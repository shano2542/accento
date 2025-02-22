import 'dart:async';

import 'package:accento/frontend/UI/auth/login_screen.dart';
import 'package:accento/frontend/UI/auth/profile_screen.dart';
import 'package:accento/frontend/UI/auth/saved_voices_screen.dart';
import 'package:accento/frontend/widgets/custom_bottom_navbar.dart';
import 'package:accento/utilities/theme.dart';
import 'package:accento/utilities/toast_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Timer for email verification
  Timer? _timer;
  int clickCount = 0;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    // Optionally, re-check preiodically if needed.
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => _checkEmailVerification());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Check Email Verification
  Future<void> _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // get latest user info
      if (!user.emailVerified) {
        _showEmailVerificationDialog();
      }
    }
  }

  // Show Email Verification Dialog

  void _showEmailVerificationDialog() {
    // prevent multiple dialogs
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
        context: context,
        barrierDismissible: false, // User must interact with the dialog
        builder: (context) => AlertDialog(
              title: const Text("Email Verification Required"),
              content: const Text(
                  "Your email is not verified. Please check your inbox and verify you email. If you haven't received an email, you can resend the verification email."),
              actions: [
                TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.currentUser!
                            .sendEmailVerification();
                        ToastMessage().toastMessage('Verification email sent!');
                      } catch (e) {
                        ToastMessage().toastMessage("e: ${e.toString()}");
                      }
                    },
                    child: const Text("Send")),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    Future.delayed(
                        const Duration(seconds: 5), _checkEmailVerification);
                    setState(() async {
                      clickCount++;
                      if (clickCount == 3) {
                        await _auth.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      }
                    });
                  },
                  child: const Text("Dismiss"),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody:
          true, // This Ensures the gradient appears behind the navbar and FAB
      bottomNavigationBar: CustomBottomNavBar(
        onListPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SavedVoices()),
          );
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
        onMicPressed: () {
          // Handle mic action
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
      ),
      floatingActionButton: CustomFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        },
        icon: Icons.mic,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          // Full-screen gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Screen content
          SafeArea(
            child: Center(
              // child: Text(
              //   'Welcome to AI ACCENTO',
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              child: Image.asset(
                'assets/images/accento.png',
                width: 1080,
                height: 1080,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
