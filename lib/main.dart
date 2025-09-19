
import 'spach_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oxvnfkcsloottwqqskgs.supabase.co',   // ← your real URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94dm5ma2NzbG9vdHR3cXFza2dzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4MDE2MzQsImV4cCI6MjA3MzM3NzYzNH0.NOCnCW6n1Q5R0PShn6JvzggO6sWl5eA59HyD8UQrsOg',                       // ← your real anon key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bazar App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home:Spachscreen(),
    );
  }
}

