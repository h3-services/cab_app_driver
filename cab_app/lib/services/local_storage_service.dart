import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver.dart';

class LocalStorageService {
  static const String _driverKey = 'driver_data';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> saveDriver(Driver driver) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverKey, jsonEncode(driver.toMap()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<void> saveDriverData(Driver driver) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverKey, jsonEncode(driver.toMap()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<Driver?> getDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final driverJson = prefs.getString(_driverKey);
    if (driverJson != null) {
      return Driver.fromMap(jsonDecode(driverJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_driverKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}