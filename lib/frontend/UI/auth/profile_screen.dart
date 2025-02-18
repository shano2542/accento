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

  // Loading
  bool loading = false;

  @override
  void initState(){
    super.initState();
    _fetchUserData();
  }

  // Fetch the user data from FireStore using the current user's UID
  Future<void> _fetchUserData() async{
    setState(() {
      loading = true;
    });

    User? user = _auth.currentUser;
    if(user != null){
      try{
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();

        setState(() {
          nameController.text = userData['name'] ?? "";
          emailController.text = userData['email'] ?? "";
          loading = false;
        });
      }catch(e){
        ToastMessage().toastMessage("Something went wrong!");
        setState(() {
          loading: false;
        });
      };
    }else{
      setState(() {
        loading: false;
      });
    }
  }


  // Update the user data in Firestore

  Future<void> _updateProfile() async{
    if(_formKey.currentState!.validate()){
      setState(() {
        loading: false;
      });

      User? user = _auth.currentUser;
      if(user != null){
        try{
          await _firestore.collection('users').doc(user.uid).update({
            'name': nameController.text.toString(),
            'email': emailController.text.toString(),
          });
          setState(() {
            loading: false;
          });
          ToastMessage().toastMessage("Succeddfully updated!");
        }catch (e){
          ToastMessage().toastMessage(e.toString());
          setState(() {
            loading: false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     double screenWidth = MediaQuery.of(context).size.width;
    double logoWidth = screenWidth * 0.50;

    return Scaffold(
      extendBody: true,
      // Ensures the gradient is visible behind the navbar
      bottomNavigationBar: CustomBottomNavBar(
        onListPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const SavedVoices(),
          //   ),
          // );
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
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const HomeScreen(),
          //   ),
          // );
        },
      ),
      floatingActionButton: CustomFAB(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const HomeScreen(),
          //   ),
          // );
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
                      child: Column(
                        key: _formKey,
                        children: [
                          CustomInputField(
                            labelText: 'Name',
                            icon: Icons.account_circle,
                            controller: nameController,
                            keyboardType: TextInputType.name,
                            validator: (value) => value == null || value.isEmpty
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
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter your password'
                                : null,
                          ),
                          const SizedBox(height: 15),
                          CustomInputField(
                            labelText: 'Confirm Password',
                            icon: Icons.remove_red_eye,
                            controller: passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please enter your password'
                                : null,
                          ),
                          const SizedBox(height: 25),
                          CustomButton(
                            text: 'Save',
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => const HomeScreen()),
                              // );
                            },
                          ),
                        ],
                      )
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
