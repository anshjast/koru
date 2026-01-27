import 'package:flutter/material.dart';
import 'package:koru/models/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Color analyticsColor = const Color(0xFFBB86FC);
  final Color obsidianBg = const Color(0xFF08080A);
  final Color glassBg = const Color(0xFF121214);

  void _submit() async {
    final auth = AuthService();
    try {
      if (isLogin) {
        await auth.login(_emailController.text, _passwordController.text);
      } else {
        await auth.signUp(_emailController.text, _passwordController.text);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            e.toString().replaceAll(RegExp(r'\[.*?\]'), ''),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: Stack(
        children: [
          Positioned(top: -100, right: -100, child: _buildGlowCircle()),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildGlassForm(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    _buildToggleLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle() => Container(
    width: 300,
    height: 300,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: analyticsColor.withOpacity(0.05),
    ),
  );

  Widget _buildHeader() => Column(
    children: [
      Text(
        "KORU",
        style: TextStyle(
          color: analyticsColor,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: 10,
        ),
      ),
      const Text(
        "SYSTEM ACCESS",
        style: TextStyle(
          color: Colors.white38,
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  Widget _buildGlassForm() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: glassBg,
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    ),
    child: Column(
      children: [
        _buildTextField("EMAIL ADDRESS", _emailController, false, Icons.alternate_email_rounded),
        const SizedBox(height: 20),
        _buildTextField("ACCESS KEY", _passwordController, true, Icons.lock_outline_rounded),
      ],
    ),
  );

  Widget _buildTextField(String label, TextEditingController controller, bool isObscure, IconData icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: analyticsColor.withOpacity(0.5), size: 18),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: analyticsColor),
          ),
        ),
      ),
    ],
  );

  Widget _buildSubmitButton() => GestureDetector(
    onTap: _submit,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: analyticsColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: analyticsColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ],
      ),
      child: Center(
        child: Text(
          isLogin ? "INITIALIZE LOGIN" : "CREATE ACCOUNT",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      ),
    ),
  );

  Widget _buildToggleLink() => TextButton(
    onPressed: () => setState(() => isLogin = !isLogin),
    child: Text(
      isLogin ? "NEW USER? CREATE PROFILE" : "ALREADY ACTIVE? LOGIN",
      style: const TextStyle(
        color: Colors.white24,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}