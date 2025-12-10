import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/driver.dart';
import '../services/driver_service.dart';
import '../theme/colors.dart';
import 'driver_home_screen.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() => _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _driverService = DriverService();
  final _imagePicker = ImagePicker();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  
  String _selectedVehicleType = 'Sedan';
  File? _profileImage;
  File? _licenseImage;
  File? _aadhaarImage;
  bool _isLoading = false;

  final List<String> _vehicleTypes = ['Sedan', 'SUV', 'Hatchback', 'Auto'];

  Future<void> _pickImage(String type) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'profile':
            _profileImage = File(pickedFile.path);
            break;
          case 'license':
            _licenseImage = File(pickedFile.path);
            break;
          case 'aadhaar':
            _aadhaarImage = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (_licenseImage == null || _aadhaarImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload license and Aadhaar images')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? profileImageUrl;
      if (_profileImage != null) {
        profileImageUrl = await _driverService.uploadImage(_profileImage!, 'profile');
      }

      final licenseImageUrl = await _driverService.uploadImage(_licenseImage!, 'license');
      final aadhaarImageUrl = await _driverService.uploadImage(_aadhaarImage!, 'aadhaar');

      final driver = Driver(
        id: _driverService.currentUserId!,
        name: _nameController.text.trim(),
        email: '', // Will be set from auth
        phone: _phoneController.text.trim(),
        licenseNumber: _licenseController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
        vehicleType: _selectedVehicleType,
        vehicleNumber: _vehicleNumberController.text.trim(),
        vehicleModel: _vehicleModelController.text.trim(),
        profileImageUrl: profileImageUrl,
        licenseImageUrl: licenseImageUrl,
        aadhaarImageUrl: aadhaarImageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _driverService.registerDriver(driver);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration submitted! Wait for admin approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Driver Registration'),
        backgroundColor: AppColors.iconBg,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              GestureDetector(
                onTap: () => _pickImage('profile'),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.grayText,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Personal Info
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true ? 'Enter phone' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _licenseController,
                decoration: const InputDecoration(
                  labelText: 'License Number *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Enter license number' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _aadhaarController,
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Enter Aadhaar number' : null,
              ),
              const SizedBox(height: 16),

              // Vehicle Info
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type *',
                  border: OutlineInputBorder(),
                ),
                items: _vehicleTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) => setState(() => _selectedVehicleType = value!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Enter vehicle number' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _vehicleModelController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Model *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Enter vehicle model' : null,
              ),
              const SizedBox(height: 20),

              // Document Upload
              _buildDocumentUpload('License Photo *', _licenseImage, () => _pickImage('license')),
              const SizedBox(height: 16),
              _buildDocumentUpload('Aadhaar Photo *', _aadhaarImage, () => _pickImage('aadhaar')),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.iconBg,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Registration'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUpload(String title, File? image, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayText),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 40, color: AppColors.grayText),
                  const SizedBox(height: 8),
                  Text(title, style: TextStyle(color: AppColors.grayText)),
                ],
              ),
      ),
    );
  }
}