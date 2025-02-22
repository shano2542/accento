import 'package:accento/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../utilities/theme.dart';
import '../../../utilities/toast_message.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_fields.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    setState(() {
      loading = true;
    });
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passwordController.text.toString(),
      );
      // Get user ID

      String uid = userCredential.user!.uid;

      // Store additional data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.toString(),
        'email': emailController.text.toString(),
        'password': passwordController.text.toString(),
        'uid': uid,
      });

      setState(() {
        loading = false;
      });
      // Navigate to Login Screen
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (error) {
      ToastMessage().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double logoWidth = AppSizes.wp(333);
    double logoHeight = AppSizes.hp(199);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: DecoratedBox(
          decoration: AppGradient.gradientBG,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo with dynamic size
                  Image.asset(
                    'assets/images/logo2.png',
                    width: logoWidth,
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),

                  Text(
                    "Create Account",
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: AppSizes.sp(24),
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Form(
                      key: _formKey,
                      child: Column(children: [
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
                        // Email Input Field
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
                            }),
                        const SizedBox(height: 15),

                        // Password Input Field
                        CustomInputField(
                          labelText: 'New Password',
                          icon: _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          isPassword: _obscurePassword,
                          onIconPressed: () {
                            setState(
                              () {
                                _obscurePassword = !_obscurePassword;
                              },
                            );
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            } else if (value.length < 6) {
                              return 'Password should be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                      ])),
                  const SizedBox(height: 25),

                  // Register Button
                  CustomButton(
                    text: 'Register',
                    loading: loading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _register();
                        // Navigator.push(context,MaterialPageRoute(builder: (context) => const LoginScreen()),);
                      }
                    },
                  ),

                  const SizedBox(height: 100),

                  // Login Link
                  TextButton(
                    onPressed: () {
                      // Handle Login logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account?",
                        style: TextStyle(
                            color: AppTheme.textColorDark,
                            fontWeight: FontWeight.w200),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
