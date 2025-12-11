import 'package:flutter/material.dart';
import 'widgets/network_monitor.dart';
import 'services/network_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Monitor Example',
      home: NetworkMonitor(
        child: StreamBuilder<bool>(
          stream: NetworkService().networkStream,
          builder: (context, snapshot) {
            // Your existing app logic here
            return const HomePage();
          },
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your App')),
      body: const Center(
        child: Text('Your app content'),
      ),
    );
  }
}

// Example of how to use NetworkService in any widget
class ExampleUsage extends StatefulWidget {
  const ExampleUsage({super.key});

  @override
  State<ExampleUsage> createState() => _ExampleUsageState();
}

class _ExampleUsageState extends State<ExampleUsage> {
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
    
    // Listen to network changes
    _networkService.networkStream.listen((isConnected) {
      print('Network status: $isConnected');
      // Handle network status changes
    });
    
    // Check current status
    bool currentStatus = _networkService.isConnected;
    print('Current network status: $currentStatus');
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Your widget content
  }
}