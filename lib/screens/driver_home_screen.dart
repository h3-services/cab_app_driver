import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../widgets/ride_card.dart';
import '../services/fcm_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeFCM();
    FCMService.setupMessageHandlers(context);
    _showTestNotification();
  }

  void _initializeFCM() async {
    String? token = await FCMService.initialize();
    if (token != null && mounted) {
      _showTokenDialog(token);
    }
  }

  void _showTokenDialog(String token) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('FCM Registration Token'),
            content: SelectableText(token),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _showTestNotification() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.notifications, color: Colors.blue),
                SizedBox(width: 8),
                Text('New Ride Request'),
              ],
            ),
            content: const Text('Pickup from Anna Nagar to T Nagar'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('View'),
              ),
            ],
          ),
        );
      }
    });
  }

  final List<Ride> _rides = [
    Ride(
      id: 'RIDE101',
      pickup: 'Anna Nagar',
      drop: 'T Nagar',
      timeText: 'Today, 4:30 PM',
      passengerName: 'Raj Kumar',
      passengerPhone: '+91 98765 43210',
    ),
    Ride(
      id: 'RIDE102',
      pickup: 'Vadapalani',
      drop: 'OMR',
      timeText: 'Today, 5:00 PM',
      passengerName: 'Priya',
      passengerPhone: '+91 99887 66554',
    ),
  ];

  void _showDriverInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.person),
                SizedBox(width: 12),
                Text('Name: Kumar Selvam', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.phone),
                SizedBox(width: 12),
                Text('Mobile: +91 98765 12345', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rides'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: _showDriverInfo,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _rides.length,
        itemBuilder: (context, index) {
          return RideCard(
            ride: _rides[index],
            onAccept: () {
              setState(() {
                _rides[index].isAccepted = true;
              });
            },
          );
        },
      ),
    );
  }
}
