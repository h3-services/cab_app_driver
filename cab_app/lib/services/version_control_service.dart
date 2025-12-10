import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class VersionControlService {
  static const String _apiUrl = 'https://h3-services.github.io/versionController/cab_app_version.json';
  static const String _defaultAndroidVersion = '1.0.0';
  static const String _defaultIosVersion = '1.0.0';
  
  String? _remoteAndroidVersion;
  String? _remoteIosVersion;
  bool _isInitialized = false;

  Future<bool> checkVersionAndInitialize() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _remoteAndroidVersion = data['android'];
        _remoteIosVersion = data['ios'];
        _isInitialized = true;
        
        // Check if update is needed
        return _isUpdateRequired();
      } else {
        if (kDebugMode) {
          print('Failed to fetch version info: ${response.statusCode}');
        }
        return false; // If API fails, continue to app
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking version: $e');
      }
      return false; // If error occurs, continue to app
    }
  }

  bool _isUpdateRequired() {
    if (!_isInitialized) return false;
    
    // For Android (you can modify this logic based on platform detection)
    return _remoteAndroidVersion != _defaultAndroidVersion || 
           _remoteIosVersion != _defaultIosVersion;
  }

  String get currentAndroidVersion => _defaultAndroidVersion;
  String get currentIosVersion => _defaultIosVersion;
  String? get remoteAndroidVersion => _remoteAndroidVersion;
  String? get remoteIosVersion => _remoteIosVersion;
  
  bool get isInitialized => _isInitialized;
}