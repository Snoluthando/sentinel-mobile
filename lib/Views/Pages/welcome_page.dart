import 'package:flutter/material.dart';
import 'package:hello_flutter/Views/Pages/registration_page.dart';
import 'dart:ui';

import 'package:hello_flutter/Views/widget_tree.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/BlackoutKnight.png',
            fit: BoxFit.cover,
          ),

          // Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
            child: Container(
              color: Colors.black.withOpacity(0.4), // dark overlay
            ),
          ),

          // Foreground content (login, register, etc.)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your title/logo here
              const Text(
                'Sentinel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // Login button placeholder
              ElevatedButton(
                onPressed: () {
                  // Navigate to the main app page (WidgetTree)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const WidgetTree()),
                  );

                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),

              // Register button placeholder
              ElevatedButton(
                onPressed: () {
                  // Navigate to the registration page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrationPage()),
                  );
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}