import 'package:accento/utilities/constants.dart';
import 'package:flutter/material.dart';

import '../../utilities/theme.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Future<void> Function()? onTap;

  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  bool loading;
  final double? width;
  final double? height;

  CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppTheme.primaryColor,
    this.textColor = AppTheme.textColorLight,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 80),
    this.loading = false,
    this.width,
    this.height, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width ?? AppSizes.wp(220),
        height: height ?? AppSizes.hp(60),
        decoration: BoxDecoration(
            color: backgroundColor, borderRadius: BorderRadius.circular(50)),
        child: Center(
          child: loading
              ? CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppTheme.textColorLight,
                )
              : Text(
                  text,
                  style: TextStyle(
                      fontSize: AppSizes.sp(20).clamp(10, 32),
                      color: textColor,
                      fontWeight: FontWeight.w700),
                ),
        ),
      ),
    );
  }
}
