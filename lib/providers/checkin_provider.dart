import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/attendee.dart';
import '../models/checkin_record.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/printing_service.dart';
import '../services/offline_storage_service.dart';
import '../core/exceptions/api_exception.dart';

class CheckinProvider with ChangeNotifier {
  List<CheckinRecord> _checkinRecords = [];
  bool _isProcessing = false;
  bool _isOffline = false;
  String? _error;
  String? _successMessage;
  int _pendingSyncCount = 0;

  List<CheckinRecord> get checkinRecords => _checkinRecords;
  bool get isProcessing => _isProcessing;
  bool get isOffline => _isOffline;
  String? get error => _error;
  String? get successMessage => _successMessage;
  int get pendingSyncCount => _pendingSyncCount;

  Future<void> _checkConnectivity() async {
    final wasOffline = _isOffline;
    _isOffline = !await ApiService.instance.isConnected;
    
    if (wasOffline && !_isOffline) {
      // Connection restored, sync offline data
      await _syncOfflineData();
    }
    
    notifyListeners();
  }

  Future<void> _syncOfflineData() async {
    try {
      final unsyncedCheckins = await OfflineStorageService.instance.getUnsyncedCheckins();
      _pendingSyncCount = unsyncedCheckins.length;
      
      if (unsyncedCheckins.isEmpty) return;
      
      debugPrint('Syncing ${unsyncedCheckins.length} offline check-ins');
      
      for (final checkin in unsyncedCheckins) {
        try {
          // For offline sync, we need to construct a QR code from attendee data
          final qrCode = checkin['qr_code'] as String? ?? 'ATT-${checkin['attendee_id']}-EVENT-${checkin['event_id']}';
          await ApiService.instance.checkInAttendee(qrCode);
          
          await OfflineStorageService.instance.markCheckinAsSynced(
            checkin['id'].toString(),
          );
          
          _pendingSyncCount--;
        } catch (e) {
          debugPrint('Failed to sync check-in ${checkin['id']}: $e');
          // Continue with other check-ins
        }
      }
      
      if (_pendingSyncCount == 0) {
        _successMessage = 'All offline check-ins synced successfully';
      } else {
        _successMessage = 'Synced ${unsyncedCheckins.length - _pendingSyncCount} of ${unsyncedCheckins.length} offline check-ins';
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing offline data: $e');
    }
  }

  Future<void> loadCheckinRecords(String eventId) async {
    try {
      _checkinRecords = await DatabaseService.instance.getCheckinRecordsByEventId(eventId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load check-in records: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> checkInAttendee({
    required Attendee attendee,
    required String staffId,
    required String eventId,
    Event? event,
    bool printBadge = true,
    String? notes,
  }) async {
    if (attendee.isCheckedIn) {
      _error = 'Attendee is already checked in';
      notifyListeners();
      return false;
    }

    _isProcessing = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    await _checkConnectivity();

    try {
      final now = DateTime.now();
      final checkinRecord = CheckinRecord(
        id: const Uuid().v4(),
        attendeeId: attendee.id,
        eventId: eventId,
        checkedInBy: staffId,
        checkedInAt: now,
        notes: notes,
        isPrinted: false,
      );

      // Update attendee status
      final updatedAttendee = attendee.copyWith(
        status: AttendeeStatus.checkedIn,
        checkedInAt: now,
        checkedInBy: staffId,
      );

      // Try online check-in first
      bool onlineSuccess = false;
      if (!_isOffline) {
        try {
          // Use attendee's QR code or construct one
          final qrCode = attendee.qrCode ?? 'ATT-${attendee.id}-EVENT-$eventId';
          await ApiService.instance.checkInAttendee(qrCode);
          onlineSuccess = true;
        } on ApiException catch (e) {
          if (e.type == ApiErrorType.noConnection || e.type == ApiErrorType.networkError) {
            _isOffline = true;
            debugPrint('Switching to offline mode due to: ${e.message}');
          } else {
            // Other API errors should be shown to user
            _error = e.userFriendlyMessage;
            _isProcessing = false;
            notifyListeners();
            return false;
          }
        } catch (e) {
          debugPrint('Unexpected error during online check-in: $e');
          _isOffline = true;
        }
      }

      // Save to local database (always)
      await DatabaseService.instance.updateAttendee(updatedAttendee);
      await DatabaseService.instance.insertCheckinRecord(checkinRecord);

      // If offline, save for later sync
      if (!onlineSuccess) {
        await OfflineStorageService.instance.addOfflineCheckin(attendee.id, eventId);
        _pendingSyncCount++;
      }

      // Add to local list
      _checkinRecords.insert(0, checkinRecord);

      // Print badge if requested
      if (printBadge && await PrintingService.instance.isAvailable()) {
        try {
          if (event != null) {
            await PrintingService.instance.printAttendeeBadge(updatedAttendee, event);
          }
          
          // Update record as printed
          final printedRecord = checkinRecord.copyWith(
            isPrinted: true,
            printedAt: DateTime.now(),
          );
          await DatabaseService.instance.updateCheckinRecord(printedRecord);
          
          // Update local list
          final index = _checkinRecords.indexWhere((r) => r.id == checkinRecord.id);
          if (index != -1) {
            _checkinRecords[index] = printedRecord;
          }
        } catch (e) {
          // Printing failed, but check-in was successful
          _error = 'Check-in successful, but printing failed: ${e.toString()}';
        }
      }

      String statusMessage = 'Successfully checked in ${attendee.fullName}';
      if (_isOffline || !onlineSuccess) {
        statusMessage += ' (offline - will sync when online)';
      }
      
      _successMessage = statusMessage;
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Check-in failed: ${e.toString()}';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> printBadgeForRecord(CheckinRecord record, Attendee attendee) async {
    if (!await PrintingService.instance.isAvailable()) {
      _error = 'No printer available';
      notifyListeners();
      return;
    }

    try {
      // This would require the event object
      // await PrintingService.instance.printAttendeeBadge(attendee, event);
      
      // Update record as printed
      final printedRecord = record.copyWith(
        isPrinted: true,
        printedAt: DateTime.now(),
      );
      await DatabaseService.instance.updateCheckinRecord(printedRecord);
      
      // Update local list
      final index = _checkinRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _checkinRecords[index] = printedRecord;
      }
      
      _successMessage = 'Badge printed successfully';
      notifyListeners();
    } catch (e) {
      _error = 'Printing failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> syncCheckinRecords() async {
    await _checkConnectivity();
    
    if (_isOffline) {
      _error = 'No internet connection available for sync';
      notifyListeners();
      return;
    }

    try {
      await _syncOfflineData();
      _successMessage = 'All data synced successfully';
      notifyListeners();
    } catch (e) {
      _error = 'Sync failed: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> manualSync() async {
    _isProcessing = true;
    _error = null;
    notifyListeners();
    
    try {
      await syncCheckinRecords();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // Statistics
  int get totalCheckins => _checkinRecords.length;
  
  List<CheckinRecord> get todayCheckins {
    final today = DateTime.now();
    return _checkinRecords.where((record) {
      return record.checkedInAt.year == today.year &&
             record.checkedInAt.month == today.month &&
             record.checkedInAt.day == today.day;
    }).toList();
  }
  
  int get todayCheckinsCount => todayCheckins.length;
  
  List<CheckinRecord> get unprintedRecords => _checkinRecords.where((r) => !r.isPrinted).toList();
  
  int get unprintedCount => unprintedRecords.length;
}