import 'package:flutter/material.dart';

import '../../utilities/theme.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  bool loading;

  CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppTheme.primaryColor,
    this.textColor = AppTheme.textColorLight,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onPressed,
      child: Container(
        height: 60,
        width: 220,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(50)
        ),
        child: Center(child: loading ? CircularProgressIndicator(strokeWidth: 3, color: AppTheme.textColorLight,): 
        Text(text,style: TextStyle(color: textColor),),),
      ),
    );
  }
}