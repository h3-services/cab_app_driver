import 'package:flutter/material.dart';
import '../services/network_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkNetworkOnStart();
  }

  void _checkNetworkOnStart() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Small delay for UI
    if (mounted) {
      NetworkService.checkNetworkAndNavigate(context, onRetry: _checkNetworkOnStart);
    }
  }

  void _handleEmailLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    
    final hasNetwork = await NetworkService.checkNetworkAndNavigate(context, onRetry: _handleEmailLogin);
    if (hasNetwork) {
      Navigator.pushReplacementNamed(context, '/driverHome');
    }
  }

  void _handleGoogleLogin() async {
    final hasNetwork = await NetworkService.checkNetworkAndNavigate(context, onRetry: _handleGoogleLogin);
    if (hasNetwork) {
      Navigator.pushReplacementNamed(context, '/driverHome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Driver Login',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _handleEmailLogin,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Login'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleGoogleLogin,
                      icon: const Icon(Icons.g_mobiledata, size: 32),
                      label: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('Sign in with Google'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
