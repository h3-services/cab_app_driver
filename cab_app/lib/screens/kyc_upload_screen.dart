import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../services/local_storage_service.dart';
import '../theme/colors.dart';
import 'driver_home_screen.dart';

class KycUploadScreen extends StatefulWidget {
  final Driver driver;

  const KycUploadScreen({super.key, required this.driver});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  final _localStorageService = LocalStorageService();
  late Driver _driver;
  
  bool _licenseUploaded = false;
  bool _aadhaarUploaded = false;
  bool _profilePhotoUploaded = false;

  @override
  void initState() {
    super.initState();
    _driver = widget.driver;
    _licenseUploaded = _driver.licenseImageUrl != null;
    _aadhaarUploaded = _driver.aadhaarImageUrl != null;
    _profilePhotoUploaded = _driver.profileImageUrl != null;
  }

  Future<void> _uploadLicense() async {
    // Simulate image upload
    setState(() => _licenseUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('License image uploaded successfully!')),
    );
  }

  Future<void> _uploadAadhaar() async {
    // Simulate image upload
    setState(() => _aadhaarUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aadhaar image uploaded successfully!')),
    );
  }

  Future<void> _uploadProfilePhoto() async {
    // Simulate image upload
    setState(() => _profilePhotoUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo uploaded successfully!')),
    );
  }

  Future<void> _completeKyc() async {
    final updatedDriver = _driver.copyWith(
      licenseImageUrl: _licenseUploaded ? 'license_image_url' : null,
      aadhaarImageUrl: _aadhaarUploaded ? 'aadhaar_image_url' : null,
      profileImageUrl: _profilePhotoUploaded ? 'profile_image_url' : null,
      kycCompleted: true,
    );

    await _localStorageService.saveDriver(updatedDriver);
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
      (route) => false,
    );
  }

  Future<void> _skipKyc() async {
    final updatedDriver = _driver.copyWith(
      kycCompleted: false,
    );

    await _localStorageService.saveDriver(updatedDriver);
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DriverHomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('KYC Upload'),
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
                    Icon(
                      Icons.verified_user,
                      size: 60,
                      color: AppColors.iconBg,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload KYC Documents',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please upload the required documents to complete your profile',
                      style: TextStyle(
                        color: AppColors.grayText,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
                      'Required Documents',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildUploadCard(
                      'License Image',
                      'Upload your driving license',
                      _licenseUploaded,
                      _uploadLicense,
                      Icons.credit_card,
                    ),
                    const SizedBox(height: 12),
                    _buildUploadCard(
                      'Aadhaar Image',
                      'Upload your Aadhaar card',
                      _aadhaarUploaded,
                      _uploadAadhaar,
                      Icons.badge,
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
                      'Optional',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildUploadCard(
                      'Profile Photo',
                      'Upload your profile picture',
                      _profilePhotoUploaded,
                      _uploadProfilePhoto,
                      Icons.person,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_licenseUploaded && _aadhaarUploaded) ? _completeKyc : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.acceptedColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _skipKyc,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.grayText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Skip for Now',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(String title, String subtitle, bool isUploaded, VoidCallback onTap, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: isUploaded ? AppColors.acceptedColor.withOpacity(0.1) : AppColors.grayText.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? AppColors.acceptedColor : AppColors.grayText,
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isUploaded ? AppColors.acceptedColor : AppColors.grayText,
          size: 32,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isUploaded ? AppColors.acceptedColor : AppColors.primaryText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppColors.grayText,
            fontSize: 12,
          ),
        ),
        trailing: isUploaded
            ? Icon(Icons.check_circle, color: AppColors.acceptedColor)
            : Icon(Icons.upload, color: AppColors.grayText),
        onTap: isUploaded ? null : onTap,
      ),
    );
  }
}