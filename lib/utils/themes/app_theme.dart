import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => FlexThemeData.light(
        useMaterial3: true,
        scheme: FlexScheme.indigoM3,
        surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
        blendLevel: 10,
        appBarStyle: FlexAppBarStyle.primary,
        typography: Typography.material2021(),
        textTheme: GoogleFonts.poppinsTextTheme(),
      );

  static ThemeData get darkTheme => FlexThemeData.dark(
        useMaterial3: true,
        scheme: FlexScheme.blueM3,
        surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
        blendLevel: 15,
        appBarStyle: FlexAppBarStyle.custom,
        appBarBackground: const Color(0xFF1D253B),
        typography: Typography.material2021(),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      );
}