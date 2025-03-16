import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFF6C5CE7); // Rich purple
  static const Color secondaryColor = Color(0xFF00D2D3); // Bright teal
  static const Color accentColor = Color(0xFFFD79A8); // Soft pink
  static const Color tertiaryColor = Color(0xFFFDCB6E); // Warm yellow

  // Semantic Colors
  static const Color errorColor = Color(0xFFFF4757); // Bright red for errors
  static const Color warningColor = Color(0xFFFF9F43); // Orange for warnings
  static const Color successColor = Color(0xFF2ED573); // Green for success
  static const Color infoColor = Color(0xFF54A0FF); // Blue for information

  // Background Colors
  static const Color lightBackground = Color(0xFFF9FAFF); // Slightly blue-tinted white
  static const Color darkBackground = Color(0xFF10151E); // Deep blue-black

  // Surface Colors - Cards, dialogs, etc.
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E2635); // Slightly lighter than background
  static const Color lightSurfaceVariant = Color(0xFFF0F4FF); // Light blue-tinted
  static const Color darkSurfaceVariant = Color(0xFF2A3142); // Medium blue-gray

  // Text Colors
  static const Color lightTextColor = Color(0xFF1E293B); // Dark slate
  static const Color darkTextColor = Color(0xFFF8FAFC); // Off-white
  static const Color lightTextSecondary = Color(0xFF64748B); // Medium slate
  static const Color darkTextSecondary = Color(0xFFB0B6C6); // Light gray-blue

  // Divider Colors
  static const Color lightDividerColor = Color(0xFFE2E8F0);
  static const Color darkDividerColor = Color(0xFF334155);

  // Special Colors
  static const Color ratingColor = Color(0xFFFFD700); // Gold for ratings
  static const Color tokenColor = Color(0xFFFFBF00); // Token gold
  static const Color tokenSecondaryColor = Color(0xFFFF9500); // Darker gold

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF6C5CE7), // Primary purple
    Color(0xFF8E75FD), // Lighter purple
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF00D2D3), // Teal
    Color(0xFF1AD6B8), // Blue-green
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFD79A8), // Pink
    Color(0xFFFF98BC), // Lighter pink
  ];

  static const List<Color> tokenGradient = [
    Color(0xFFFFBF00), // Gold
    Color(0xFFFF9500), // Amber
  ];

  static const List<Color> successGradient = [
    Color(0xFF2ED573), // Green
    Color(0xFF7BED9F), // Lighter green
  ];

  static const List<Color> errorGradient = [
    Color(0xFFFF4757), // Red
    Color(0xFFFF6B81), // Lighter red
  ];

  // Overlay/Fade gradients
  static const List<Color> posterGradient = [
    Color(0x00000000), // Transparent
    Color(0xCC000000), // 80% black
  ];

  static const List<Color> featuredGradient = [
    Color(0x006C5CE7), // Transparent purple
    Color(0xCC6C5CE7), // 80% purple
  ];

  // Shimmer Colors
  static const Color shimmerBaseColor = Color(0xFFE2E8F0);
  static const Color shimmerHighlightColor = Color(0xFFF8FAFC);
  static const Color darkShimmerBaseColor = Color(0xFF2A3142);
  static const Color darkShimmerHighlightColor = Color(0xFF3A4155);

  // Card Gradients
  static const List<Color> cardGradient1 = [Color(0xFF6C5CE7), Color(0xFF8E75FD)];
  static const List<Color> cardGradient2 = [Color(0xFF00D2D3), Color(0xFF1AD6B8)];
  static const List<Color> cardGradient3 = [Color(0xFFFD79A8), Color(0xFFFF98BC)];
  static const List<Color> cardGradient4 = [Color(0xFFFDCB6E), Color(0xFFFFDA8A)];

  // Color Palette for charts or visualization
  static const List<Color> colorPalette = [
    Color(0xFF6C5CE7), // Purple
    Color(0xFF00D2D3), // Teal
    Color(0xFFFD79A8), // Pink
    Color(0xFFFDCB6E), // Yellow
    Color(0xFF54A0FF), // Blue
    Color(0xFF2ED573), // Green
  ];

  // New Neumorphic Colors
  static const Color lightNeumorphicBase = Color(0xFFF0F4F8);
  static const Color darkNeumorphicBase = Color(0xFF1A202C);

  // Material 3 inspired palette
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF6C5CE7,
    <int, Color>{
      50: Color(0xFFEEECFD),
      100: Color(0xFFD4CFFA),
      200: Color(0xFFB7B0F7),
      300: Color(0xFF9A90F4),
      400: Color(0xFF8377F1),
      500: Color(0xFF6C5CE7),
      600: Color(0xFF6454E4),
      700: Color(0xFF594AE0),
      800: Color(0xFF5041DD),
      900: Color(0xFF3F30D7),
    },
  );
}
