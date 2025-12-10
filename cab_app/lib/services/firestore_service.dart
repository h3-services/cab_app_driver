import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getDriverData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('drivers').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['email'] = user.email ?? '';
        return data;
      }
      return null;
    } catch (e) {
      throw 'Failed to get driver data: $e';
    }
  }

  Future<void> createDriverProfile(Map<String, dynamic> driverData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No authenticated user';

      await _firestore.collection('drivers').doc(user.uid).set({
        ...driverData,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to create driver profile: $e';
    }
  }

  Future<void> updateDriverLocation(double latitude, double longitude) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('drivers').doc(user.uid).update({
        'latitude': latitude,
        'longitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update location: $e';
    }
  }

  Future<void> updateDriverAvailability(bool isAvailable) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('drivers').doc(user.uid).update({
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update availability: $e';
    }
  }
}