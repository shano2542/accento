import 'package:accento/frontend/UI/auth/home_screen.dart';
import 'package:accento/frontend/UI/auth/profile_screen.dart';
import 'package:accento/frontend/UI/auth/saved_voices_screen.dart';
import 'package:accento/frontend/widgets/custom_bottom_navbar.dart';
import 'package:accento/utilities/theme.dart';
import 'package:flutter/material.dart';

class RecordNewVoice extends StatefulWidget {
  const RecordNewVoice({super.key});

  @override
  State<RecordNewVoice> createState() => _RecordNewVoiceState();
}

class _RecordNewVoiceState extends State<RecordNewVoice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true, // This Ensures the gradient appears behind the navbar and FAB
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
        imagePath: 'assets/images/wave-sound.png',
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