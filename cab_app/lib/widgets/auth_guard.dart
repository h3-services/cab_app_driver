import 'package:flutter/material.dart';
import '../services/auth_middleware.dart';
import '../screens/login_screen.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final String? requiredRole;

  const AuthGuard({
    super.key,
    required this.child,
    this.requiredRole = 'driver',
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final AuthMiddleware _authMiddleware = AuthMiddleware();
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authResult = await _authMiddleware.checkAuthStatus();
    
    setState(() {
      _isLoading = false;
      _isAuthenticated = authResult['isAuthenticated'] ?? false;
      _errorMessage = authResult['error'];
    });

    if (!_isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Authentication required',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}