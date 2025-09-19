import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  Event? _selectedEvent;
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  Event? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    await loadEvents();
    await loadSelectedEvent();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load from API first
      print('EventProvider: Checking API connection...');
      if (await ApiService.instance.isConnected) {
        print('EventProvider: API connected, fetching events...');
        final apiEvents = await ApiService.instance.getEvents();
        print('EventProvider: Received ${apiEvents.length} events from API');
        
        // Save to local database
        for (final event in apiEvents) {
          await DatabaseService.instance.insertEvent(event);
        }
        
        _events = apiEvents;
      } else {
        print('EventProvider: API not connected, loading from local database...');
        // Load from local database
        _events = await DatabaseService.instance.getAllEvents();
        print('EventProvider: Loaded ${_events.length} events from local database');
      }
    } catch (e) {
      print('EventProvider: Error loading events: $e');
      // Fallback to local database
      _events = await DatabaseService.instance.getAllEvents();
      print('EventProvider: Fallback - loaded ${_events.length} events from local database');
      _error = 'Failed to sync events: ${e.toString()}';
    }

    print('EventProvider: Final event count: ${_events.length}');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectEvent(Event event) async {
    _selectedEvent = event;
    
    // Save selected event to shared preferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(AppConstants.keySelectedEventId, event.id);
    
    notifyListeners();
  }

  Future<void> loadSelectedEvent() async {
    // final prefs = await SharedPreferences.getInstance();
    // final selectedEventId = prefs.getString(AppConstants.keySelectedEventId);
    
    // if (selectedEventId != null) {
    //   try {
    //     _selectedEvent = await DatabaseService.instance.getEventById(selectedEventId);
    //     notifyListeners();
    //   } catch (e) {
    //     // Event not found, clear selection
    //     await prefs.remove(AppConstants.keySelectedEventId);
    //   }
    // }
  }

  Future<void> refreshEvents() async {
    await loadEvents();
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      // Try API first
      if (await ApiService.instance.isConnected) {
        return await ApiService.instance.getEvent(eventId);
      } else {
        // Fallback to local database
        return await DatabaseService.instance.getEventById(eventId);
      }
    } catch (e) {
      return await DatabaseService.instance.getEventById(eventId);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get hasSelectedEvent => _selectedEvent != null;

  String get selectedEventName => _selectedEvent?.name ?? 'No Event Selected';
}