class Churrasco {
  final int id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final int tipoCarne;
  final int terminoCoccion;
  final int tipoPlato;
  final int cantidadPorciones;
  final double precioBase;
  final bool disponible;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final List<GuarnicionChurrasco>? guarniciones;

  Churrasco({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion,
    required this.tipoCarne,
    required this.terminoCoccion,
    required this.tipoPlato,
    required this.cantidadPorciones,
    required this.precioBase,
    required this.disponible,
    required this.fechaCreacion,
    this.fechaModificacion,
    this.guarniciones,
  });

  factory Churrasco.fromJson(Map<String, dynamic> json) {
    try {
      return Churrasco(
        id: _parseInteger(json['id']),
        nombre: _parseString(json['nombre']),
        precio: _parseDouble(json['precio']),
        descripcion: _parseNullableString(json['descripcion']),
        tipoCarne: _parseInteger(json['tipoCarne']),
        terminoCoccion: _parseInteger(json['terminoCoccion']),
        tipoPlato: _parseInteger(json['tipoPlato']),
        cantidadPorciones: _parseInteger(json['cantidadPorciones']),
        precioBase: _parseDouble(json['precioBase']),
        disponible: _parseBoolean(json['disponible']),
        fechaCreacion: _parseDateTime(json['fechaCreacion']),
        fechaModificacion: _parseNullableDateTime(json['fechaModificacion']),
        guarniciones: _parseGuarniciones(json['guarniciones']),
      );
    } catch (e) {
      print('Error parsing Churrasco: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseInteger(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return value.toString();
  }

  static bool _parseBoolean(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) return value == 1;
    return false;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static List<GuarnicionChurrasco>? _parseGuarniciones(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      try {
        return value
            .map((e) => GuarnicionChurrasco.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error parsing guarniciones: $e');
        return [];
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'tipoCarne': tipoCarne,
      'terminoCoccion': terminoCoccion,
      'tipoPlato': tipoPlato,
      'cantidadPorciones': cantidadPorciones,
      'precioBase': precioBase,
      'disponible': disponible,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
      'guarniciones': guarniciones?.map((e) => e.toJson()).toList(),
    };
  }

  Churrasco copyWith({
    int? id,
    String? nombre,
    double? precio,
    String? descripcion,
    int? tipoCarne,
    int? terminoCoccion,
    int? tipoPlato,
    int? cantidadPorciones,
    double? precioBase,
    bool? disponible,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    List<GuarnicionChurrasco>? guarniciones,
  }) {
    return Churrasco(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      descripcion: descripcion ?? this.descripcion,
      tipoCarne: tipoCarne ?? this.tipoCarne,
      terminoCoccion: terminoCoccion ?? this.terminoCoccion,
      tipoPlato: tipoPlato ?? this.tipoPlato,
      cantidadPorciones: cantidadPorciones ?? this.cantidadPorciones,
      precioBase: precioBase ?? this.precioBase,
      disponible: disponible ?? this.disponible,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      guarniciones: guarniciones ?? this.guarniciones,
    );
  }
}

class GuarnicionChurrasco {
  final int churrascoId;
  final int guarnicionId;
  final String nombreGuarnicion;
  final int cantidadPorciones;
  final bool esExtra;
  final double precioExtra;
  final double precioTotal;

  GuarnicionChurrasco({
    required this.churrascoId,
    required this.guarnicionId,
    required this.nombreGuarnicion,
    required this.cantidadPorciones,
    required this.esExtra,
    required this.precioExtra,
    required this.precioTotal,
  });

  factory GuarnicionChurrasco.fromJson(Map<String, dynamic> json) {
    return GuarnicionChurrasco(
      churrascoId: json['churrascoId'] as int? ?? 0,
      guarnicionId: json['guarnicionId'] as int? ?? 0,
      nombreGuarnicion: json['nombreGuarnicion'] as String? ?? '',
      cantidadPorciones: json['cantidadPorciones'] as int? ?? 1,
      esExtra: json['esExtra'] as bool? ?? false,
      precioExtra: (json['precioExtra'] as num?)?.toDouble() ?? 0.0,
      precioTotal: (json['precioTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'churrascoId': churrascoId,
      'guarnicionId': guarnicionId,
      'nombreGuarnicion': nombreGuarnicion,
      'cantidadPorciones': cantidadPorciones,
      'esExtra': esExtra,
      'precioExtra': precioExtra,
      'precioTotal': precioTotal,
    };
  }
}

class ChurrascoCreateRequest {
  final String nombre;
  final double precio;
  final String? descripcion;
  final int tipoCarne;
  final int terminoCoccion;
  final int tipoPlato;
  final int cantidadPorciones;
  final double precioBase;
  final bool disponible;
  final List<GuarnicionChurrascoRequest>? guarniciones;

  ChurrascoCreateRequest({
    required this.nombre,
    required this.precio,
    this.descripcion,
    required this.tipoCarne,
    required this.terminoCoccion,
    required this.tipoPlato,
    required this.cantidadPorciones,
    required this.precioBase,
    this.disponible = true,
    this.guarniciones,
  });

  factory ChurrascoCreateRequest.fromJson(Map<String, dynamic> json) {
    return ChurrascoCreateRequest(
      nombre: json['nombre'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'] as String?,
      tipoCarne: json['tipoCarne'] as int? ?? 0,
      terminoCoccion: json['terminoCoccion'] as int? ?? 0,
      tipoPlato: json['tipoPlato'] as int? ?? 0,
      cantidadPorciones: json['cantidadPorciones'] as int? ?? 1,
      precioBase: (json['precioBase'] as num?)?.toDouble() ?? 0.0,
      disponible: json['disponible'] as bool? ?? true,
      guarniciones: (json['guarniciones'] as List<dynamic>?)
          ?.map((e) => GuarnicionChurrascoRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'tipoCarne': tipoCarne,
      'terminoCoccion': terminoCoccion,
      'tipoPlato': tipoPlato,
      'cantidadPorciones': cantidadPorciones,
      'precioBase': precioBase,
      'disponible': disponible,
      'guarniciones': guarniciones?.map((e) => e.toJson()).toList(),
    };
  }
}

class GuarnicionChurrascoRequest {
  final int guarnicionId;
  final int cantidadPorciones;
  final bool esExtra;

  GuarnicionChurrascoRequest({
    required this.guarnicionId,
    required this.cantidadPorciones,
    required this.esExtra,
  });

  factory GuarnicionChurrascoRequest.fromJson(Map<String, dynamic> json) {
    return GuarnicionChurrascoRequest(
      guarnicionId: json['guarnicionId'] as int? ?? 0,
      cantidadPorciones: json['cantidadPorciones'] as int? ?? 1,
      esExtra: json['esExtra'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guarnicionId': guarnicionId,
      'cantidadPorciones': cantidadPorciones,
      'esExtra': esExtra,
    };
  }
}

class Guarnicion {
  final int id;
  final String nombre;
  final double precioExtra;
  final bool disponible;
  final int cantidadStock;
  final int stockMinimo;
  final String? descripcion;

  Guarnicion({
    required this.id,
    required this.nombre,
    required this.precioExtra,
    required this.disponible,
    required this.cantidadStock,
    required this.stockMinimo,
    this.descripcion,
  });

  factory Guarnicion.fromJson(Map<String, dynamic> json) {
    return Guarnicion(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      precioExtra: (json['precioExtra'] as num?)?.toDouble() ?? 0.0,
      disponible: json['disponible'] as bool? ?? true,
      cantidadStock: json['cantidadStock'] as int? ?? 0,
      stockMinimo: json['stockMinimo'] as int? ?? 0,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precioExtra': precioExtra,
      'disponible': disponible,
      'cantidadStock': cantidadStock,
      'stockMinimo': stockMinimo,
      'descripcion': descripcion,
    };
  }
}