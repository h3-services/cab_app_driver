import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';
import 'pages/splash_page.dart';
import 'screens/driver_home_screen.dart';
import 'theme/colors.dart';
import 'widgets/network_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Force logout to show login screen
  try {
    await FirebaseAuth.instance.signOut();
    print('User signed out successfully');
  } catch (e) {
    print('Sign out error: $e');
  }
  
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cab Driver Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.iconBg),
        useMaterial3: true,
      ),
      home: NetworkMonitor(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashPage();
            }
            if (snapshot.hasData) {
              return const DriverHomeScreen();
            }
            return const SplashPage();
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}