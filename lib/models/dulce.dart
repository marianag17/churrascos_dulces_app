class DulceTipico {
  final int id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final int tipoDulce;
  final int cantidadEnStock;
  final int modalidadVenta;
  final int? capacidadCaja;
  final double precioUnidad;
  final DateTime? fechaVencimiento;
  final String? proveedor;
  final String? ingredientes;
  final double? pesoGramos;
  final bool disponible;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  DulceTipico({
    required this.id,
    required this.nombre,
    required this.precio,
    this.descripcion,
    required this.tipoDulce,
    required this.cantidadEnStock,
    required this.modalidadVenta,
    this.capacidadCaja,
    required this.precioUnidad,
    this.fechaVencimiento,
    this.proveedor,
    this.ingredientes,
    this.pesoGramos,
    required this.disponible,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  factory DulceTipico.fromJson(Map<String, dynamic> json) {
    return DulceTipico(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(),
      descripcion: json['descripcion'] as String?,
      tipoDulce: json['tipoDulce'] as int,
      cantidadEnStock: json['cantidadEnStock'] as int,
      modalidadVenta: json['modalidadVenta'] as int,
      capacidadCaja: json['capacidadCaja'] as int?,
      precioUnidad: (json['precioUnidad'] as num).toDouble(),
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.parse(json['fechaVencimiento'] as String)
          : null,
      proveedor: json['proveedor'] as String?,
      ingredientes: json['ingredientes'] as String?,
      pesoGramos: (json['pesoGramos'] as num?)?.toDouble(),
      disponible: json['disponible'] as bool,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'tipoDulce': tipoDulce,
      'cantidadEnStock': cantidadEnStock,
      'modalidadVenta': modalidadVenta,
      'capacidadCaja': capacidadCaja,
      'precioUnidad': precioUnidad,
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'proveedor': proveedor,
      'ingredientes': ingredientes,
      'pesoGramos': pesoGramos,
      'disponible': disponible,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
    };
  }

  bool get isVencido {
    if (fechaVencimiento == null) return false;
    return fechaVencimiento!.isBefore(DateTime.now());
  }

  bool get stockCritico {
    return cantidadEnStock <= 5;
  }

  String get modalidadVentaTexto {
    switch (modalidadVenta) {
      case 0: return 'Por Unidad';
      case 1: return 'Caja de 6';
      case 2: return 'Caja de 12';
      case 3: return 'Caja de 24';
      default: return 'Desconocido';
    }
  }

  String get tipoDulceTexto {
    switch (tipoDulce) {
      case 0: return 'Canillitas de Leche';
      case 1: return 'Pepitoria';
      case 2: return 'Cocadas';
      case 3: return 'Dulces de Higo';
      case 4: return 'Mazapanes';
      case 5: return 'Chilacayotes';
      case 6: return 'Conservas de Coco';
      case 7: return 'Colochos de Guayaba';
      default: return 'Desconocido';
    }
  }
}