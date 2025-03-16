import 'package:accento/frontend/UI/auth/forgot_password.dart';
import 'package:accento/frontend/UI/auth/home_screen.dart';
import 'package:accento/frontend/UI/auth/signup_screen.dart';
import 'package:accento/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../utilities/theme.dart';
import '../../../utilities/toast_message.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_fields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Login/SignIn user with Email and Password

  void login() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    _auth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((value) {
      setState(() {
        loading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
      ToastMessage()
          .toastMessage("Login Successfully!", backgroundColor: Colors.green);
    }).catchError((error) {
      setState(() {
        loading = false;
      });

      ToastMessage().toastMessage(error.toString());
    });
  }

  // Login/SignIn with Google

  Future<void> signInWithGoogle() async {
    try {
      // Ensure the previous account is signed out
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        ToastMessage().toastMessage('Google Sign-In canceled');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if the user exists in FireStore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Save user details in FireStore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'name': user.displayName,
            'email': user.email,
            'uid': user.uid,
          });
        }

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
        ToastMessage()
            .toastMessage('Login Successfully!', backgroundColor: Colors.green);
      }
    } catch (e) {
      ToastMessage().toastMessage("e: ${e.toString()}");
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
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Welcome!\n",
                          style: TextStyle(
                            fontSize: AppSizes.sp(24),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navBgColor,
                          ),
                        ),
                        TextSpan(
                          text: "AI ACCENTO",
                          style: TextStyle(
                            fontSize: AppSizes.sp(24),
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navBgColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,
                    child: Column(children: [
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
                    ]),
                  ),
                  const SizedBox(height: 25),

                  // Login Button
                  CustomButton(
                    text: 'Login',
                    loading: loading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                  ),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w300,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Google Login
                  Column(
                    children: [
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: AppTheme.textColorDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 0),
                      IconButton(
                        onPressed: () {
                          // Handle Google login logic
                          signInWithGoogle();
                        },
                        icon: Image.asset(
                          'assets/images/Google.png',
                          width: 40,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.wp(20)),

                  // Register Link
                  TextButton(
                    onPressed: () {
                      // Handle registration logic
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account?",
                        style: TextStyle(
                            color: AppTheme.textColorDark,
                            fontWeight: FontWeight.w200),
                        children: [
                          TextSpan(
                            text: 'Register',
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
