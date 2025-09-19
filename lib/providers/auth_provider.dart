import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userRole;
  String? _authToken;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userRole => _userRole;
  String? get authToken => _authToken;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    // final prefs = await SharedPreferences.getInstance();
    // _authToken = prefs.getString(AppConstants.keyAuthToken);
    // _userId = prefs.getString(AppConstants.keyUserId);
    // _userRole = prefs.getString(AppConstants.keyUserRole);
    
    // if (_authToken != null && _userId != null) {
    //   _isAuthenticated = true;
    //   ApiService.instance.setAuthToken(_authToken!);
    // }
    
    // Use post frame callback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.instance.login(email, password);
      
      _authToken = response['token'];
      _userId = response['user']['id'];
      _userRole = response['user']['role'];
      _isAuthenticated = true;

      // Save to shared preferences
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString(AppConstants.keyAuthToken, _authToken!);
      // await prefs.setString(AppConstants.keyUserId, _userId!);
      // await prefs.setString(AppConstants.keyUserRole, _userRole!);

      // Set token in API service
      ApiService.instance.setAuthToken(_authToken!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.instance.logout();
    } catch (e) {
      // Ignore logout errors
    }

    // Clear local data
    _isAuthenticated = false;
    _userId = null;
    _userRole = null;
    _authToken = null;

    // Clear shared preferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove(AppConstants.keyAuthToken);
    // await prefs.remove(AppConstants.keyUserId);
    // await prefs.remove(AppConstants.keyUserRole);
    // await prefs.remove(AppConstants.keySelectedEventId);

    _isLoading = false;
    notifyListeners();
  }

  bool hasRole(String role) {
    return _userRole == role || _userRole == 'admin';
  }

  bool canManageEvents() {
    return hasRole('admin') || hasRole('organizer');
  }

  bool canCheckInAttendees() {
    return hasRole('admin') || hasRole('organizer') || hasRole('staff');
  }
}