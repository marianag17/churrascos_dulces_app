import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF8B4513);
  static const Color secondaryColor = Color(0xFFFF6B35); 
  static const Color accentColor = Color(0xFF32CD32); 
  static const Color inventoryColor = Color(0xFF2E7D32); 
  static const Color salesColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFFFF8DC); 

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(0xFF8B4513, {
        50: const Color(0xFFF5F0E8),
        100: const Color(0xFFE6D9C6),
        200: const Color(0xFFD5C0A0),
        300: const Color(0xFFC4A77A),
        400: const Color(0xFFB7945E),
        500: primaryColor,
        600: const Color(0xFF7F3F11),
        700: const Color(0xFF74370E),
        800: const Color(0xFF6A2F0C),
        900: const Color(0xFF572007),
      }),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // // Card Theme
      // cardTheme: CardTheme(
      //   color: Colors.white,
      //   elevation: 4,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      //   margin: const EdgeInsets.all(8),
      // ),
      //       elevatedButtonTheme: ElevatedButtonThemeData(
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: primaryColor,
      //     foregroundColor: Colors.white,
      //     elevation: 4,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //   ),
      // ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        background: backgroundColor,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        onError: Colors.white,
      ),
    );
  }

  static const Map<String, Color> categoryColors = {
    'churrascos': primaryColor,
    'dulces': secondaryColor,
    'combos': accentColor,
    'inventario': inventoryColor,
    'ventas': salesColor,
    'guarniciones': Color(0xFF4CAF50),
    'sucursales': Color(0xFF9C27B0),
  };

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFFA0522D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFFE55A2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getStockColor(int stock, int minStock) {
    if (stock <= minStock) return Colors.red;
    if (stock <= minStock * 2) return Colors.orange;
    return Colors.green;
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activo':
      case 'disponible':
      case 'completado':
        return Colors.green;
      case 'pendiente':
      case 'proceso':
        return Colors.orange;
      case 'inactivo':
      case 'cancelado':
      case 'agotado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
}