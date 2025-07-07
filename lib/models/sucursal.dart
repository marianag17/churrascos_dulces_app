class Sucursal {
  final int id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String? email;
  final String? gerente;
  final bool activa;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final double? latitud;
  final double? longitud;
  final String? horarioApertura;
  final String? horarioCierre;
  final List<String>? diasLaborales;
  Sucursal({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.telefono,
    this.email,
    this.gerente,
    required this.activa,
    required this.fechaCreacion,
    this.fechaModificacion,
    this.latitud,
    this.longitud,
    this.horarioApertura,
    this.horarioCierre,
    this.diasLaborales,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      email: json['email'] as String?,
      gerente: json['gerente'] as String?,
      activa: json['activa'] as bool? ?? true,
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime.now(),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      horarioApertura: json['horarioApertura'] as String?,
      horarioCierre: json['horarioCierre'] as String?,
      diasLaborales: (json['diasLaborales'] as List<dynamic>?)
          ?.map((e) => e.toString()).toList()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'gerente': gerente,
      'activa': activa,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
      'horarioApertura': horarioApertura,
      'horarioCierre': horarioCierre,
      'diasLaborales': diasLaborales,
    };
  }

  Sucursal copyWith({
    int? id,
    String? nombre,
    String? direccion,
    String? telefono,
    String? email,
    String? gerente,
    bool? activa,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    double? latitud,
    double? longitud,
    String? horarioApertura,
    String? horarioCierre,
    List<String>? diasLaborales,
  }) {
    return Sucursal(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      gerente: gerente ?? this.gerente,
      activa: activa ?? this.activa,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      horarioApertura: horarioApertura ?? this.horarioApertura,
      horarioCierre: horarioCierre ?? this.horarioCierre,
      diasLaborales: diasLaborales ?? this.diasLaborales,
    );
  }

  bool get estaAbierta {
    if (horarioApertura == null || horarioCierre == null || diasLaborales == null) {
      return true; // Si no hay horarios definidos, asumimos que está abierta
    }

    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    
    if (!diasLaborales!.contains(dayName)) {
      return false; // No trabaja hoy
    }

    final currentTime = _TimeOfDay.now();
    final openTime = _parseTimeOfDay(horarioApertura!);
    final closeTime = _parseTimeOfDay(horarioCierre!);

    if (openTime == null || closeTime == null) return true;

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    if (closeMinutes > openMinutes) {
      // Horario normal (ej: 8:00 - 20:00)
      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    } else {
      // Horario que cruza medianoche (ej: 22:00 - 2:00)
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    }
  }

  String _getDayName(int weekday) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return days[weekday - 1];
  }

  _TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        return _TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Error parsing time
    }
    return null;
  }
}

// Clase auxiliar para evitar conflictos con Flutter TimeOfDay
class _TimeOfDay {
  final int hour;
  final int minute;

  _TimeOfDay({required this.hour, required this.minute});

  static _TimeOfDay now() {
    final now = DateTime.now();
    return _TimeOfDay(hour: now.hour, minute: now.minute);
  }
}

class SucursalCreateRequest {
  final String nombre;
  final String direccion;
  final String telefono;
  final String? email;
  final String? gerente;
  final bool activa;
  final double? latitud;
  final double? longitud;
  final String? horarioApertura;
  final String? horarioCierre;
  final List<String>? diasLaborales;

  SucursalCreateRequest({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    this.email,
    this.gerente,
    this.activa = true,
    this.latitud,
    this.longitud,
    this.horarioApertura,
    this.horarioCierre,
    this.diasLaborales,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'gerente': gerente,
      'activa': activa,
      'latitud': latitud,
      'longitud': longitud,
      'horarioApertura': horarioApertura,
      'horarioCierre': horarioCierre,
      'diasLaborales': diasLaborales,
    };
  }
}