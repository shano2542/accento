
import 'package:accento/frontend/UI/auth/signup_screen.dart';
import 'package:accento/frontend/UI/auth/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  final FirebaseAuth  _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Login user

  void login(){
    setState(() {
      loading = true;
    });

    _auth.signInWithEmailAndPassword(
      email: emailController.text.toString(), 
      password: passwordController.text.toString(),
    ).then((value){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SplashScreen()));
      setState(() {
        loading = false;
      });
    }).onError((error,stackTrace){
      ToastMessage().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double logoWidth = screenWidth * 0.85;
    double logoHeight = screenHeight * 0.38;


    return SafeArea(
      child: Scaffold(
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
                    'assets/images/logo3.png',
                    width: logoWidth,
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                        labelText: 'Password',
                        icon: Icons.remove_red_eye,
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        isPassword: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                    ]
                  ),
                ),  
                  const SizedBox(height: 25),

                  // Login Button
                  CustomButton(
                    text: 'Login',
                    loading: loading,
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        login();
                      }
                      // Navigator.push(context,MaterialPageRoute(builder: (context) => const HomeScreen()),);
                    },
                  ),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const ForgotPasswordScreen()),
                      // );
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
                        },
                        icon: Image.asset(
                          'assets/images/Google.png',
                          width: 40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

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