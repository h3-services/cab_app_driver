import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/driver.dart';
import '../models/trip.dart';
import '../services/local_storage_service.dart';
import '../theme/colors.dart';
import 'driver_profile_screen.dart';
import 'wallet_screen.dart';
import 'login_screen.dart';
import 'trip_accepted_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _localStorageService = LocalStorageService();
  Driver? _driver;
  List<Trip> _availableTrips = [];
  Map<String, String> _tripStatuses = {};
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
    _loadMockTrips();
  }

  Future<void> _loadDriverData() async {
    final driver = await _localStorageService.getDriver();
    setState(() {
      _driver = driver;
      _isLoading = false;
    });
  }

  void _loadMockTrips() {
    _availableTrips = [
      Trip(
        id: 'trip_001',
        riderId: 'rider_001',
        pickupAddress: 'Airport Terminal 1',
        dropAddress: 'City Center Mall',
        pickupLat: 28.5562,
        pickupLng: 77.1000,
        dropLat: 28.6139,
        dropLng: 77.2090,
        vehicleType: 'Sedan',
        fare: 250.0,
        requestedAt: DateTime.now(),
        riderName: 'Alice Smith',
        riderPhone: '+1234567890',
        distance: 15.2,
      ),
      Trip(
        id: 'trip_002',
        riderId: 'rider_002',
        pickupAddress: 'Railway Station',
        dropAddress: 'Business District',
        pickupLat: 28.6448,
        pickupLng: 77.2167,
        dropLat: 28.6304,
        dropLng: 77.2177,
        vehicleType: 'Sedan',
        fare: 180.0,
        requestedAt: DateTime.now(),
        riderName: 'Bob Johnson',
        riderPhone: '+1234567891',
        distance: 8.5,
      ),
    ];
  }

  Future<void> _toggleAvailability() async {
    if (_driver == null) return;
    
    final updatedDriver = _driver!.copyWith(isAvailable: !_driver!.isAvailable);
    await _localStorageService.saveDriver(updatedDriver);
    setState(() => _driver = updatedDriver);
  }

  Future<void> _signOut() async {
    await _localStorageService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverProfileScreen(driver: _driver!),
      ),
    );
  }

  void _acceptTrip(Trip trip) {
    setState(() {
      _tripStatuses[trip.id] = 'accepted';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trip to ${trip.dropAddress} accepted!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to Trip Accepted Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripAcceptedScreen(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.mainBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_driver == null) {
      return const Scaffold(
        backgroundColor: AppColors.mainBg,
        body: Center(child: Text('Driver data not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: Text('Hello, ${_driver!.name}'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _openProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return WalletScreen(driver: _driver!);
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Availability Status', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        _driver!.isAvailable ? 'Available for trips' : 'Not available',
                        style: TextStyle(
                          color: _driver!.isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _driver!.isAvailable,
                    onChanged: (_) => _toggleAvailability(),
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (_driver!.isAvailable) ...[
            const Text('Available Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._availableTrips.map((trip) {
              final status = _tripStatuses[trip.id] ?? 'available';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip Status Badge
                      if (status != 'available')
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getStatusIcon(status), color: _getStatusColor(status), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusText(status),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              trip.pickupAddress,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              trip.dropAddress,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fare: ₹${trip.fare.toStringAsFixed(0)}', 
                                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Distance: ${trip.distance?.toStringAsFixed(1)} km'),
                              if (trip.riderName != null)
                                Text('Rider: ${trip.riderName}'),
                            ],
                          ),
                          if (status == 'available')
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _acceptTrip(trip),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Accept Ride', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripAcceptedScreen(trip: trip),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              child: const Text('View Trip'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted': return Colors.blue;
      case 'started': return Colors.purple;
      case 'completed': return Colors.green;
      default: return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted': return Icons.check_circle;
      case 'started': return Icons.play_circle;
      case 'completed': return Icons.check_circle;
      default: return Icons.radio_button_unchecked;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted': return 'Trip Accepted';
      case 'started': return 'Trip Started';
      case 'completed': return 'Trip Completed';
      default: return 'Available';
    }
  }
}