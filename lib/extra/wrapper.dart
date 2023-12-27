import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../account/user/login.dart';
import '../firebase/auth_service.dart';
import '../screens/homepage.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return _showSplash
        ? _buildSplashScreen()
        : StreamBuilder<User?>(
            stream: authService.user,
            builder: (_, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                final User? user = snapshot.data;
                return user == null ? const LoginPage() : const HomePage();
              } else {
                return _buildSplashScreen();
              }
            },
          );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/depthblue.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
