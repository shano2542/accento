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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void Register() async{
    setState(() {
      loading = true;
    });
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.toString(), 
        password: passwordController.text.toString(),
      );
      // Get user ID

      String uid = userCredential.user!.uid;

      // Store additional data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameController.text.toString(),
        'email': emailController.text.toString(),
        'uid': uid,
      });

      setState(() {
        loading = false;
      });
    }catch(error){
      ToastMessage().toastMessage(error.toString());
      setState(() {
        loading: false;
      });

    }
    
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
                    'assets/images/logo4.png',
                    width: logoWidth,
                    height: logoHeight,
                    fit: BoxFit.contain,
                  ),
                  // const SizedBox(height: 5),
              Form(
                key: _formKey,
                child: Column(
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
                )
              ),
                  const SizedBox(height: 25),

                  // Register Button
                  CustomButton(
                    text: 'Register',
                    loading: loading,
                    onPressed: () {
                      if(_formKey.currentState!.validate()){

                        Register();
                        // Navigator.push(context,MaterialPageRoute(builder: (context) => const LoginScreen()),);
                      }
                    },
                  ),

                  const SizedBox(height: 100),

                  // Register Link
                  TextButton(
                    onPressed: () {
                      // Handle registration logic
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