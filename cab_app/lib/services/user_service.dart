import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/driver_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DriverService _driverService = DriverService();

  Future<bool> isUserRegistered(String uid) async {
    try {
      final driver = await _driverService.getDriverById(uid);
      return driver != null;
    } catch (e) {
      print('Error checking user registration: $e');
      return false;
    }
  }

  Future<void> createUserProfile(User user) async {
    try {
      await _firestore.collection('drivers').doc(user.uid).set({
        'id': user.uid,
        'name': user.displayName ?? 'Driver',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'photoUrl': user.photoURL ?? '',
        'status': 'pending',
        'isAvailable': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      throw e;
    }
  }
}