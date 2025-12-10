import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionControlService {
  final String minimumRequiredVersion;
  final String apiEndpoint;

  String? _currentVersion;
  String? _newVersion;

  VersionControlService({
    required this.minimumRequiredVersion,
    required this.apiEndpoint,
  });

  /// Initializes the current version and fetches the latest version from API
  Future<void> initialize() async {
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;

    try {
      final response = await http.get(Uri.parse(apiEndpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _newVersion = data['version'];
        print("Version fetched successfully");
      }
    } catch (e) {
      print('Failed to fetch version: $e');
    }
  }

  /// Returns true if a newer version is available
  bool isUpdateAvailable() {
    if (_newVersion == null || _currentVersion == null) return false;
    return _compareVersions(_currentVersion!, _newVersion!) < 0;
  }

  /// Returns the new version string
  String? getNewVersion() => _newVersion;

  /// Returns the current version string
  String? getCurrentVersion() => _currentVersion;

  /// Compares two version strings like "1.2.3"
  int _compareVersions(String v1, String v2) {
    final a = v1.split('.').map(int.parse).toList();
    final b = v2.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      if (a[i] > b[i]) return 1;
      if (a[i] < b[i]) return -1;
    }
    return 0;
  }
}