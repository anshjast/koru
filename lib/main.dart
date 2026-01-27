import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:koru/screens/auth_screen.dart';
import 'package:koru/screens/dashboard_screen.dart';
import 'package:koru/screens/profile_setup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'KORU',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (authSnapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(authSnapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  var data = userSnapshot.data!.data() as Map<String, dynamic>;
                  if (data['setupComplete'] == true) {
                    return const DashboardScreen();
                  }
                }

                return const ProfileSetupScreen();
              },
            );
          }
          return const AuthScreen();
        },
      ),
    );
  }
}