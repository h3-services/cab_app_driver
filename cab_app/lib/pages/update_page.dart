import 'package:flutter/material.dart';
import '../services/version_control_service.dart';
import '../theme/colors.dart';

void main() {
  runApp(MaterialApp(
    home: const UpdatePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> with TickerProviderStateMixin {
  final VersionControlService _versionService = VersionControlService(
    minimumRequiredVersion: '1.0.0',
    apiEndpoint: 'https://h3-services.github.io/versionController/cab_app_version.json',
  );
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _currentVersion = '';
  String _newVersion = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    await _versionService.initialize();
    setState(() {
      _currentVersion = _versionService.getCurrentVersion() ?? 'Unknown';
      _newVersion = _versionService.getNewVersion() ?? 'Unknown';
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.mainBg, Colors.white.withOpacity(0.9)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Image.asset(
                              'assets/images/logo1.png',
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.system_update,
                                  size: 100,
                                  color: Colors.orange,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Update Required',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Current Version:',
                                  style: TextStyle(
                                    color: AppColors.grayText,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _currentVersion,
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'New Version:',
                                  style: TextStyle(
                                    color: AppColors.grayText,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _newVersion,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'A new version is available with important updates and bug fixes.',
                        style: TextStyle(
                          color: AppColors.grayText,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Update action - no navigation
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Update Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    // Later action - no navigation
                  },
                  child: Text(
                    'Update Later',
                    style: TextStyle(
                      color: AppColors.grayText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}