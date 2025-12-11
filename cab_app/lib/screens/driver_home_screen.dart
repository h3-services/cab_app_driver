import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/driver.dart';
import '../models/trip.dart';
import '../services/local_storage_service.dart';
import '../services/auth_middleware.dart';
import '../theme/colors.dart';
import '../widgets/auth_guard.dart';
import 'driver_profile_view_screen.dart';
import 'wallet_screen.dart';
import 'login_screen.dart';
import 'trip_accepted_screen.dart';
import 'kyc_upload_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _localStorageService = LocalStorageService();
  final _authMiddleware = AuthMiddleware();
  Driver? _driver;
  List<Trip> _availableTrips = [];
  List<Trip> _approvedTrips = [];
  List<Trip> _completedTrips = [];
  Map<String, String> _tripStatuses = {};
  bool _isLoading = true;
  int _selectedIndex = 0;
  int _tripTabIndex = 0; // 0 = Available, 1 = Approved, 2 = Completed
  bool _isGpsEnabled = true;
  bool _isInternetConnected = true;
  DateTime _lastLocationUpdate = DateTime.now();
  bool _isLocationLive = true;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
    _loadMockTrips();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    // Simulate location updates every 10 seconds
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _driver?.isAvailable == true) {
        setState(() {
          _lastLocationUpdate = DateTime.now();
        });
      }
    });
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
    
    // Show KYC dialog if not completed
    if (!_driver!.kycCompleted && !_driver!.isAvailable) {
      _showKycDialog();
      return;
    }
    
    final updatedDriver = _driver!.copyWith(isAvailable: !_driver!.isAvailable);
    await _localStorageService.saveDriver(updatedDriver);
    setState(() => _driver = updatedDriver);
  }

  void _showKycDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user, color: AppColors.iconBg),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'KYC Verification Required',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'You need to complete KYC verification to go online and receive trip requests. Please upload your required documents.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.grayText)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KycUploadScreen(driver: _driver!),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.acceptedColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete KYC'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await _authMiddleware.signOut();
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
        builder: (context) => DriverProfileViewScreen(driver: _driver!),
      ),
    );
  }

  void _acceptTrip(Trip trip) {
    setState(() {
      _availableTrips.remove(trip);
      _approvedTrips.add(trip);
      _tripStatuses[trip.id] = 'pending';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trip request sent to admin for approval!'),
        backgroundColor: AppColors.pendingColor,
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
        title: Text(_driver!.name),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: _openProfile,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.grayText,
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Availability Status', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          _driver!.isAvailable ? 'Available for trips' : (_driver!.kycCompleted ? 'Not available' : 'KYC Required'),
                          style: TextStyle(
                            color: _driver!.isAvailable ? Colors.green : (_driver!.kycCompleted ? Colors.red : Colors.grey),
                          ),
                        ),
                        if (_driver!.isAvailable) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isLocationLive ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _isLocationLive ? 'Location Live' : 'Location Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isLocationLive ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Last updated: ${_getTimeAgo(_lastLocationUpdate)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.grayText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Switch(
                    value: _driver!.isAvailable,
                    onChanged: (_) => _toggleAvailability(),
                    activeColor: _driver!.kycCompleted ? Colors.green : Colors.grey,
                    inactiveThumbColor: _driver!.kycCompleted ? null : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Warning Cards
          if (_driver!.isAvailable) ...[
            // Battery Optimization Warning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.pendingColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.pendingColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.battery_alert, color: AppColors.pendingColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Disable battery optimization for accurate location tracking.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.pendingColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // GPS Alert
            if (!_isGpsEnabled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.rejectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.rejectedColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gps_off, color: AppColors.rejectedColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS is disabled. Enable GPS for location tracking.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.rejectedColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Internet Alert
            if (!_isInternetConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.grayText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grayText.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: AppColors.grayText, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Internet offline. Sync pending...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grayText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          if (_driver!.isAvailable) ...[
            // Tab Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _tripTabIndex = 0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tripTabIndex == 0 ? AppColors.acceptedColor : AppColors.cardBg,
                      foregroundColor: _tripTabIndex == 0 ? Colors.white : AppColors.grayText,
                      elevation: _tripTabIndex == 0 ? 2 : 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Available (${_availableTrips.length})'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _tripTabIndex = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tripTabIndex == 1 ? AppColors.acceptedColor : AppColors.cardBg,
                      foregroundColor: _tripTabIndex == 1 ? Colors.white : AppColors.grayText,
                      elevation: _tripTabIndex == 1 ? 2 : 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Approved (${_approvedTrips.length})'),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _tripTabIndex == 2 ? AppColors.acceptedColor : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _tripTabIndex == 2 ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: IconButton(
                    onPressed: () => setState(() => _tripTabIndex = 2),
                    icon: Icon(
                      Icons.history,
                      color: _tripTabIndex == 2 ? Colors.white : AppColors.grayText,
                    ),
                    tooltip: 'Completed Trips (${_completedTrips.length})',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Trip Content based on selected tab
            if (_tripTabIndex == 0)
              ..._availableTrips.map((trip) => _buildTripCard(trip, false)).toList()
            else if (_tripTabIndex == 1)
              ..._approvedTrips.map((trip) => _buildTripCard(trip, true)).toList()
            else
              ..._completedTrips.map((trip) => _buildCompletedTripCard(trip)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip, bool isApproved) {
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
                if (!isApproved && status == 'available')
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
                else if (isApproved)
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripAcceptedScreen(trip: trip),
                        ),
                      );
                      if (result == 'completed') {
                        _moveToCompleted(trip);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueStart,
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
  }

  Widget _buildCompletedTripCard(Trip trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.acceptedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.acceptedColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.acceptedColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: AppColors.acceptedColor,
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
                    Text('Earned: ₹${trip.fare.toStringAsFixed(0)}', 
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.acceptedColor)),
                    Text('Distance: ${trip.distance?.toStringAsFixed(1)} km'),
                    if (trip.completedAt != null)
                      Text('Completed: ${_formatDate(trip.completedAt!)}', 
                           style: TextStyle(color: AppColors.grayText, fontSize: 12)),
                  ],
                ),
                Icon(Icons.check_circle, color: AppColors.acceptedColor, size: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _moveToCompleted(Trip trip) {
    setState(() {
      _approvedTrips.remove(trip);
      final completedTrip = Trip(
        id: trip.id,
        riderId: trip.riderId,
        driverId: trip.driverId,
        pickupAddress: trip.pickupAddress,
        dropAddress: trip.dropAddress,
        pickupLat: trip.pickupLat,
        pickupLng: trip.pickupLng,
        dropLat: trip.dropLat,
        dropLng: trip.dropLng,
        vehicleType: trip.vehicleType,
        fare: trip.fare,
        status: 'completed',
        requestedAt: trip.requestedAt,
        acceptedAt: trip.acceptedAt,
        startedAt: trip.startedAt,
        completedAt: DateTime.now(),
        riderName: trip.riderName,
        riderPhone: trip.riderPhone,
        distance: trip.distance,
        startKm: trip.startKm,
        endKm: trip.endKm,
        tollAmount: trip.tollAmount,
        driverAllowance: trip.driverAllowance,
        kmRate: trip.kmRate,
        walletFeeDeducted: trip.walletFeeDeducted,
      );
      _completedTrips.add(completedTrip);
      _tripStatuses.remove(trip.id);
    });
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

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} sec ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}