import 'package:accento/frontend/widgets/custom_button.dart';
import 'package:accento/frontend/widgets/input_fields.dart';
import 'package:accento/utilities/theme.dart';
import 'package:accento/utilities/toast_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
 bool loading = false;

 // Function to send password reset email
 Future<void> resetPassword() async{
  if(_formKey.currentState!.validate()){
    setState((){
      loading = true;
    });
    try{
      await _auth.sendPasswordResetEmail(
        email: emailController.text.toString(),
      );
      ToastMessage().toastMessage("Password reset email sent!");
      Navigator.pop(context);
    }catch(error){
      ToastMessage().toastMessage(error.toString());
      setState((){
        loading = false;
      });
    }
  }
 }
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
                            if(value == null || value.isEmpty){
                              return "Please enter your email";
                            }else if(!RegExp(
                               r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$'
                            ).hasMatch(value)){
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        // Forget Button
                        CustomButton(
                          text: 'Forget Password',
                          onPressed: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()),);
                            resetPassword();
                          },
                        ),
                      ],
                    )
                  )
                ],
              ),
            ),
          ),
        ),        
      ),
    );
  }
}