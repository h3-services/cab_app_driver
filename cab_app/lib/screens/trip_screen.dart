import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/trip.dart';
import '../services/driver_service.dart';
import '../theme/colors.dart';

// Remove this main function as TripScreen should be navigated to with a trip parameter
// void main(List<String> args) {
//   runApp(const TripScreen());
// }

class TripScreen extends StatefulWidget {
  final Trip trip;

  const TripScreen({super.key, required this.trip});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final _driverService = DriverService();
  late Trip _trip;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  Future<void> _startTrip() async {
    setState(() => _isLoading = true);
    try {
      await _driverService.startTrip(_trip.id);
      setState(() {
        _trip = Trip(
          id: _trip.id,
          riderId: _trip.riderId,
          driverId: _trip.driverId,
          pickupAddress: _trip.pickupAddress,
          dropAddress: _trip.dropAddress,
          pickupLat: _trip.pickupLat,
          pickupLng: _trip.pickupLng,
          dropLat: _trip.dropLat,
          dropLng: _trip.dropLng,
          vehicleType: _trip.vehicleType,
          fare: _trip.fare,
          status: 'started',
          requestedAt: _trip.requestedAt,
          acceptedAt: _trip.acceptedAt,
          startedAt: DateTime.now(),
          completedAt: _trip.completedAt,
          riderName: _trip.riderName,
          riderPhone: _trip.riderPhone,
          distance: _trip.distance,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip started successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting trip: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeTrip() async {
    setState(() => _isLoading = true);
    try {
      await _driverService.completeTrip(_trip.id, _trip.fare);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip completed successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error completing trip: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openMaps(double lat, double lng, String address) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }

  Future<void> _callRider() async {
    if (_trip.riderPhone != null) {
      final url = 'tel:${_trip.riderPhone}';
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
        title: const Text('Trip Details'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trip Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _trip.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Fare: ₹${_trip.fare.toStringAsFixed(0)}'),
                    if (_trip.distance != null)
                      Text(
                        'Distance: ${_trip.distance!.toStringAsFixed(1)} km',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pickup Location
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: const Text('Pickup Location'),
                subtitle: Text(_trip.pickupAddress),
                trailing: IconButton(
                  icon: const Icon(Icons.navigation),
                  onPressed: () => _openMaps(
                    _trip.pickupLat,
                    _trip.pickupLng,
                    _trip.pickupAddress,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Drop Location
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text('Drop Location'),
                subtitle: Text(_trip.dropAddress),
                trailing: IconButton(
                  icon: const Icon(Icons.navigation),
                  onPressed: () => _openMaps(
                    _trip.dropLat,
                    _trip.dropLng,
                    _trip.dropAddress,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Rider Info
            if (_trip.riderName != null || _trip.riderPhone != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rider Information',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_trip.riderName != null)
                        Text('Name: ${_trip.riderName}'),
                      if (_trip.riderPhone != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Phone: ${_trip.riderPhone}'),
                            IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              onPressed: _callRider,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Action Buttons
            if (_trip.status == 'accepted') ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Start Trip'),
                ),
              ),
            ] else if (_trip.status == 'started') ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeTrip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Complete Trip'),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Trip Timeline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip Timeline',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildTimelineItem('Requested', _trip.requestedAt, true),
                    if (_trip.acceptedAt != null)
                      _buildTimelineItem('Accepted', _trip.acceptedAt!, true),
                    if (_trip.startedAt != null)
                      _buildTimelineItem('Started', _trip.startedAt!, true),
                    if (_trip.completedAt != null)
                      _buildTimelineItem('Completed', _trip.completedAt!, true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_trip.status) {
      case 'requested':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'started':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTimelineItem(String title, DateTime dateTime, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: AppColors.grayText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
