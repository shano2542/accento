import 'package:accento/frontend/UI/auth/home_screen.dart';
import 'package:accento/frontend/UI/auth/profile_screen.dart';
import 'package:accento/frontend/UI/auth/record_new_voices_screen.dart';
import 'package:accento/frontend/widgets/custom_bottom_navbar.dart';
import 'package:accento/frontend/widgets/custom_button.dart';
import 'package:accento/frontend/widgets/custom_voice_field.dart';
import 'package:accento/utilities/theme.dart';
import 'package:flutter/material.dart';

class SavedVoices extends StatefulWidget {
  const SavedVoices({super.key});

  @override
  State<SavedVoices> createState() => _SavedVoicesState();
}

class _SavedVoicesState extends State<SavedVoices> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      // Ensures the gradient is visible behind the navbar
      bottomNavigationBar: CustomBottomNavBar(
        onListPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SavedVoices(),
            ),
          );
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
            ),
          );
        },
        onMicPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
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
          Container(
            decoration:
                AppGradient.gradientBG, // Gradient applied to the entire screen
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "List of Saved Voices",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColorDark,
                      ),
                    ),
                    const SizedBox(height: 40),
                    CustomVoiceField(selectedVoice: "Jarvis", onPressed: () {}),
                    const SizedBox(height: 10),
                    CustomVoiceField(selectedVoice: "Mark", onPressed: () {}),
                    const SizedBox(height: 10),
                    CustomVoiceField(selectedVoice: "Friday", onPressed: () {}),
                    const SizedBox(height: 10),
                    CustomVoiceField(selectedVoice: "Emma", onPressed: () {}),
                    const SizedBox(height: 50),
                    CustomButton(
                      text: "Record Voice",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecordNewVoice(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}