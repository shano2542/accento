import 'package:accento/utilities/constants.dart';
import 'package:accento/utilities/theme.dart';
import 'package:flutter/material.dart';

class CustomVoiceField extends StatelessWidget {
  final String selectedVoice;
  final VoidCallback onPressed;
  const CustomVoiceField(
      {super.key, required this.selectedVoice, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.wp(323),
      height: AppSizes.hp(70),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryColor, width: 2.0),
        color: AppTheme.navBgColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Selected Voice Display
          Expanded(
            child: Text(
              selectedVoice,
              style: TextStyle(
                color: AppTheme.textColorDark,
                fontSize: AppSizes.sp(18).clamp(10, 32),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis, // Handle long voice names
            ),
          ),
          // Button with Icon
          InkWell(
            onTap: onPressed,
            child: const Icon(Icons.arrow_forward,
                size: 30, color: AppTheme.primaryColor),
          )
        ],
      ),
    );
  }
}
