import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../services/local_storage_service.dart';
import '../theme/colors.dart';
import 'personal_details_screen.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final Driver driver;

  const ProfileUpdateScreen({super.key, required this.driver});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _localStorageService = LocalStorageService();
  late Driver _driver;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    _driver = widget.driver;
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = _driver.name;
    _phoneController.text = _driver.phone;
    _vehicleNumberController.text = _driver.vehicleNumber;
    _emailController.text = _driver.email ?? '';
    _selectedVehicleType = _driver.vehicleType;
  }

  Future<void> _updateProfileAndContinue() async {
    final updatedDriver = _driver.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      vehicleNumber: _vehicleNumberController.text.trim(),
      email: _emailController.text.trim(),
      vehicleType: _selectedVehicleType ?? _driver.vehicleType,
    );

    await _localStorageService.saveDriver(updatedDriver);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PersonalDetailsScreen(driver: updatedDriver)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Update Profile'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.grayText,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome Back!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_driver.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _driver.status,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please update your profile information',
                      style: TextStyle(
                        color: AppColors.grayText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

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
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (Optional)',
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
                      'Vehicle Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedVehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 16),
                    _buildInfoRow('Vehicle Model', _driver.vehicleModel),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // KYC Documents Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KYC Documents',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDocumentCard('License Image', _driver.licenseImageUrl != null),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDocumentCard('Aadhaar Image', _driver.aadhaarImageUrl != null),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfileAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.acceptedColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Personal Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: AppColors.grayText),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not provided',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String title, bool isUploaded) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUploaded ? AppColors.acceptedColor.withOpacity(0.1) : AppColors.grayText.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUploaded ? AppColors.acceptedColor : AppColors.grayText,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            color: isUploaded ? AppColors.acceptedColor : AppColors.grayText,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isUploaded ? AppColors.acceptedColor : AppColors.grayText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            isUploaded ? 'Uploaded' : 'Pending',
            style: TextStyle(
              fontSize: 10,
              color: isUploaded ? AppColors.acceptedColor : AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'APPROVED': return AppColors.acceptedColor;
      case 'PENDING': return AppColors.pendingColor;
      case 'REJECTED': return AppColors.rejectedColor;
      case 'SUSPENDED': return AppColors.rejectedColor;
      default: return AppColors.grayText;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }
}