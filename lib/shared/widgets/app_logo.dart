import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool useGradient;

  const AppLogo({
    Key? key,
    required this.size,
    this.useGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (useGradient) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      );
    } else {
      return Icon(
        Icons.movie_outlined,
        color: AppColors.primaryColor,
        size: size,
      );
    }
  }
}