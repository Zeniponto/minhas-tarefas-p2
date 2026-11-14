import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static final ThemeData lightTheme = _criar(Brightness.light);
  static final ThemeData darkTheme = _criar(Brightness.dark);

  static ThemeData _criar(Brightness brilho) {
    final cores = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: brilho,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cores,
      scaffoldBackgroundColor: cores.surfaceContainerLowest,
    );
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
        titleLarge: base.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cores.surfaceContainerLowest,
        foregroundColor: cores.onSurface,
        surfaceTintColor: cores.surfaceContainerLowest,
        systemOverlayStyle: brilho == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cores.surfaceContainerLow,
        shape: forma,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cores.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cores.outlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cores.primary,
          foregroundColor: cores.onPrimary,
          minimumSize: const Size(0, 52),
          shape: forma,
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: cores.surface),
      listTileTheme: ListTileThemeData(
        selectedColor: cores.primary,
        selectedTileColor: cores.primaryContainer,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cores.inverseSurface,
        contentTextStyle: TextStyle(color: cores.onInverseSurface),
      ),
    );
  }
}
