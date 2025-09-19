import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'onboarding.dart';
import 'home.dart';

class Spachscreen extends StatefulWidget {
  const Spachscreen({super.key});

  @override
  State<Spachscreen> createState() => _SpachscreenState();
}

class _SpachscreenState extends State<Spachscreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay

    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B3E96),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png'),
            const SizedBox(height: 20),
            Image.asset('assets/Vector.png', width: 80, height: 80),
          ],
        ),
      ),
    );
  }
}
