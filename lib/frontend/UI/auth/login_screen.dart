import 'package:accento/frontend/UI/auth/home_screen.dart';
import 'package:accento/frontend/UI/auth/signup_screen.dart';
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

  final FirebaseAuth  _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Login/SignIn user with Email and Password

  void login(){
    setState(() {
      loading = true;
    });

    _auth.signInWithEmailAndPassword(
      email: emailController.text.toString(), 
      password: passwordController.text.toString(),
    ).then((value){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
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

  // Login/SignIn with Google

  Future<void> signInWithGoogle() async{
    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if(googleUser == null){
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

      if(user != null){
        // Check if the user exists in FireStore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if(!userDoc.exists){
          // Save user details in FireStore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'uid': user.uid,
          });
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        ToastMessage().toastMessage('Login Successful');
      }
    }catch (e){
      ToastMessage().toastMessage("e: ${e.toString()}");
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
        resizeToAvoidBottomInset: false,
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
                           signInWithGoogle();
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