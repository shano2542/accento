import 'package:accento/utilities/theme.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback onListPressed;
  final VoidCallback onProfilePressed;
  final VoidCallback onMicPressed;

  const CustomBottomNavBar({
    super.key,
    required this.onListPressed,
    required this.onProfilePressed,
    required this.onMicPressed,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double navWidth = screenWidth * 0.60;
    double navHeight = screenHeight * 0.10;
    return Container(
      width: navWidth,
      height: navHeight,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.navBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.list_alt_outlined,
                color: AppTheme.primaryColor,
                size: 42,
              ),
              onPressed: onListPressed,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.account_circle,
                color: AppTheme.primaryColor,
                size: 42,
              ),
              onPressed: onProfilePressed,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  final String? imagePath;

  const CustomFAB({
    super.key,
    required this.onPressed,
    this.icon,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.5,
      child: FloatingActionButton(
        onPressed: onPressed,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: AppTheme.transparentColor,
        child: imagePath != null
            ? CustomImage(
                imagePath: imagePath!,
                size: 140, // Adjust size as needed
              )
            : CustomIcon(
                icon: icon!,
                size: 140,
                color: AppTheme.primaryColor,
              ),
      ),
    );
  }
}

class CustomIcon extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;

  const CustomIcon({
    super.key,
    required this.size,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Center(
        child: Icon(
          icon,
          color: AppTheme.textColorLight,
          size: size * 0.30,
        ),
      ),
    );
  }
}

class CustomImage extends StatelessWidget {
  final String imagePath;
  final double size;
  final Color backgroundColor;

  const CustomImage({
    super.key,
    required this.imagePath,
    required this.size,
    this.backgroundColor = AppTheme.primaryColor, // Default background color
  });

  @override
  Widget build(BuildContext context) {
    double imageSize = size * 0.27;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
      ),
      child: Center(
        child: ClipOval(
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: imageSize,
            height: imageSize,
            color: AppTheme.textColorLight,
          ),
        ),
      ),
    );
  }
}