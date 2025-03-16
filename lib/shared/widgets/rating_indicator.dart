import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';

class RatingIndicator extends StatelessWidget {
  final double rating;
  final double size;
  final bool showText;

  const RatingIndicator({
    Key? key,
    required this.rating,
    this.size = 16.0,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert rating from 0-10 scale to 0-100% for display
    final percentage = (rating * 10).round();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: AppColors.ratingColor,
          size: size,
        ),
        const SizedBox(width: 2),
        if (showText)
          Text(
            '$percentage%',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.75,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
