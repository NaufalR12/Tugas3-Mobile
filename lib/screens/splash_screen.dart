import 'package:flutter/material.dart';
import '../database/session_manager.dart';
import 'login_page.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a small delay to ensure Flutter is fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkLoginStatus();
    });
  }

  _checkLoginStatus() async {
    try {
      final isLoggedIn = await SessionManager.isLoggedIn();

      if (mounted) {
        if (isLoggedIn) {
          // Navigate to MainScreen instead of HomePage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          // Navigate to login page if user is not logged in
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
      // Fallback to login page on error
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.black),
            const SizedBox(height: 24),
            const Text(
              "Tugas 3",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
