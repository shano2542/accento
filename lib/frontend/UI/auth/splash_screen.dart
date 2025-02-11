import 'package:flutter/material.dart';

import '../../../utilities/theme.dart';
import '../firebase_services/splash_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;


  // Timer from splash_services

  SplashServices splashScreen = SplashServices();

  @override
  void initState() {
    super.initState();

    splashScreen.isLogin(context);

    // creating a controller to control the animation
    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    // creating a tween animation for sliding the placeholder from left to right
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // creating after 3 seconds, navigate to HomeScreen
    // Future.delayed(const Duration(seconds: 7), () {
    //   // Navigator.pushReplacement(
    //   //   context,
    //   //   MaterialPageRoute(builder: (context) => const LoginPage()),
    //   // );
    // });
  }

  // disposing the controller to freeup the system resources
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.gradientEnd, AppTheme.gradientStart],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.center,
              // Keeps the image centered vertically
              child: Image.asset(
                'assets/images/logo.png',
                // width: 500,
                // height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
