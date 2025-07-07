class InventarioItem {
  final int id;
  final String nombre;
  final int tipo;
  final double cantidad;
  final String unidad;
  final double stockMinimo;
  final double stockMaximo;
  final double precioUnitario;
  final DateTime ultimaActualizacion;
  final String? proveedor;
  final String? codigoProveedor;
  final DateTime? fechaVencimiento;
  final String? ubicacionAlmacen;
  final double costoPromedio;
  final double puntoReorden;
  final bool activo;
  final String? notas;

  InventarioItem({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.cantidad,
    required this.unidad,
    required this.stockMinimo,
    required this.stockMaximo,
    required this.precioUnitario,
    required this.ultimaActualizacion,
    this.proveedor,
    this.codigoProveedor,
    this.fechaVencimiento,
    this.ubicacionAlmacen,
    required this.costoPromedio,
    required this.puntoReorden,
    required this.activo,
    this.notas,
  });

  factory InventarioItem.fromJson(Map<String, dynamic> json) {
    return InventarioItem(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
      tipo: json['tipo'] as int? ?? 0,
      cantidad: (json['cantidad'] as num?)?.toDouble() ?? 0.0,
      unidad: json['unidad'] as String? ?? '',
      stockMinimo: (json['stockMinimo'] as num?)?.toDouble() ?? 0.0,
      stockMaximo: (json['stockMaximo'] as num?)?.toDouble() ?? 0.0,
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      ultimaActualizacion: json['ultimaActualizacion'] != null 
          ? DateTime.parse(json['ultimaActualizacion'] as String)
          : DateTime.now(),
      proveedor: json['proveedor'] as String?,
      codigoProveedor: json['codigoProveedor'] as String?,
      fechaVencimiento: json['fechaVencimiento'] != null
          ? DateTime.parse(json['fechaVencimiento'] as String)
          : null,
      ubicacionAlmacen: json['ubicacionAlmacen'] as String?,
      costoPromedio: (json['costoPromedio'] as num?)?.toDouble() ?? 0.0,
      puntoReorden: (json['puntoReorden'] as num?)?.toDouble() ?? 0.0,
      activo: json['activo'] as bool? ?? true,
      notas: json['notas'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'cantidad': cantidad,
      'unidad': unidad,
      'stockMinimo': stockMinimo,
      'stockMaximo': stockMaximo,
      'precioUnitario': precioUnitario,
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
      'proveedor': proveedor,
      'codigoProveedor': codigoProveedor,
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'ubicacionAlmacen': ubicacionAlmacen,
      'costoPromedio': costoPromedio,
      'puntoReorden': puntoReorden,
      'activo': activo,
      'notas': notas,
    };
  }

  String get tipoTexto {
    switch (tipo) {
      case 0: return 'Carne';
      case 1: return 'Guarnición';
      case 2: return 'Dulce';
      case 3: return 'Empaque';
      case 4: return 'Combustible';
      default: return 'Desconocido';
    }
  }

  bool get stockCritico => cantidad <= stockMinimo;
  
  bool get stockBajo => cantidad <= puntoReorden;
  
  bool get estaVencido {
    if (fechaVencimiento == null) return false;
    return fechaVencimiento!.isBefore(DateTime.now());
  }

  bool get proximoAVencer {
    if (fechaVencimiento == null) return false;
    final diasRestantes = fechaVencimiento!.difference(DateTime.now()).inDays;
    return diasRestantes <= 7 && diasRestantes > 0;
  }
}