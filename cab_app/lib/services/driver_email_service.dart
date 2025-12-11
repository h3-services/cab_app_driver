import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';

class DriverEmailService {
  static final DriverEmailService _instance = DriverEmailService._internal();
  factory DriverEmailService() => _instance;
  DriverEmailService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getAllDriverEmails() async {
    try {
      final querySnapshot = await _firestore
          .collection('drivers')
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['email'] as String? ?? '')
          .where((email) => email.isNotEmpty)
          .toList();
    } catch (e) {
      print('Error fetching driver emails: $e');
      return [];
    }
  }

  Future<Driver?> getDriverByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('drivers')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final driverDoc = querySnapshot.docs.first;
      final driverData = driverDoc.data();
      return Driver.fromMap({...driverData, 'id': driverDoc.id});
    } catch (e) {
      print('Error fetching driver by email: $e');
      return null;
    }
  }
}