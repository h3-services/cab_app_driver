class Driver {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final String aadhaarNumber;
  final String vehicleType;
  final String vehicleNumber;
  final String vehicleModel;
  final String status; // pending, approved, rejected
  final bool isAvailable;
  final bool kycCompleted;
  final double? latitude;
  final double? longitude;
  final String? profileImageUrl;
  final String? licenseImageUrl;
  final String? aadhaarImageUrl;
  final double walletBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.aadhaarNumber,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.vehicleModel,
    this.status = 'pending',
    this.isAvailable = false,
    this.kycCompleted = false,
    this.latitude,
    this.longitude,
    this.profileImageUrl,
    this.licenseImageUrl,
    this.aadhaarImageUrl,
    this.walletBalance = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      aadhaarNumber: map['aadhaarNumber'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      vehicleModel: map['vehicleModel'] ?? '',
      status: map['status'] ?? 'pending',
      isAvailable: map['isAvailable'] ?? false,
      kycCompleted: map['kycCompleted'] ?? false,
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      profileImageUrl: map['profileImageUrl'],
      licenseImageUrl: map['licenseImageUrl'],
      aadhaarImageUrl: map['aadhaarImageUrl'],
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'aadhaarNumber': aadhaarNumber,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'vehicleModel': vehicleModel,
      'status': status,
      'isAvailable': isAvailable,
      'kycCompleted': kycCompleted,
      'latitude': latitude,
      'longitude': longitude,
      'profileImageUrl': profileImageUrl,
      'licenseImageUrl': licenseImageUrl,
      'aadhaarImageUrl': aadhaarImageUrl,
      'walletBalance': walletBalance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Driver copyWith({
    String? name,
    String? email,
    String? phone,
    String? licenseNumber,
    String? aadhaarNumber,
    String? vehicleType,
    String? vehicleNumber,
    String? vehicleModel,
    String? status,
    bool? isAvailable,
    bool? kycCompleted,
    double? latitude,
    double? longitude,
    String? profileImageUrl,
    String? licenseImageUrl,
    String? aadhaarImageUrl,
    double? walletBalance,
  }) {
    return Driver(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      kycCompleted: kycCompleted ?? this.kycCompleted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      licenseImageUrl: licenseImageUrl ?? this.licenseImageUrl,
      aadhaarImageUrl: aadhaarImageUrl ?? this.aadhaarImageUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}