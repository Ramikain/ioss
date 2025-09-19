import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';
import '../core/exceptions/api_exception.dart';
import '../models/event.dart';
import '../models/attendee.dart';
import '../models/checkin_record.dart';
import '../models/badge_template.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get instance => _instance;
  ApiService._internal();

  final String _baseUrl = AppConstants.baseUrl;
  String? _authToken;
  static const int _maxRetries = 3;
  static const Duration _timeoutDuration = Duration(seconds: 30);

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  Future<bool> get isConnected async {
    // try {
    //   final connectivityResult = await Connectivity().checkConnectivity();
    //   if (connectivityResult == ConnectivityResult.none) {
    //     return false;
    //   }
    //   
    //   // Test actual connectivity with a simple request
    //   final response = await http.get(
    //     Uri.parse('${AppConstants.baseUrl}/health'),
    //     headers: _headers,
    //   ).timeout(_timeoutDuration);
    //   
    //   return response.statusCode == 200;
    // } catch (e) {
    //   debugPrint('Connectivity check failed: $e');
    //   return false;
    // }
    return true; // Always return true for minimal build
  }

  Future<T> _makeRequest<T>(
    Future<http.Response> Function() request,
    T Function(dynamic) parser, {
    int retryCount = 0,
  }) async {
    try {
      if (!await isConnected) {
        throw ApiException('No internet connection', ApiErrorType.noConnection);
      }

      final response = await request().timeout(_timeoutDuration);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return parser(data);
      } else if (response.statusCode == 401) {
        _authToken = null;
        throw ApiException('Authentication failed', ApiErrorType.unauthorized);
      } else if (response.statusCode >= 500) {
        throw ApiException('Server error: ${response.statusCode}', ApiErrorType.serverError);
      } else {
        throw ApiException('Request failed: ${response.body}', ApiErrorType.clientError);
      }
    } on SocketException {
      throw ApiException('Network error', ApiErrorType.networkError);
    } on HttpException {
      throw ApiException('HTTP error', ApiErrorType.networkError);
    } on FormatException {
      throw ApiException('Invalid response format', ApiErrorType.parseError);
    } catch (e) {
      if (e is ApiException) rethrow;
      
      // Retry logic for network errors
      if (retryCount < _maxRetries && 
          (e is SocketException || e is HttpException || e.toString().contains('timeout'))) {
        debugPrint('Retrying request (attempt ${retryCount + 1}/$_maxRetries)');
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        return _makeRequest(request, parser, retryCount: retryCount + 1);
      }
      
      throw ApiException('Unexpected error: $e', ApiErrorType.unknown);
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _makeRequest(
      () => http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ),
      (data) => data,
    );
  }

  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: _headers,
      ).timeout(_timeoutDuration);
    } catch (e) {
      debugPrint('Logout error (ignored): $e');
    } finally {
      _authToken = null;
    }
  }

  // Events
  Future<List<Event>> getEvents() async {
    print('ApiService: Making request to $_baseUrl/events');
    return await _makeRequest(
      () => http.get(
        Uri.parse('$_baseUrl/events'),
        headers: _headers,
      ),
      (data) {
        print('ApiService: Received data: $data');
        final List<dynamic> eventsJson = data is List ? data : (data is Map ? (data['events'] ?? data['data'] ?? []) : []);
        print('ApiService: Parsed events JSON: $eventsJson');
        return eventsJson.map((json) => Event.fromJson(json)).toList();
      },
    );
  }

  Future<Event> getEvent(String eventId) async {
    return await _makeRequest(
      () => http.get(
        Uri.parse('$_baseUrl/events/$eventId'),
        headers: _headers,
      ),
      (data) => Event.fromJson(data is Map ? (data['event'] ?? data['data'] ?? data) : data),
    );
  }

  // Attendees
  Future<List<Attendee>> getAttendees(String eventId) async {
    print('ApiService: Making request to $_baseUrl/attendees/$eventId');
    final response = await http.get(
      Uri.parse('$_baseUrl/attendees/$eventId'),
      headers: _headers,
    );

    print('ApiService: Attendees response status: ${response.statusCode}');
    print('ApiService: Attendees response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> attendeesJson = data is List ? data : (data['attendees'] ?? data['data'] ?? []);
      print('ApiService: Parsed attendees JSON: $attendeesJson');
      final attendees = attendeesJson.map((json) => Attendee.fromJson(json)).toList();
      print('ApiService: Converted to ${attendees.length} Attendee objects');
      return attendees;
    } else {
      throw Exception('Failed to load attendees: ${response.body}');
    }
  }

  Future<Attendee?> getAttendeeByQrCode(String qrCode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/attendees/qr/$qrCode'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Attendee.fromJson(data['attendee'] ?? data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load attendee: ${response.body}');
    }
  }

  Future<List<Attendee>> searchAttendees(String eventId, String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/attendees/$eventId?search=$query'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> attendeesJson = data is List ? data : (data['attendees'] ?? data['data'] ?? []);
      return attendeesJson.map((json) => Attendee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search attendees: ${response.body}');
    }
  }

  // Check-in
  Future<Map<String, dynamic>> checkInAttendee(String qrCode) async {
    return await _makeRequest(
      () => http.post(
        Uri.parse('$_baseUrl/checkin'),
        headers: _headers,
        body: jsonEncode({
          'qrCode': qrCode,
        }),
      ),
      (data) => data,
    );
  }

  Future<void> syncCheckinRecord(CheckinRecord record) async {
    await _makeRequest(
      () => http.post(
        Uri.parse('$_baseUrl/sync-checkin'),
        headers: _headers,
        body: jsonEncode(record.toJson()),
      ),
      (data) => data,
    );
  }

  // Statistics
  Future<Map<String, dynamic>> getEventStatistics(String eventId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/analytics?event_id=$eventId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load statistics: ${response.body}');
    }
  }

  // Badge Templates
  Future<List<BadgeTemplate>> getBadgeTemplates({String? eventId, String? labelSizeId}) async {
    final queryParams = <String, String>{};
    if (eventId != null) queryParams['eventId'] = eventId;
    if (labelSizeId != null) queryParams['labelSizeId'] = labelSizeId;
    
    final uri = Uri.parse('$_baseUrl/badges/templates').replace(queryParameters: queryParams);
    
    return await _makeRequest(
      () => http.get(uri, headers: _headers),
      (data) {
        final List<dynamic> templatesJson = data is List ? data : (data['templates'] ?? data['data'] ?? []);
        return templatesJson.map((json) => BadgeTemplate.fromJson(json)).toList();
      },
    );
  }

  Future<BadgeTemplate?> getBadgeTemplate(String templateId) async {
    try {
      return await _makeRequest(
        () => http.get(
          Uri.parse('$_baseUrl/badges/templates/$templateId'),
          headers: _headers,
        ),
        (data) => BadgeTemplate.fromJson(data is Map ? (data['template'] ?? data['data'] ?? data) : data),
      );
    } catch (e) {
      debugPrint('Error fetching badge template: $e');
      return null;
    }
  }

  // Download image as base64 for printing
  Future<String?> downloadImageAsBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(_timeoutDuration);
      if (response.statusCode == 200) {
        return base64Encode(response.bodyBytes);
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  // Sync operations
  Future<void> syncData() async {
    if (!await isConnected) {
      throw Exception('No internet connection');
    }

    // Implement full data synchronization logic here
    // This would typically involve:
    // 1. Uploading local changes to server
    // 2. Downloading server changes
    // 3. Resolving conflicts
    // 4. Updating local database
  }
}