import 'package:flutter/material.dart';
import '../models/driver.dart';
import '../theme/colors.dart';
import '../services/local_storage_service.dart';
import 'kyc_upload_screen.dart';
import 'login_screen.dart';

class DriverProfileViewScreen extends StatefulWidget {
  final Driver driver;

  const DriverProfileViewScreen({super.key, required this.driver});

  @override
  State<DriverProfileViewScreen> createState() => _DriverProfileViewScreenState();
}

class _DriverProfileViewScreenState extends State<DriverProfileViewScreen> {
  final _localStorageService = LocalStorageService();

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.grayText)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.rejectedColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await _localStorageService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('My Profile'),
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
                    _buildInfoRow('Name', widget.driver.name),
                    _buildInfoRow('Email', widget.driver.email),
                    _buildInfoRow('Phone', widget.driver.phone),
                    _buildInfoRow('License Number', widget.driver.licenseNumber),
                    _buildInfoRow('Aadhaar Number', widget.driver.aadhaarNumber),
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
                    _buildInfoRow('Vehicle Type', widget.driver.vehicleType),
                    _buildInfoRow('Vehicle Number', widget.driver.vehicleNumber),
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
                      'KYC Documents',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDocumentCard('License Image', widget.driver.licenseImageUrl != null),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDocumentCard('Aadhaar Image', widget.driver.aadhaarImageUrl != null),
                        ),
                      ],
                    ),
                    if (!widget.driver.kycCompleted) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KycUploadScreen(driver: widget.driver),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.acceptedColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Complete KYC'),
                        ),
                      ),
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
                      'Account Stats',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Wallet Balance', '₹${(widget.driver.walletBalance < 0 ? 0.0 : widget.driver.walletBalance).toStringAsFixed(2)}'),
                    _buildInfoRow('Member Since', _formatDate(widget.driver.createdAt)),
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
                      'Account Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.grayText,
                          child: const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        title: Text(
                          widget.driver.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          widget.driver.email ?? 'Driver Account',
                          style: TextStyle(
                            color: AppColors.grayText,
                            fontSize: 14,
                          ),
                        ),
                        trailing: TextButton.icon(
                          onPressed: _showLogoutDialog,
                          icon: Icon(Icons.logout, color: AppColors.rejectedColor, size: 20),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                              color: AppColors.rejectedColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                    ),
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