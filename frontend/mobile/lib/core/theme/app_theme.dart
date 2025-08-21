import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  static const Color accentColor = MAIZE_ACCENT;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: MAIZE_PRIMARY,
      fontFamily: GoogleFonts.montserrat().fontFamily,
      textTheme: TextTheme(
        // FOR TITLE TEXT
        titleLarge: GoogleFonts.righteous(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: MAIZE_TITLE,
          letterSpacing: 5,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.30),
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),

        // FOR HEADLINE TEXT
        headlineMedium: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
          fontSize: 25.sp,
          color: MAIZE_PRIMARY_LIGHT,
          letterSpacing: 0,
          height: 0,
          decoration: TextDecoration.none,
        ),

        // FOR BODY TEXT
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: MAIZE_ACCENT,
          letterSpacing: 0,
          height: 0,
          decoration: TextDecoration.none,
        ),

        // FOR SMALL BODY TEXT
        bodySmall: GoogleFonts.montserrat(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: MAIZE_ACCENT,
          letterSpacing: 0,
          height: 0,
          decoration: TextDecoration.none,
        ),

        // FOR BODY TEXT WITH BOLD WEIGHT
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: MAIZE_PRIMARY_LIGHT,
          letterSpacing: 0,
          height: 0,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
