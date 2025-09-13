import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:koru/screens/splash_screen.dart'; // Ensure this import is here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KoruApp());
}

class KoruApp extends StatelessWidget {
  const KoruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koru',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
      ),
      home: const SplashScreen(), // This calls the class from the other file
    );
  }
}