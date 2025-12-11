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
        
        return Driver(
          id: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? email,
          phone: data['phone'] ?? '',
          licenseNumber: data['licenseNumber'] ?? '',
          aadhaarNumber: data['aadhaarNumber'] ?? '',
          vehicleType: data['vehicleType'] ?? '',
          vehicleNumber: data['vehicleNumber'] ?? '',
          vehicleModel: data['vehicleModel'] ?? '',
          status: data['status'] ?? 'pending',
          isAvailable: data['isAvailable'] ?? false,
          walletBalance: (data['walletBalance'] ?? 0.0).toDouble(),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('Error fetching driver: $e');
      return null;
    }
  }
}