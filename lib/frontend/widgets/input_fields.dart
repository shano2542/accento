import 'package:accento/utilities/constants.dart';
import 'package:flutter/material.dart';

import '../../utilities/theme.dart';

class CustomInputField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onIconPressed;
  final bool? enabled;

  const CustomInputField({
    super.key,
    required this.labelText,
    this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isPassword = false,
    this.enabled,
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.wp(323),
      height: AppSizes.hp(60),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        obscuringCharacter: "*",
        keyboardType: keyboardType,
        enabled: enabled,
        validator: validator,
        style: TextStyle(
          color: AppTheme.textColorLight, // Ensure text is the right color
          fontSize: AppSizes.sp(20).clamp(10, 36),
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            fontSize: AppSizes.sp(16).clamp(10, 34),
            // ignore: deprecated_member_use
            color: AppTheme.textColorLight.withOpacity(0.7),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          filled: true,
          fillColor: AppTheme.transparentColor, // Adjust this color as needed
          prefixIcon: null,
          suffixIcon: IconButton(
            icon: Icon(icon),
            onPressed: onIconPressed, // Toggle function
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 18, horizontal: 12), // Adjusted padding
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
              width: 0.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 0.0,
            ),
          ),
        ),
      ),
    );
  }
}
