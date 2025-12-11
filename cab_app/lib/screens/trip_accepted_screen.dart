import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/trip.dart';
import '../theme/colors.dart';
import 'odometer_input_screen.dart';
import 'trip_cost_breakdown_screen.dart';


class TripAcceptedScreen extends StatefulWidget {
  final Trip trip;

  const TripAcceptedScreen({super.key, required this.trip});

  @override
  State<TripAcceptedScreen> createState() => _TripAcceptedScreenState();
}

class _TripAcceptedScreenState extends State<TripAcceptedScreen> {
  String _tripStatus = 'pending'; // Changed to pending initially
  late Trip _currentTrip;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
  }

  Future<void> _startTrip() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => OdometerInputScreen(
          trip: _currentTrip,
          isStarting: true,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentTrip = Trip(
          id: _currentTrip.id,
          riderId: _currentTrip.riderId,
          driverId: _currentTrip.driverId,
          pickupAddress: _currentTrip.pickupAddress,
          dropAddress: _currentTrip.dropAddress,
          pickupLat: _currentTrip.pickupLat,
          pickupLng: _currentTrip.pickupLng,
          dropLat: _currentTrip.dropLat,
          dropLng: _currentTrip.dropLng,
          vehicleType: _currentTrip.vehicleType,
          fare: _currentTrip.fare,
          status: 'started',
          requestedAt: _currentTrip.requestedAt,
          acceptedAt: _currentTrip.acceptedAt,
          startedAt: DateTime.now(),
          completedAt: _currentTrip.completedAt,
          riderName: _currentTrip.riderName,
          riderPhone: _currentTrip.riderPhone,
          distance: _currentTrip.distance,
          startKm: result['startKm'],
          endKm: _currentTrip.endKm,
          tollAmount: _currentTrip.tollAmount,
          driverAllowance: _currentTrip.driverAllowance,
          kmRate: _currentTrip.kmRate,
          walletFeeDeducted: _currentTrip.walletFeeDeducted,
        );
        _tripStatus = 'started';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip started! Navigate to destination.'),
          backgroundColor: AppColors.blueStart,
        ),
      );
    }
  }

  Future<void> _completeTrip() async {
    final odometerResult = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => OdometerInputScreen(
          trip: _currentTrip,
          isStarting: false,
        ),
      ),
    );

    if (odometerResult != null) {
      final costResult = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => TripCostBreakdownScreen(
            trip: _currentTrip,
            endKm: odometerResult['endKm'],
            tollAmount: odometerResult['tollAmount'],
            driverAllowance: odometerResult['driverAllowance'],
          ),
        ),
      );

      if (costResult != null) {
        setState(() {
          _currentTrip = Trip(
            id: _currentTrip.id,
            riderId: _currentTrip.riderId,
            driverId: _currentTrip.driverId,
            pickupAddress: _currentTrip.pickupAddress,
            dropAddress: _currentTrip.dropAddress,
            pickupLat: _currentTrip.pickupLat,
            pickupLng: _currentTrip.pickupLng,
            dropLat: _currentTrip.dropLat,
            dropLng: _currentTrip.dropLng,
            vehicleType: _currentTrip.vehicleType,
            fare: _currentTrip.fare,
            status: 'completed',
            requestedAt: _currentTrip.requestedAt,
            acceptedAt: _currentTrip.acceptedAt,
            startedAt: _currentTrip.startedAt,
            completedAt: DateTime.now(),
            riderName: _currentTrip.riderName,
            riderPhone: _currentTrip.riderPhone,
            distance: _currentTrip.distance,
            startKm: _currentTrip.startKm,
            endKm: costResult['endKm'],
            tollAmount: costResult['tollAmount'],
            driverAllowance: costResult['driverAllowance'],
            kmRate: _currentTrip.kmRate,
            walletFeeDeducted: costResult['walletFee'],
          );
          _tripStatus = 'completed';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip completed! ₹${costResult['netEarnings'].toStringAsFixed(0)} earned.'),
            backgroundColor: AppColors.acceptedColor,
          ),
        );
      }
    }
  }

  Future<void> _navigateToLocation(double lat, double lng, String address) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  Future<void> _callRider() async {
    if (_currentTrip.riderPhone != null) {
      final url = 'tel:${_currentTrip.riderPhone}';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Trip Request'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Trip Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: _getStatusColor().withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(), color: _getStatusColor(), size: 22),
                        const SizedBox(width: 10),
                        Text(
                          _getStatusText(),
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '₹${_currentTrip.fare.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.acceptedColor,
                    ),
                  ),
                  Text(
                    'Trip Fare',
                    style: TextStyle(
                      color: AppColors.grayText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Trip Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLocationRow(
                    Icons.radio_button_checked,
                    AppColors.acceptedColor,
                    'Pickup Location',
                    _currentTrip.pickupAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildLocationRow(
                    Icons.location_on,
                    AppColors.rejectedColor,
                    'Drop Location',
                    _currentTrip.dropAddress,
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem('Distance', '${_currentTrip.distance?.toStringAsFixed(1)} km'),
                      ),
                      Expanded(
                        child: _buildInfoItem('Vehicle', _currentTrip.vehicleType),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rider Info Card
            if (_currentTrip.riderName != null || _currentTrip.riderPhone != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rider Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_currentTrip.riderName != null)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.blueStart.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.person, color: AppColors.blueStart, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(_currentTrip.riderName!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    if (_currentTrip.riderPhone != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.acceptedColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.phone, color: AppColors.acceptedColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(_currentTrip.riderPhone!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Status Message
            if (_tripStatus == 'pending') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pendingColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.pendingColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.hourglass_empty, color: AppColors.pendingColor, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'Waiting for Admin Approval',
                      style: TextStyle(
                        color: AppColors.pendingColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your trip request has been sent to admin for approval. Please wait.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grayText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _tripStatus = 'accepted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.acceptedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Skip to Accepted (Test)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ]
            else if (_tripStatus == 'accepted') ...[
              // Navigation and Call Fields
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionField(
                      'Navigate to Pickup',
                      'Get directions to pickup location',
                      Icons.navigation,
                      AppColors.blueStart,
                      () => _navigateToLocation(_currentTrip.pickupLat, _currentTrip.pickupLng, _currentTrip.pickupAddress),
                    ),
                    const SizedBox(height: 12),
                    _buildActionField(
                      'Call Rider',
                      'Contact the rider directly',
                      Icons.call,
                      AppColors.pendingColor,
                      _callRider,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                'Start Trip',
                Icons.play_arrow,
                AppColors.acceptedColor,
                _startTrip,
                isFullWidth: true,
              ),
            ] else if (_tripStatus == 'started') ...[
              // Navigation and Call Fields for Started Trip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip in Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionField(
                      'Navigate to Drop',
                      'Get directions to drop location',
                      Icons.navigation,
                      AppColors.blueStart,
                      () => _navigateToLocation(_currentTrip.dropLat, _currentTrip.dropLng, _currentTrip.dropAddress),
                    ),
                    const SizedBox(height: 12),
                    _buildActionField(
                      'Call Rider',
                      'Contact the rider if needed',
                      Icons.call,
                      AppColors.pendingColor,
                      _callRider,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                'Complete Trip',
                Icons.check_circle,
                AppColors.acceptedColor,
                _completeTrip,
                isFullWidth: true,
              ),
            ] else if (_tripStatus == 'completed') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.acceptedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.acceptedColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.acceptedColor, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Trip Completed Successfully!',
                      style: TextStyle(
                        color: AppColors.acceptedColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trip completed successfully! Check completed trips for details.',
                      style: TextStyle(
                        color: AppColors.grayText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                'Back to Home',
                Icons.home,
                AppColors.iconBg,
                () => Navigator.pop(context, 'completed'),
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String title, String address) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText)),
              Text(address, style: TextStyle(color: AppColors.grayText, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText)),
        Text(value, style: TextStyle(color: AppColors.grayText, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed, {bool isFullWidth = false}) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_tripStatus) {
      case 'pending': return AppColors.pendingColor;
      case 'accepted': return AppColors.blueStart;
      case 'started': return AppColors.acceptedColor;
      case 'completed': return AppColors.acceptedColor;
      default: return AppColors.grayText;
    }
  }

  IconData _getStatusIcon() {
    switch (_tripStatus) {
      case 'pending': return Icons.hourglass_empty;
      case 'accepted': return Icons.check_circle;
      case 'started': return Icons.play_circle;
      case 'completed': return Icons.check_circle;
      default: return Icons.radio_button_unchecked;
    }
  }

  String _getStatusText() {
    switch (_tripStatus) {
      case 'pending': return 'Pending Approval';
      case 'accepted': return 'Trip Accepted';
      case 'started': return 'Trip In Progress';
      case 'completed': return 'Trip Completed';
      default: return 'Available';
    }
  }

  Widget _buildActionField(String title, String subtitle, IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.grayText,
            ),
          ],
        ),
      ),
    );
  }
}