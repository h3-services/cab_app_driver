import 'package:flutter/material.dart';
import '../services/version_control_service.dart';
import '../services/network_service.dart';
import 'version_control_page.dart';
import 'network_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final VersionControlService _versionService = VersionControlService(
    minimumRequiredVersion: '1.0.0',
    apiEndpoint: 'https://h3-services.github.io/versionController/cab_app_version.json',
  );
  final NetworkService _networkService = NetworkService();
  String _versionStatus = 'Checking version...';
  String _networkStatus = 'Checking network...';

  @override
  void initState() {
    super.initState();
    _checkVersion();
    _checkNetwork();
  }

  Future<void> _checkVersion() async {
    await _versionService.initialize();
    setState(() {
      if (_versionService.isUpdateAvailable()) {
        _versionStatus = 'Update available: ${_versionService.getNewVersion()}';
      } else {
        _versionStatus = 'Current version: ${_versionService.getCurrentVersion()}';
      }
    });
  }

  Future<void> _checkNetwork() async {
    final isConnected = await _networkService.isNetworkConnected();
    setState(() {
      _networkStatus = isConnected ? 'Network: Connected' : 'Network: Disconnected';
    });
    
    if (mounted) {
      if (isConnected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VersionControlPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NetworkPage()),
        );
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_versionStatus),
            Text(_networkStatus),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VersionControlPage()),
              ),
              child: const Text('Version Control'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NetworkPage()),
              ),
              child: const Text('Network Status'),
            ),
            const SizedBox(height: 20),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}