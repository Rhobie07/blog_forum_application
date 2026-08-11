import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _inkBlack = Color(0xFF18181B);
  static const _textBlack = Color(0xFF09090B);
  static const _subtleGray = Color(0xFF3F3F46);
  static const _mutedGray = Color(0xFF71717A);
  static const _borderGray = Color(0xFFE4E4E7);
  static const _bgWhite = Color(0xFFFAFAFA);
  static const _pureWhite = Color(0xFFFFFFFF);
  static const _mediaOverlay = Color(0x8A000000);
  static const _accent = Color(0xFFE11D48);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _inkBlack,
      onPrimary: _pureWhite,
      secondary: _subtleGray,
      surface: _bgWhite,
      onSurface: _textBlack,
      outline: _borderGray,
      error: _accent,
      inverseSurface: _inkBlack,
      onInverseSurface: _pureWhite,
      scrim: _mediaOverlay,
    ),
    scaffoldBackgroundColor: _bgWhite,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.newsreader(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.15,
        color: _textBlack,
      ),
      displayMedium: GoogleFonts.newsreader(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: _textBlack,
      ),
      headlineLarge: GoogleFonts.newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: _textBlack,
      ),
      headlineMedium: GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: _textBlack,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: _textBlack,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: _textBlack,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: _textBlack,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: _subtleGray,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: _mutedGray,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: _subtleGray,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: _mutedGray,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _bgWhite,
      foregroundColor: _textBlack,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textBlack,
      ),
    ),
    cardTheme: CardThemeData(
      color: _pureWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _borderGray, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _pureWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _inkBlack, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _accent),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _subtleGray,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _mutedGray,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _inkBlack,
        foregroundColor: _pureWhite,
        disabledBackgroundColor: _borderGray,
        disabledForegroundColor: _mutedGray,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _inkBlack,
        side: const BorderSide(color: _borderGray),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _subtleGray,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: _borderGray,
      thickness: 1,
      space: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _inkBlack,
      linearTrackColor: _borderGray,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _pureWhite,
      ),
    ),
  );
}
