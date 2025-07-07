class Venta {
  final int id;
  final DateTime fecha;
  final double subtotal;
  final double impuestos;
  final double descuento;
  final double total;
  final int tipoVenta;
  final int estado;
  final String? nombreCliente;
  final String? telefonoCliente;
  final String? direccionEntrega;
  final int? numeroMesa;
  final String? metodoPago;
  final String? notasEspeciales;
  final String numeroOrden;
  final List<VentaItem>? items;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  Venta({
    required this.id,
    required this.fecha,
    required this.subtotal,
    required this.impuestos,
    required this.descuento,
    required this.total,
    required this.tipoVenta,
    required this.estado,
    this.nombreCliente,
    this.telefonoCliente,
    this.direccionEntrega,
    this.numeroMesa,
    this.metodoPago,
    this.notasEspeciales,
    required this.numeroOrden,
    this.items,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'] as int? ?? 0,
      fecha: json['fecha'] != null 
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      impuestos: (json['impuestos'] as num?)?.toDouble() ?? 0.0,
      descuento: (json['descuento'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      tipoVenta: json['tipoVenta'] as int? ?? 0,
      estado: json['estado'] as int? ?? 0,
      nombreCliente: json['nombreCliente'] as String?,
      telefonoCliente: json['telefonoCliente'] as String?,
      direccionEntrega: json['direccionEntrega'] as String?,
      numeroMesa: json['numeroMesa'] as int?,
      metodoPago: json['metodoPago'] as String?,
      notasEspeciales: json['notasEspeciales'] as String?,
      numeroOrden: json['numeroOrden'] as String? ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => VentaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime.now(),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'subtotal': subtotal,
      'impuestos': impuestos,
      'descuento': descuento,
      'total': total,
      'tipoVenta': tipoVenta,
      'estado': estado,
      'nombreCliente': nombreCliente,
      'telefonoCliente': telefonoCliente,
      'direccionEntrega': direccionEntrega,
      'numeroMesa': numeroMesa,
      'metodoPago': metodoPago,
      'notasEspeciales': notasEspeciales,
      'numeroOrden': numeroOrden,
      'items': items?.map((e) => e.toJson()).toList(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
    };
  }

  String get tipoVentaTexto {
    switch (tipoVenta) {
      case 0: return 'Local';
      case 1: return 'Domicilio';
      case 2: return 'Eventos';
      default: return 'Desconocido';
    }
  }

  String get estadoTexto {
    switch (estado) {
      case 0: return 'Pendiente';
      case 1: return 'Preparando';
      case 2: return 'Listo';
      case 3: return 'Entregado';
      case 4: return 'Cancelado';
      default: return 'Desconocido';
    }
  }

  bool get estaCompletada => estado == 3; // Entregado
  bool get estaCancelada => estado == 4; // Cancelado
  bool get estaPendiente => estado == 0; // Pendiente

  int get cantidadItems => items?.fold(0, (sum, item) => sum! + item.cantidad) ?? 0;


  Venta copyWith({
    int? id,
    DateTime? fecha,
    double? subtotal,
    double? impuestos,
    double? descuento,
    double? total,
    int? tipoVenta,
    int? estado,
    String? nombreCliente,
    String? telefonoCliente,
    String? direccionEntrega,
    int? numeroMesa,
    String? metodoPago,
    String? notasEspeciales,
    String? numeroOrden,
    List<VentaItem>? items,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  }) {
    return Venta(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      subtotal: subtotal ?? this.subtotal,
      impuestos: impuestos ?? this.impuestos,
      descuento: descuento ?? this.descuento,
      total: total ?? this.total,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      estado: estado ?? this.estado,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      telefonoCliente: telefonoCliente ?? this.telefonoCliente,
      direccionEntrega: direccionEntrega ?? this.direccionEntrega,
      numeroMesa: numeroMesa ?? this.numeroMesa,
      metodoPago: metodoPago ?? this.metodoPago,
      notasEspeciales: notasEspeciales ?? this.notasEspeciales,
      numeroOrden: numeroOrden ?? this.numeroOrden,
      items: items ?? this.items,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
    );
  }
}

class VentaItem {
  final int id;
  final int ventaId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? notasEspeciales;
  final String? categoria;

  VentaItem({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.notasEspeciales,
    this.categoria,
  });

  factory VentaItem.fromJson(Map<String, dynamic> json) {
    return VentaItem(
      id: json['id'] as int? ?? 0,
      ventaId: json['ventaId'] as int? ?? 0,
      productoId: json['productoId'] as int? ?? 0,
      nombreProducto: json['nombreProducto'] as String? ?? '',
      cantidad: json['cantidad'] as int? ?? 1,
      precioUnitario: (json['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      notasEspeciales: json['notasEspeciales'] as String?,
      categoria: json['categoria'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ventaId': ventaId,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
      'notasEspeciales': notasEspeciales,
      'categoria': categoria,
    };
  }

  double get totalCalculado => precioUnitario * cantidad;

  VentaItem copyWith({
    int? id,
    int? ventaId,
    int? productoId,
    String? nombreProducto,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
    String? notasEspeciales,
    String? categoria,
  }) {
    return VentaItem(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      notasEspeciales: notasEspeciales ?? this.notasEspeciales,
      categoria: categoria ?? this.categoria,
    );
  }
}

class VentaCreateRequest {
  final DateTime fecha;
  final double subtotal;
  final double impuestos;
  final double descuento;
  final double total;
  final int tipoVenta;
  final int estado;
  final String? nombreCliente;
  final String? telefonoCliente;
  final String? direccionEntrega;
  final int? numeroMesa;
  final String? metodoPago;
  final String? notasEspeciales;
  final String numeroOrden;
  final List<VentaItemCreateRequest> items;

  VentaCreateRequest({
    required this.fecha,
    required this.subtotal,
    required this.impuestos,
    required this.descuento,
    required this.total,
    required this.tipoVenta,
    this.estado = 0, 
    this.nombreCliente,
    this.telefonoCliente,
    this.direccionEntrega,
    this.numeroMesa,
    this.metodoPago,
    this.notasEspeciales,
    required this.numeroOrden,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'subtotal': subtotal,
      'impuestos': impuestos,
      'descuento': descuento,
      'total': total,
      'tipoVenta': tipoVenta,
      'estado': estado,
      'nombreCliente': nombreCliente,
      'telefonoCliente': telefonoCliente,
      'direccionEntrega': direccionEntrega,
      'numeroMesa': numeroMesa,
      'metodoPago': metodoPago,
      'notasEspeciales': notasEspeciales,
      'numeroOrden': numeroOrden,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
class VentaItemCreateRequest {
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String? notasEspeciales;

  VentaItemCreateRequest({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.notasEspeciales,
  });

  Map<String, dynamic> toJson() {
    return {
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
      'notasEspeciales': notasEspeciales,
    };
  }
}