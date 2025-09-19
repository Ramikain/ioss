import 'package:flutter/foundation.dart';

import '../models/attendee.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class AttendeeProvider with ChangeNotifier {
  List<Attendee> _attendees = [];
  List<Attendee> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String _searchQuery = '';

  List<Attendee> get attendees => _attendees;
  List<Attendee> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadAttendees(String eventId) async {
    print('AttendeeProvider: Starting to load attendees for event: $eventId');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Always try API first, then check connection status
      print('AttendeeProvider: Checking API connection...');
      final isConnected = await ApiService.instance.isConnected;
      print('AttendeeProvider: API connection status: $isConnected');
      
      if (isConnected) {
        print('AttendeeProvider: API is connected, fetching attendees from API');
        try {
          final apiAttendees = await ApiService.instance.getAttendees(eventId);
          print('AttendeeProvider: Received ${apiAttendees.length} attendees from API');
          
          // Save to local database
          for (final attendee in apiAttendees) {
            await DatabaseService.instance.insertAttendee(attendee);
          }
          
          _attendees = apiAttendees;
        } catch (apiError) {
          print('AttendeeProvider: API call failed: $apiError');
          // Fallback to local database
          _attendees = await DatabaseService.instance.getAttendeesByEventId(eventId);
          print('AttendeeProvider: API fallback - loaded ${_attendees.length} attendees from local database');
          _error = 'API failed, using local data: ${apiError.toString()}';
        }
      } else {
        print('AttendeeProvider: API not connected, loading from local database');
        // Load from local database
        _attendees = await DatabaseService.instance.getAttendeesByEventId(eventId);
        print('AttendeeProvider: Loaded ${_attendees.length} attendees from local database');
      }
    } catch (e) {
      print('AttendeeProvider: General error loading attendees: $e');
      // Final fallback to local database
      _attendees = await DatabaseService.instance.getAttendeesByEventId(eventId);
      print('AttendeeProvider: Final fallback - loaded ${_attendees.length} attendees from local database');
      _error = 'Failed to load attendees: ${e.toString()}';
    }

    print('AttendeeProvider: Final attendee count: ${_attendees.length}');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchAttendees(String eventId, String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      // Try API search first
      if (await ApiService.instance.isConnected) {
        _searchResults = await ApiService.instance.searchAttendees(eventId, query);
      } else {
        // Fallback to local database search
        _searchResults = await DatabaseService.instance.searchAttendees(eventId, query);
      }
    } catch (e) {
      // Fallback to local database search
      _searchResults = await DatabaseService.instance.searchAttendees(eventId, query);
      _error = 'Search failed: ${e.toString()}';
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<Attendee?> getAttendeeByQrCode(String qrCode) async {
    try {
      // Try API first
      if (await ApiService.instance.isConnected) {
        return await ApiService.instance.getAttendeeByQrCode(qrCode);
      } else {
        // Fallback to local database
        return await DatabaseService.instance.getAttendeeByQrCode(qrCode);
      }
    } catch (e) {
      return await DatabaseService.instance.getAttendeeByQrCode(qrCode);
    }
  }

  Future<void> updateAttendee(Attendee attendee) async {
    try {
      // Update local database first
      await DatabaseService.instance.updateAttendee(attendee);
      
      // Update in memory list
      final index = _attendees.indexWhere((a) => a.id == attendee.id);
      if (index != -1) {
        _attendees[index] = attendee;
      }
      
      // Update search results if applicable
      final searchIndex = _searchResults.indexWhere((a) => a.id == attendee.id);
      if (searchIndex != -1) {
        _searchResults[searchIndex] = attendee;
      }
      
      notifyListeners();
      
      // Try to sync with API in background
      if (await ApiService.instance.isConnected) {
        // This would typically be a PUT request to update the attendee
        // Implementation depends on your API structure
      }
    } catch (e) {
      _error = 'Failed to update attendee: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Statistics
  int get totalAttendees => _attendees.length;
  
  int get checkedInCount => _attendees.where((a) => a.isCheckedIn).length;
  
  int get vipCount => _attendees.where((a) => a.isVip).length;
  
  double get checkinRate => totalAttendees > 0 ? (checkedInCount / totalAttendees) * 100 : 0;

  List<Attendee> get checkedInAttendees => _attendees.where((a) => a.isCheckedIn).toList();
  
  List<Attendee> get notCheckedInAttendees => _attendees.where((a) => !a.isCheckedIn).toList();
  
  List<Attendee> get vipAttendees => _attendees.where((a) => a.isVip).toList();
}