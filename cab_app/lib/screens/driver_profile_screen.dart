import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../services/local_storage_service.dart';
import '../theme/colors.dart';

class DriverProfileScreen extends StatefulWidget {
  final Driver driver;

  const DriverProfileScreen({super.key, required this.driver});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _localStorageService = LocalStorageService();
  late Driver _driver;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleNumberController = TextEditingController();


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
  }

  Future<void> _updateProfile() async {
    final updatedDriver = _driver.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      vehicleNumber: _vehicleNumberController.text.trim(),

    );

    await _localStorageService.saveDriver(updatedDriver);
    setState(() {
      _driver = updatedDriver;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
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
                      _driver.name,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Trips', '45'),
                        _buildStatItem('Rating', '4.7⭐'),
                        _buildStatItem('Earnings', '₹15750'),
                      ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(_isEditing ? Icons.close : Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditing = !_isEditing;
                              if (!_isEditing) {
                                _initializeControllers();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isEditing) ...[
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
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.iconBg,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ] else ...[
                      _buildInfoRow('Name', _driver.name),
                      _buildInfoRow('Email', _driver.email),
                      _buildInfoRow('Phone', _driver.phone),
                      _buildInfoRow('License Number', _driver.licenseNumber),
                      _buildInfoRow('Aadhaar Number', _driver.aadhaarNumber),
                    ],
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
                    if (_isEditing) ...[
                      TextFormField(
                        controller: _vehicleNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Number',
                          border: OutlineInputBorder(),
                        ),
                      ),

                    ] else ...[
                      _buildInfoRow('Vehicle Type', _driver.vehicleType),
                      _buildInfoRow('Vehicle Number', _driver.vehicleNumber),
                    ],
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
            const SizedBox(height: 16),

            // Performance Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Stats',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Total Trips', '45'),
                    _buildInfoRow('Total Earnings', '₹15750.00'),
                    _buildInfoRow('Wallet Balance', '₹${_driver.walletBalance.toStringAsFixed(2)}'),
                    _buildInfoRow('Member Since', _formatDate(_driver.createdAt)),
                  ],
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: AppColors.grayText, fontSize: 12),
        ),
      ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}