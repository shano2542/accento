import 'package:flutter/material.dart';

import '../../utilities/theme.dart';


class CustomInputField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.labelText,
    this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 323,
      height: 60,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        obscuringCharacter: "*",
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          color: AppTheme.textColorLight, // Ensure text is the right color
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: 14,
            // ignore: deprecated_member_use
            color: AppTheme.textColorLight.withOpacity(0.7),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: AppTheme.transparentColor, // Adjust this color as needed
          prefixIcon: null,
          suffixIcon: Icon(
            icon,
            color: AppTheme.primaryColor, // Icon color
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12), // Adjusted padding
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.inputFieldColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}