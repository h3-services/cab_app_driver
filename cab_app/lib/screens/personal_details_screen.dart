import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';
import '../services/local_storage_service.dart';
import '../theme/colors.dart';
import 'kyc_upload_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final Driver? driver;
  final String? userId;
  final String? userName;
  final String? userEmail;

  const PersonalDetailsScreen({
    super.key, 
    this.driver,
    this.userId,
    this.userName,
    this.userEmail,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _localStorageService = LocalStorageService();
  Driver? _driver;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _aadhaarNumberController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _driver = widget.driver;
    _initializeControllers();
  }

  void _initializeControllers() {
    if (_driver != null) {
      _nameController.text = _driver!.name;
      _phoneController.text = _driver!.phone;
      _emailController.text = _driver!.email;
      _licenseNumberController.text = _driver!.licenseNumber;
      _aadhaarNumberController.text = _driver!.aadhaarNumber;
      _vehicleNumberController.text = _driver!.vehicleNumber;
      
      final validTypes = ['SUV', 'Sedan', 'Hatchback'];
      // Force empty strings to null to prevent dropdown assertion error
      final vehicleType = _driver!.vehicleType;
      _selectedVehicleType = (vehicleType != null && 
                            vehicleType.isNotEmpty && 
                            vehicleType != '' &&
                            validTypes.contains(vehicleType)) 
          ? vehicleType 
          : null;
    } else {
      // New user - initialize with Google sign-in data
      _nameController.text = widget.userName ?? '';
      _emailController.text = widget.userEmail ?? '';
    }
  }

  Future<void> _saveData() async {
    final Driver driverToSave;
    
    if (_driver != null) {
      // Existing driver - update
      driverToSave = _driver!.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
        aadhaarNumber: _aadhaarNumberController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim(),
        vehicleType: _selectedVehicleType ?? _driver!.vehicleType,
      );
    } else {
      // New driver - create
      driverToSave = Driver(
        id: widget.userId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        licenseNumber: _licenseNumberController.text.trim(),
        aadhaarNumber: _aadhaarNumberController.text.trim(),
        vehicleNumber: _vehicleNumberController.text.trim(),
        vehicleModel: '', // Will be set later if needed
        vehicleType: _selectedVehicleType ?? 'Sedan',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    // Save to local storage
    await _localStorageService.saveDriver(driverToSave);
    
    // Save to Firestore
    final docId = driverToSave.id?.isNotEmpty == true 
        ? driverToSave.id! 
        : DateTime.now().millisecondsSinceEpoch.toString();
    
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(docId)
        .set({
      'name': driverToSave.name,
      'email': driverToSave.email,
      'phone': driverToSave.phone,
      'license_number': driverToSave.licenseNumber,
      'aadhaar_number': driverToSave.aadhaarNumber,
      'car_type': driverToSave.vehicleType,
      'car_number': driverToSave.vehicleNumber,
      'car_model': driverToSave.vehicleModel,
      'kyc_completed': false,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    
    // Navigate to KYC upload screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => KycUploadScreen(driver: driverToSave)),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Personal Details'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _aadhaarNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Aadhaar Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: (_selectedVehicleType == null || _selectedVehicleType!.isEmpty) ? null : _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select Vehicle Type'),
                      items: ['SUV', 'Sedan', 'Hatchback'].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedVehicleType = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _vehicleNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.acceptedColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save & Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseNumberController.dispose();
    _aadhaarNumberController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }
}