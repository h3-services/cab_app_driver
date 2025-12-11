import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';

class DriverService {
  static final DriverService _instance = DriverService._internal();
  factory DriverService() => _instance;
  DriverService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Driver?> getDriverByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('drivers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        return Driver.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching driver: $e');
      return null;
    }
  }

  Future<Driver?> getDriverById(String uid) async {
    try {
      final doc = await _firestore.collection('drivers').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Driver.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error fetching driver by ID: $e');
      return null;
    }
  }
}