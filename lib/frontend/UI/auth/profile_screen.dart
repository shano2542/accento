import 'package:accento/frontend/UI/auth/home_screen.dart';
import 'package:accento/frontend/UI/auth/login_screen.dart';
import 'package:accento/frontend/UI/auth/saved_voices_screen.dart';
import 'package:accento/frontend/widgets/custom_bottom_navbar.dart';
import 'package:accento/frontend/widgets/custom_button.dart';
import 'package:accento/frontend/widgets/input_fields.dart';
import 'package:accento/utilities/theme.dart';
import 'package:accento/utilities/toast_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form key for validating input
  final _formKey = GlobalKey<FormState>();

  // Controllers for profile fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();

  // Loading
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch the user data from FireStore using the current user's UID
  Future<void> _fetchUserData() async {
    setState(() {
      loading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();

        setState(() {
          nameController.text = userData['name'] ?? "";
          emailController.text = userData['email'] ?? "";
          passwordController.text = userData['password'] ?? "";
          loading = false;
        });
      } catch (e) {
        ToastMessage().toastMessage("Something went wrong!");
        setState(() {
          loading:
          false;
        });
      }
    } else {
      setState(() {
        loading:false;
      });
    }
  }

  // Update the user data in Firestore and Firebase Authentication

  Future<void> _updateProfile() async{
    if(_formKey.currentState!.validate()){
      // If a new password is provided, ensure that the password and confirm password match.
      if(passwordController.text.isNotEmpty && passwordController.text != confirmpasswordController.text){
        ToastMessage().toastMessage('Password do not match!');
        return;
      }
      setState(() {
        loading:
        true;
      });

      User? user = _auth.currentUser;
      if(user != null){
        try{
          // Update Authentication Email if changed
          if(emailController.text.trim() != user.email){
            await user.verifyBeforeUpdateEmail(emailController.text.trim());
          }

          // Update Authentication Password if Provided.
          if(passwordController.text.isNotEmpty){
            await user.updatePassword(passwordController.text);
          }

          // Update Firestore data
          await _firestore.collection('users').doc(user.uid).update({
            'name': nameController.text.toString(),
            'email': emailController.text.toString(),
            'password': passwordController.text.toString(),
          });
          setState(() {
            loading:
            false;
          });
          ToastMessage().toastMessage("Successfully updated!");
        } catch (e) {
          ToastMessage().toastMessage(e.toString());
          setState(() {
            loading:
            false;
          });
        }
      }
    }
  }

  
  // Logout  user
  Future<void> _logout() async{
    await _auth.signOut();
    ToastMessage().toastMessage('Logged out successfully');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double logoWidth = screenWidth * 0.50;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
       // Logout button on the right Top-side
       actions:[
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
        )
       ]
      ),
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
                    Image.asset(
                      'assets/images/avtar.png',
                      width: logoWidth,
                      fit: BoxFit.contain,
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
                            CustomInputField(
                              labelText: 'Password',
                              icon: Icons.remove_red_eye,
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              isPassword: true,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your password'
                                      : null,
                            ),
                            const SizedBox(height: 15),
                            CustomInputField(
                              labelText: 'Confirm Password',
                              icon: Icons.remove_red_eye,
                              controller: confirmpasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              isPassword: true,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Please enter your password'
                                      : null,
                            ),
                          ],
                        )),
                    const SizedBox(height: 25),
                    CustomButton(
                      text: 'Save',
                      loading: loading,
                      onPressed: () {
                        _updateProfile();
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
