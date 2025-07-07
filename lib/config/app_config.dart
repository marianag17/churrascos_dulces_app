class AppConfig {
  static const String appName = 'Churrascos & Dulces';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'http://localhost:5026/api'; 
  static const int timeoutSeconds = 30;
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;

  static const Map<int, String> tiposCarne = {
    0: 'Puyazo',
    1: 'Culotte',
    2: 'Costilla',
  };

  static const Map<int, String> terminosCoccion = {
    0: 'Término Medio',
    1: 'Término Tres Cuartos',
    2: 'Bien Cocido',
  };

  static const Map<int, String> tiposPlato = {
    0: 'Individual',
    1: 'Familiar 3 Porciones',
    2: 'Familiar 5 Porciones',
  };

  static const Map<int, String> tiposDulce = {
    0: 'Canillitas de Leche',
    1: 'Pepitoria',
    2: 'Cocadas',
    3: 'Dulces de Higo',
    4: 'Mazapanes',
    5: 'Chilacayotes',
    6: 'Conservas de Coco',
    7: 'Colochos de Guayaba',
  };

  static const Map<int, String> modalidadesVenta = {
    0: 'Por Unidad',
    1: 'Caja de 6',
    2: 'Caja de 12',
    3: 'Caja de 24',
  };

  static const Map<int, String> tiposCombos = {
    0: 'Familiar',
    1: 'Eventos',
    2: 'Personalizado',
  };

  static const Map<int, String> tiposInventario = {
    0: 'Carne',
    1: 'Guarnición',
    2: 'Dulce',
    3: 'Empaque',
    4: 'Combustible',
  };

  static const Map<int, String> tiposVenta = {
    0: 'Local',
    1: 'Domicilio',
    2: 'Eventos',
  };

  static const Map<int, String> estadosVenta = {
    0: 'Pendiente',
    1: 'Preparando',
    2: 'Listo',
    3: 'Entregado',
    4: 'Cancelado',
  };

  static String formatCurrency(double amount) {
    return 'Q${amount.toStringAsFixed(2)}';
  }

  static String getMeatTypeLabel(int type) {
    return tiposCarne[type] ?? 'Desconocido';
  }

  static String getCookingTermLabel(int term) {
    return terminosCoccion[term] ?? 'Desconocido';
  }

  static String getPlateTypeLabel(int type) {
    return tiposPlato[type] ?? 'Desconocido';
  }

  static String getSweetTypeLabel(int type) {
    return tiposDulce[type] ?? 'Desconocido';
  }

  static String getSaleModalityLabel(int modality) {
    return modalidadesVenta[modality] ?? 'Desconocido';
  }

  static String getComboTypeLabel(int type) {
    return tiposCombos[type] ?? 'Desconocido';
  }

  static String getInventoryTypeLabel(int type) {
    return tiposInventario[type] ?? 'Desconocido';
  }

  static String getSaleTypeLabel(int type) {
    return tiposVenta[type] ?? 'Desconocido';
  }

  static String getSaleStatusLabel(int status) {
    return estadosVenta[status] ?? 'Desconocido';
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\d{4}-\d{4}$').hasMatch(phone);
  }

  static bool isValidPrice(String price) {
    final double? value = double.tryParse(price);
    return value != null && value >= 0;
  }

  static bool isValidQuantity(String quantity) {
    final int? value = int.tryParse(quantity);
    return value != null && value >= 0;
  }

  static const Map<String, int> categoryColors = {
    'churrascos': 0xFF8B4513,
    'dulces': 0xFFFF6B35,
    'combos': 0xFF9C27B0,
    'inventario': 0xFF2E7D32,
    'ventas': 0xFF1976D2,
    'sucursales': 0xFF00695C,
  };

  static const int maxImageSizeMB = 5;
  static const int maxDescriptionLength = 500;
  static const int maxNameLength = 100;
  static const double minPrice = 0.01;
  static const double maxPrice = 9999.99;
  static const int maxQuantity = 9999;
  static const int defaultPageSize = 20;

  static const Duration notificationDuration = Duration(seconds: 4);
  static const int maxNotifications = 50;

  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;

  static const Map<String, String> messages = {
    'network_error': 'Error de conexión. Verifica tu internet.',
    'server_error': 'Error del servidor. Intenta más tarde.',
    'validation_error': 'Datos inválidos. Revisa la información.',
    'success_create': 'Creado exitosamente',
    'success_update': 'Actualizado exitosamente',
    'success_delete': 'Eliminado exitosamente',
    'confirm_delete': '¿Estás seguro de que deseas eliminar este elemento?',
    'no_data': 'No hay datos disponibles',
    'loading': 'Cargando...',
  };

  static const bool isDevelopment = true;
  static const bool enableLogging = true;
  static const bool enableDebugMode = true;
  static const String productionBaseUrl = 'https://api.churrascos.gt/api';
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const String defaultLocale = 'es_GT';
  static const String defaultCurrency = 'GTQ';
  static const String defaultTimeZone = 'America/Guatemala';

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  static String getTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Ahora';
    }
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static double calculateTax(double amount, {double taxRate = 0.12}) {
    return amount * taxRate;
  }

  static double calculateDiscount(double amount, double percentage) {
    return amount * (percentage / 100);
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static String getOrdinalNumber(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}º';
    }
    switch (number % 10) {
      case 1:
        return '${number}º';
      case 2:
        return '${number}º';
      case 3:
        return '${number}º';
      default:
        return '${number}º';
    }
  }

  static bool isValidOrderNumber(String orderNumber) {
    return RegExp(r'^ORD-\d+$').hasMatch(orderNumber);
  }

  static bool isBusinessHour(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= 8 && hour <= 22; // 8 AM a 10 PM
  }

  static String generateOrderNumber() {
    return 'ORD-${DateTime.now().millisecondsSinceEpoch}';
  }

  static double roundToTwoDecimals(double value) {
    return double.parse(value.toStringAsFixed(2));
  }



}