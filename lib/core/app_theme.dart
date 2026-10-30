import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pastel Drift colour tokens.
abstract final class AppColors {
  static const Color primaryInk = Color(0xFF215887);
  static const Color pastelPedestal = Color(0xFFB3D4E0);
  static const Color canvasBackground = Color(0xFFF4F4EB);
  static const Color textSecondary = Color(0xFF718096);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color bodyText = Color(0xFF1A1C17);
  static const Color splashBackground = Color(0xFFDFF2FA);

  static const Color errorRed = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2F855A);
  static const Color warning = Color(0xFFB7791F);

  /// 4% black, used for ambient shadows.
  static const Color shadowTint = Color(0x0A000000);

  /// Soft pastel outline (powder blue at 50%).
  static const Color pastelOutline = Color(0x80B3D4E0);

  /// Translucent white used on top of navy surfaces.
  static const Color whiteGlass = Color(0x33FFFFFF);
}

abstract final class AppShadows {
  /// 0px 8px 15px rgba(0,0,0,0.04)
  static const List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadowTint, blurRadius: 15, offset: Offset(0, 8)),
  ];

  /// Upward shadow for docks and overlapping slabs.
  static const List<BoxShadow> lifted = [
    BoxShadow(color: AppColors.shadowTint, blurRadius: 10, offset: Offset(0, -4)),
  ];
}

abstract final class AppRadii {
  static const double card = 35;
  static const double banner = 40;
  static const double slab = 24;
  static const double control = 16;
  static const double pill = 100;
}

/// Plus Jakarta Sans type scale. Fields are lazily created once.
abstract final class AppText {
  static TextStyle _style(
    double size,
    FontWeight weight,
    double lineHeight,
    Color color,
  ) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: lineHeight / size,
      color: color,
    );
  }

  static final TextStyle headlineXL =
      _style(26, FontWeight.w800, 32, AppColors.primaryInk);
  static final TextStyle headlineMedium =
      _style(20, FontWeight.w700, 26, AppColors.primaryInk);
  static final TextStyle titleMedium =
      _style(16, FontWeight.w600, 22, AppColors.primaryInk);
  static final TextStyle bodyMedium =
      _style(14, FontWeight.w400, 21, AppColors.textSecondary);
  static final TextStyle labelMedium =
      _style(12, FontWeight.w600, 16, AppColors.primaryInk);
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryInk,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primaryInk,
      onPrimary: Colors.white,
      secondary: AppColors.pastelPedestal,
      surface: AppColors.surfaceWhite,
      error: AppColors.errorRed,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.canvasBackground,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.bodyText,
        displayColor: AppColors.primaryInk,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryInk,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryInk,
        contentTextStyle: AppText.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
