import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

class AppTheme {
  // Işık teması
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,

      // Renk şeması
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFECE5FF),
        onPrimaryContainer: Color(0xFF351C85),

        secondary: AppColors.secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFD9F7F0),
        onSecondaryContainer: Color(0xFF004D40),

        tertiary: AppColors.accentColor,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFFFEAF1),
        onTertiaryContainer: Color(0xFF8C0037),

        error: AppColors.errorColor,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD7),
        onErrorContainer: Color(0xFF7F1D25),

        background: AppColors.lightBackground,
        onBackground: AppColors.lightTextColor,

        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextColor,

        surfaceVariant: AppColors.lightSurfaceVariant,
        onSurfaceVariant: AppColors.lightTextSecondary,

        outline: Color(0xFFDBE0EC),
        shadow: Color(0x29000000),
      ),

      // Diğer temel renkler
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.primaryColor,

      // StatusBar stili
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextColor,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.lightSurface,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.titleMedium,
        scrolledUnderElevation: 4,
        shadowColor: Color(0x20000000),
        toolbarHeight: 60,
      ),

      // Kart teması
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: const Color(0x1A000000),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated buton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryColor,
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 2,
          shadowColor: const Color(0x40000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 54),
        ),
      ),

      // Text buton teması
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined buton teması
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input dekorasyon teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyText.copyWith(color: AppColors.lightTextSecondary),
        labelStyle: AppTextStyles.bodyText.copyWith(color: AppColors.lightTextSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.errorColor),
        prefixIconColor: AppColors.lightTextSecondary,
        suffixIconColor: AppColors.lightTextSecondary,
      ),

      // Bottom navigation teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
        showUnselectedLabels: true,
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 26),
      ),

      // TabBar teması
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.lightTextSecondary,
        labelStyle: AppTextStyles.buttonText,
        unselectedLabelStyle: AppTextStyles.buttonText,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // Divider teması
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDividerColor,
        thickness: 1,
        space: 24,
      ),

      // Chip teması
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        disabledColor: AppColors.lightSurfaceVariant.withOpacity(0.7),
        selectedColor: AppColors.primaryColor.withOpacity(0.2),
        secondarySelectedColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        labelStyle: AppTextStyles.tag.copyWith(color: AppColors.lightTextColor),
        secondaryLabelStyle: AppTextStyles.tag.copyWith(color: Colors.white),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),

      // Snackbar teması
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextColor,
        contentTextStyle: AppTextStyles.bodyText.copyWith(color: Colors.white),
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Metin teması
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyText,
        bodySmall: AppTextStyles.bodyTextSmall,
        labelLarge: AppTextStyles.buttonText,
        labelMedium: AppTextStyles.caption,
        labelSmall: AppTextStyles.overline,
      ),

      // Diğer temalar
      iconTheme: const IconThemeData(
        color: AppColors.lightTextColor,
        size: 24,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor.withOpacity(0.4);
          }
          return AppColors.lightTextSecondary.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppColors.lightTextSecondary, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return AppColors.lightTextSecondary;
        }),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.lightTextColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }

  // Koyu tema
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,

      // Renk şeması
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF473377),
        onPrimaryContainer: Color(0xFFECE5FF),

        secondary: AppColors.secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF004D40),
        onSecondaryContainer: Color(0xFFD9F7F0),

        tertiary: AppColors.accentColor,
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF7D0031),
        onTertiaryContainer: Color(0xFFFFEAF1),

        error: AppColors.errorColor,
        onError: Colors.white,
        errorContainer: Color(0xFF7F1D25),
        onErrorContainer: Color(0xFFFFDAD7),

        background: AppColors.darkBackground,
        onBackground: AppColors.darkTextColor,

        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextColor,

        surfaceVariant: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkTextSecondary,

        outline: Color(0xFF454D65),
        shadow: Color(0x29000000),
      ),

      // Diğer temel renkler
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.primaryColor,

      // StatusBar stili
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextColor,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.darkSurface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.titleMedium,
        scrolledUnderElevation: 4,
        shadowColor: Color(0x40000000),
        toolbarHeight: 60,
      ),

      // Kart teması
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 2,
        shadowColor: const Color(0x3A000000),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated buton teması
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryColor,
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 2,
          shadowColor: const Color(0x60000000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(0, 54),
        ),
      ),

      // Text buton teması
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined buton teması
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
          textStyle: AppTextStyles.buttonText,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input dekorasyon teması
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyText.copyWith(color: AppColors.darkTextSecondary),
        labelStyle: AppTextStyles.bodyText.copyWith(color: AppColors.darkTextSecondary),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.errorColor),
        prefixIconColor: AppColors.darkTextSecondary,
        suffixIconColor: AppColors.darkTextSecondary,
      ),

      // Bottom navigation teması
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: AppTextStyles.caption,
        unselectedLabelStyle: AppTextStyles.caption,
        showUnselectedLabels: true,
        selectedIconTheme: IconThemeData(size: 26),
        unselectedIconTheme: IconThemeData(size: 26),
      ),

      // TabBar teması
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.darkTextSecondary,
        labelStyle: AppTextStyles.buttonText,
        unselectedLabelStyle: AppTextStyles.buttonText,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // Divider teması
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDividerColor,
        thickness: 1,
        space: 24,
      ),

      // Chip teması
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        disabledColor: AppColors.darkSurfaceVariant.withOpacity(0.7),
        selectedColor: AppColors.primaryColor.withOpacity(0.3),
        secondarySelectedColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        labelStyle: AppTextStyles.tag.copyWith(color: AppColors.darkTextColor),
        secondaryLabelStyle: AppTextStyles.tag.copyWith(color: Colors.white),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),

      // Snackbar teması
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: AppTextStyles.bodyText.copyWith(color: AppColors.darkTextColor),
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Metin teması
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.darkTextColor),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.darkTextColor),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.darkTextColor),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.darkTextColor),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextColor),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.darkTextColor),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextColor),
        bodyMedium: AppTextStyles.bodyText.copyWith(color: AppColors.darkTextColor),
        bodySmall: AppTextStyles.bodyTextSmall.copyWith(color: AppColors.darkTextColor),
        labelLarge: AppTextStyles.buttonText.copyWith(color: AppColors.darkTextColor),
        labelMedium: AppTextStyles.caption.copyWith(color: AppColors.darkTextColor),
        labelSmall: AppTextStyles.overline.copyWith(color: AppColors.darkTextColor),
      ),

      // Diğer temalar
      iconTheme: const IconThemeData(
        color: AppColors.darkTextColor,
        size: 24,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor.withOpacity(0.4);
          }
          return AppColors.darkTextSecondary.withOpacity(0.3);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppColors.darkTextSecondary, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryColor;
          }
          return AppColors.darkTextSecondary;
        }),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.caption.copyWith(color: AppColors.darkTextColor),
      ),
    );
  }
}