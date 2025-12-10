import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import '../models/driver.dart';
import '../models/trip.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Driver Registration
  Future<void> registerDriver(Driver driver) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('drivers').doc(currentUserId).set(driver.toMap());
  }

  // Get current driver data
  Future<Driver?> getCurrentDriver() async {
    if (currentUserId == null) return null;
    
    final doc = await _firestore.collection('drivers').doc(currentUserId).get();
    if (doc.exists) {
      return Driver.fromMap(doc.data()!);
    }
    return null;
  }

  // Update driver profile
  Future<void> updateDriver(Driver driver) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('drivers').doc(currentUserId).update(driver.toMap());
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile, String folder) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('drivers/$currentUserId/$folder/$fileName');
    
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Update driver availability
  Future<void> updateAvailability(bool isAvailable) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('drivers').doc(currentUserId).update({
      'isAvailable': isAvailable,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Update driver location
  Future<void> updateLocation(double latitude, double longitude) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('drivers').doc(currentUserId).update({
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Get available trips for driver
  Stream<List<Trip>> getAvailableTrips(String vehicleType) {
    return _firestore
        .collection('trips')
        .where('status', isEqualTo: 'requested')
        .where('vehicleType', isEqualTo: vehicleType)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromMap(doc.data()))
            .toList());
  }

  // Accept a trip
  Future<void> acceptTrip(String tripId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await _firestore.collection('trips').doc(tripId).update({
      'driverId': currentUserId,
      'status': 'accepted',
      'acceptedAt': DateTime.now().toIso8601String(),
    });
  }

  // Start a trip
  Future<void> startTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).update({
      'status': 'started',
      'startedAt': DateTime.now().toIso8601String(),
    });
  }

  // Complete a trip
  Future<void> completeTrip(String tripId, double fare) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    // Update trip status
    await _firestore.collection('trips').doc(tripId).update({
      'status': 'completed',
      'completedAt': DateTime.now().toIso8601String(),
    });

    // Update driver wallet
    final driverDoc = await _firestore.collection('drivers').doc(currentUserId).get();
    if (driverDoc.exists) {
      final currentBalance = (driverDoc.data()!['walletBalance'] ?? 0.0).toDouble();
      await _firestore.collection('drivers').doc(currentUserId).update({
        'walletBalance': currentBalance + fare,
      });
    }

    // Add transaction record
    await _firestore.collection('transactions').add({
      'driverId': currentUserId,
      'tripId': tripId,
      'amount': fare,
      'type': 'trip_earning',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Get driver's trips
  Stream<List<Trip>> getDriverTrips() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('trips')
        .where('driverId', isEqualTo: currentUserId)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromMap(doc.data()))
            .toList());
  }

  // Get current active trip
  Stream<Trip?> getCurrentTrip() {
    if (currentUserId == null) return Stream.value(null);
    
    return _firestore
        .collection('trips')
        .where('driverId', isEqualTo: currentUserId)
        .where('status', whereIn: ['accepted', 'started'])
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty 
            ? Trip.fromMap(snapshot.docs.first.data())
            : null);
  }

  // Get transaction history
  Stream<List<Map<String, dynamic>>> getTransactionHistory() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection('transactions')
        .where('driverId', isEqualTo: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  }
}