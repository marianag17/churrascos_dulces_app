class Combo {
  final int id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final int tipoCombo;
  final double porcentajeDescuento;
  final double montoDescuento;
  final bool esTemporada;
  final DateTime? fechaInicioVigencia;
  final DateTime? fechaFinVigencia;
  final bool disponible;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;
  final List<ComboItem>? items;

  Combo({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion,
    required this.tipoCombo,
    required this.porcentajeDescuento,
    required this.montoDescuento,
    required this.esTemporada,
    this.fechaInicioVigencia,
    this.fechaFinVigencia,
    required this.disponible,
    required this.fechaCreacion,
    this.fechaModificacion,
    this.items,
  });

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      descripcion: json['descripcion'] as String?,
      tipoCombo: json['tipoCombo'] as int? ?? 0,
      porcentajeDescuento: (json['porcentajeDescuento'] as num?)?.toDouble() ?? 0.0,
      montoDescuento: (json['montoDescuento'] as num?)?.toDouble() ?? 0.0,
      esTemporada: json['esTemporada'] as bool? ?? false,
      fechaInicioVigencia: json['fechaInicioVigencia'] != null 
          ? DateTime.parse(json['fechaInicioVigencia'] as String)
          : null,
      fechaFinVigencia: json['fechaFinVigencia'] != null
          ? DateTime.parse(json['fechaFinVigencia'] as String)
          : null,
      disponible: json['disponible'] as bool? ?? true,
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime.now(),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ComboItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'tipoCombo': tipoCombo,
      'porcentajeDescuento': porcentajeDescuento,
      'montoDescuento': montoDescuento,
      'esTemporada': esTemporada,
      'fechaInicioVigencia': fechaInicioVigencia?.toIso8601String(),
      'fechaFinVigencia': fechaFinVigencia?.toIso8601String(),
      'disponible': disponible,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }

  Combo copyWith({
    int? id,
    String? nombre,
    double? precio,
    String? descripcion,
    int? tipoCombo,
    double? porcentajeDescuento,
    double? montoDescuento,
    bool? esTemporada,
    DateTime? fechaInicioVigencia,
    DateTime? fechaFinVigencia,
    bool? disponible,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    List<ComboItem>? items,
  }) {
    return Combo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      descripcion: descripcion ?? this.descripcion,
      tipoCombo: tipoCombo ?? this.tipoCombo,
      porcentajeDescuento: porcentajeDescuento ?? this.porcentajeDescuento,
      montoDescuento: montoDescuento ?? this.montoDescuento,
      esTemporada: esTemporada ?? this.esTemporada,
      fechaInicioVigencia: fechaInicioVigencia ?? this.fechaInicioVigencia,
      fechaFinVigencia: fechaFinVigencia ?? this.fechaFinVigencia,
      disponible: disponible ?? this.disponible,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      items: items ?? this.items,
    );
  }

  String get tipoComboTexto {
    switch (tipoCombo) {
      case 0: return 'Familiar';
      case 1: return 'Eventos';
      case 2: return 'Personalizado';
      default: return 'Desconocido';
    }
  }

  bool get estaVigente {
    if (!esTemporada) return disponible;
    
    final now = DateTime.now();
    if (fechaInicioVigencia != null && now.isBefore(fechaInicioVigencia!)) {
      return false;
    }
    if (fechaFinVigencia != null && now.isAfter(fechaFinVigencia!)) {
      return false;
    }
    return disponible;
  }
}

class ComboItem {
  final int id;
  final int comboId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final bool esObligatorio;
  final String? categoria;

  ComboItem({
    required this.id,
    required this.comboId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.esObligatorio,
    this.categoria,
  });

  factory ComboItem.fromJson(Map<String, dynamic> json) {
    return ComboItem(
      id: json['id'] as int? ?? 0,
      comboId: json['comboId'] as int? ?? 0,
      productoId: json['productoId'] as int? ?? 0,
      nombreProducto: json['nombreProducto'] as String? ?? '',
      cantidad: json['cantidad'] as int? ?? 1,
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      esObligatorio: json['esObligatorio'] as bool? ?? true,
      categoria: json['categoria'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comboId': comboId,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'esObligatorio': esObligatorio,
      'categoria': categoria,
    };
  }

  double get precioTotal => precioUnitario * cantidad;
}