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
  final String status;
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
  final String? fcmToken;
  final String role;

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
    this.fcmToken,
    this.role = 'driver',
  });

  factory Driver.fromMap(Map<String, dynamic> map) {
    final currentLocation = map['current_location'];
    final docsUrl = map['is_docs_url'] as Map<String, dynamic>?;
    
    return Driver(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      licenseNumber: map['license_no'] ?? '',
      aadhaarNumber: map['aadhaar_number'] ?? '',
      vehicleType: map['car_type'] ?? '',
      vehicleNumber: map['car_register_no'] ?? '',
      vehicleModel: '',
      status: map['status'] ?? 'pending',
      isAvailable: false,
      kycCompleted: map['is_kyc_verified'] ?? false,
      latitude: currentLocation is Map && currentLocation.containsKey('latitude') 
          ? currentLocation['latitude']?.toDouble() 
          : null,
      longitude: currentLocation is Map && currentLocation.containsKey('longitude') 
          ? currentLocation['longitude']?.toDouble() 
          : null,
      profileImageUrl: map['profile_photo_url'],
      licenseImageUrl: docsUrl?['license_url'],
      aadhaarImageUrl: docsUrl?['aadhaar_url'],
      walletBalance: 0.0,
      createdAt: map['createdAt'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt']) 
          : (map['createdAt']?.toDate() ?? DateTime.now()),
      updatedAt: map['updatedAt'] is int 
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt']) 
          : (map['updatedAt']?.toDate() ?? DateTime.now()),
      fcmToken: map['fcm_token'],
      role: map['role'] ?? 'driver',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'license_no': licenseNumber,
      'aadhaar_number': aadhaarNumber,
      'car_type': vehicleType,
      'car_register_no': vehicleNumber,
      'status': status,
      'is_kyc_verified': kycCompleted,
      'current_location': latitude != null && longitude != null 
          ? {'latitude': latitude, 'longitude': longitude} 
          : null,
      'profile_photo_url': profileImageUrl,
      'is_docs_url': {
        'license_url': licenseImageUrl,
        'aadhaar_url': aadhaarImageUrl,
      },
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'fcm_token': fcmToken,
      'role': role,
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
    String? fcmToken,
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
      fcmToken: fcmToken ?? this.fcmToken,
      role: role,
    );
  }
}