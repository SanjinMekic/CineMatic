import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF90CAF9),      // Light blue
    secondary: Color(0xFF80CBC4),    // Teal
    background: Color(0xFF121212),   // True dark
    surface: Color(0xFF1E1E1E),
    error: Color(0xFFCF6679),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onBackground: Colors.white,
    onSurface: Colors.white,
    onError: Colors.black,
  ),
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Color(0xFF90CAF9),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF90CAF9)),
    titleTextStyle: TextStyle(
      color: Color(0xFF90CAF9),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardTheme(
    color: Color(0xFF232323),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Color(0xFF232323),
    contentTextStyle: TextStyle(color: Color(0xFF90CAF9)),
    actionTextColor: Color(0xFF80CBC4),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF90CAF9),
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF80CBC4),
    ),
  ),
  iconTheme: IconThemeData(color: Color(0xFF90CAF9)),
  dividerColor: Color(0xFF232323),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF232323),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF90CAF9)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Color(0xFF80CBC4)),
    ),
    labelStyle: TextStyle(color: Color(0xFF90CAF9)),
    hintStyle: TextStyle(color: Colors.grey[400]),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Color(0xFF90CAF9),
  ),
  listTileTheme: ListTileThemeData(
    tileColor: Color(0xFF232323),
    iconColor: Color(0xFF90CAF9),
    textColor: Colors.white,
  ),
  popupMenuTheme: PopupMenuThemeData(
    color: Color(0xFF232323),
    textStyle: TextStyle(color: Colors.white),
  ),
  // Dodaj još po želji...
);