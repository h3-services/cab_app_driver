class Trip {
  final String id;
  final String riderId;
  final String? driverId;
  final String pickupAddress;
  final String dropAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String vehicleType;
  final double fare;
  final String status; // requested, accepted, started, completed, cancelled
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? riderName;
  final String? riderPhone;
  final double? distance;
  final int? startKm;
  final int? endKm;
  final double? tollAmount;
  final double? driverAllowance;
  final double? kmRate;
  final double? walletFeeDeducted;

  Trip({
    required this.id,
    required this.riderId,
    this.driverId,
    required this.pickupAddress,
    required this.dropAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.vehicleType,
    required this.fare,
    this.status = 'requested',
    required this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.riderName,
    this.riderPhone,
    this.distance,
    this.startKm,
    this.endKm,
    this.tollAmount,
    this.driverAllowance,
    this.kmRate,
    this.walletFeeDeducted,
  });

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'] ?? '',
      riderId: map['riderId'] ?? '',
      driverId: map['driverId'],
      pickupAddress: map['pickupAddress'] ?? '',
      dropAddress: map['dropAddress'] ?? '',
      pickupLat: (map['pickupLat'] ?? 0.0).toDouble(),
      pickupLng: (map['pickupLng'] ?? 0.0).toDouble(),
      dropLat: (map['dropLat'] ?? 0.0).toDouble(),
      dropLng: (map['dropLng'] ?? 0.0).toDouble(),
      vehicleType: map['vehicleType'] ?? '',
      fare: (map['fare'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'requested',
      requestedAt: DateTime.parse(map['requestedAt']),
      acceptedAt: map['acceptedAt'] != null ? DateTime.parse(map['acceptedAt']) : null,
      startedAt: map['startedAt'] != null ? DateTime.parse(map['startedAt']) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
      riderName: map['riderName'],
      riderPhone: map['riderPhone'],
      distance: map['distance']?.toDouble(),
      startKm: map['startKm']?.toInt(),
      endKm: map['endKm']?.toInt(),
      tollAmount: map['tollAmount']?.toDouble(),
      driverAllowance: map['driverAllowance']?.toDouble(),
      kmRate: map['kmRate']?.toDouble(),
      walletFeeDeducted: map['walletFeeDeducted']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'riderId': riderId,
      'driverId': driverId,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'vehicleType': vehicleType,
      'fare': fare,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'riderName': riderName,
      'riderPhone': riderPhone,
      'distance': distance,
      'startKm': startKm,
      'endKm': endKm,
      'tollAmount': tollAmount,
      'driverAllowance': driverAllowance,
      'kmRate': kmRate,
      'walletFeeDeducted': walletFeeDeducted,
    };
  }
}