import 'dart:io';
import 'package:accento/frontend/UI/auth/home_screen.dart';
import 'package:accento/frontend/UI/auth/login_screen.dart';
import 'package:accento/frontend/UI/auth/saved_voices_screen.dart';
import 'package:accento/frontend/widgets/custom_bottom_navbar.dart';
import 'package:accento/frontend/widgets/custom_button.dart';
import 'package:accento/frontend/widgets/input_fields.dart';
import 'package:accento/utilities/constants.dart';
import 'package:accento/utilities/theme.dart';
import 'package:accento/utilities/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isGoogleUser = false;

  // Form key for validating input
  final _formKey = GlobalKey<FormState>();

  // Controllers for profile fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Loading state
  bool loading = false;

  // Toggle visibility for password fields
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Profile Image
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadImage();
  }

  // Pick Image from phone storage
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final savedImage = await _saveImage(imageFile);
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  Future<File> _saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/profile_pic.png';
    return image.copy(path);
  }

  Future<void> _loadImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/profile_pic.png';
    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  // Fetch the user data from Firestore using the current user's UID
  Future<void> _fetchUserData() async {
    setState(() {
      loading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // DEBUG: Print provider info
        for (var provider in user.providerData) {
          print("Provider ID: ${provider.providerId}");
        }

        // Check if the user logged in via Google
        bool googleLogin = user.providerData
            .any((provider) => provider.providerId == 'google.com');
        setState(() {
          isGoogleUser = googleLogin;
        });

        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();

        setState(() {
          nameController.text = userData['name'] ?? "";
          emailController.text = userData['email'] ?? "";
          // passwordController.text = userData['password'] ?? "";
          loading = false;
        });
      } catch (e) {
        ToastMessage().toastMessage("Something went wrong!");
        setState(() {
          loading = false;
        });
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  // Update the user data in Firestore and Firebase Authentication
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      // Update Firestore data
      User? user = _auth.currentUser;
      // String currentPassword = userData['password'];
      if (user != null) {
        try {
          // Update Authentication Email if changed
          if (emailController.text.trim() != user.email) {
            await user.verifyBeforeUpdateEmail(emailController.text.trim());
          }

          // Update Authentication Password if Provided.
          if (passwordController.text.isNotEmpty &&
              passwordController.text == confirmPasswordController.text) {
            await user.updatePassword(passwordController.text);
          }

          // Update Firestore data
          await _firestore.collection('users').doc(user.uid).update({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            // 'password': passwordController.text.trim(),
          });
          setState(() {
            loading = false;
          });
          ToastMessage().toastMessage("Successfully updated!",
              backgroundColor: Colors.green);

          await _auth.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } catch (e) {
          ToastMessage().toastMessage(e.toString());
          print(e.toString());
          if (mounted) {
            setState(() {
              loading = false;
            });
          }
        }
      }
    }
  }

  // Logout user
  Future<void> _logout() async {
    await _auth.signOut();
    ToastMessage()
        .toastMessage('Logged out successfully', backgroundColor: Colors.green);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double logoWidth = AppSizes.wp(110);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 74,
        automaticallyImplyLeading: false,
        // Logout button on the right Top-side
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 20),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              color: AppTheme.navBgColor,
              iconSize: 34,
            ),
          ),
        ],
      ),
      // Ensures the gradient is visible behind the navbar
      bottomNavigationBar: CustomBottomNavBar(
        onListPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SavedVoices(),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ),
          );
        },
        onMicPressed: () {},
      ),
      floatingActionButton: CustomFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
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
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    0.0, // Add keyboard space
              ),
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(5).copyWith(bottom: 80),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image.asset(
                      //   'assets/images/avtar.png',
                      //   width: logoWidth,
                      //   fit: BoxFit.contain,
                      // ),
                      GestureDetector(
                        onTap: _pickImage, // Tap to select an image
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : const AssetImage('assets/images/avtar.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomInputField(
                                labelText: 'Name',
                                icon: Icons.account_circle,
                                controller: nameController,
                                keyboardType: TextInputType.name,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Please enter your name'
                                        : null,
                              ),
                              const SizedBox(height: 15),
                              CustomInputField(
                                labelText: 'Email',
                                icon: Icons.email,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isGoogleUser,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              // Password field with toggle eye icon
                              CustomInputField(
                                labelText: 'New Password',
                                icon: _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                controller: passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                enabled: !isGoogleUser,
                                isPassword: _obscurePassword,
                                onIconPressed: () {
                                  setState(
                                    () {
                                      _obscurePassword = !_obscurePassword;
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value!.length < 6) {
                                    return 'Password should be at least 6 characters long';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              // Confirm Password field with toggle eye icon
                              CustomInputField(
                                labelText: 'Confirm New Password',
                                icon: _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                controller: confirmPasswordController,
                                keyboardType: TextInputType.visiblePassword,
                                enabled: !isGoogleUser,
                                isPassword: _obscureConfirmPassword,
                                onIconPressed: () {
                                  setState(
                                    () {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    },
                                  );
                                },
                                validator: (value) {
                                  if (value!.length < 6) {
                                    return 'Password should be at least 6 characters long';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          )),
                      const SizedBox(height: 25),
                      CustomButton(
                        text: 'Save',
                        width: AppSizes.wp(150),
                        height: AppSizes.hp(50),
                        loading: loading,
                        onPressed: _updateProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
