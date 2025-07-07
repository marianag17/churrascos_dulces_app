import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  BuildContext? _context;
  
  final List<AppNotification> _notificaciones = [];
  
  final List<VoidCallback> _listeners = [];

  // Agregar flag para controlar si el servicio está activo
  bool _isActive = false;

  void init(BuildContext context) {
    _context = context;
    _isActive = true;
    _inicializarNotificaciones();
  }

  // Método para desactivar el servicio
  void dispose() {
    _isActive = false;
    _context = null;
    _listeners.clear();
  }

  void _inicializarNotificaciones() {
    // Inicialización vacía por ahora
  }

  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    if (!_isActive) return;
    
    final listenersToNotify = List<VoidCallback>.from(_listeners);
    
    for (final listener in listenersToNotify) {
      try {
        listener();
      } catch (e) {
        debugPrint('Error notificando listener: $e');
      }
    }
  }

  List<AppNotification> get notificaciones => List.unmodifiable(_notificaciones);

  List<AppNotification> get notificacionesNoLeidas => 
      _notificaciones.where((n) => !n.leida).toList();

  int get cantidadNoLeidas => notificacionesNoLeidas.length;

  void mostrarNotificacionVenta({
    required String cliente,
    required double monto,
    required String sucursal,
    required String producto,
  }) {
    if (!_isActive) return;
    
    final notificacion = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: '💰 Nueva Venta',
      mensaje: '$cliente compró $producto por ${AppConfig.formatCurrency(monto)}',
      tipo: TipoNotificacion.venta,
      fecha: DateTime.now(),
      leida: false,
      data: {
        'cliente': cliente,
        'monto': monto,
        'producto': producto,
      },
    );

    _agregarNotificacion(notificacion);
    _mostrarSnackBar(notificacion);
  }

   void notificarProductoCreado(String nombreProducto, String categoria) {
    if (!_isActive) return;
    
    final notificacion = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: '$categoria Creado',
      mensaje: '$nombreProducto se ha agregado exitosamente al inventario',
      tipo: TipoNotificacion.sistema,
      fecha: DateTime.now(),
      leida: false,
      data: {
        'accion': 'producto_creado',
        'producto': nombreProducto,
        'categoria': categoria,
      },
    );

    _agregarNotificacion(notificacion);
    _mostrarSnackBar(notificacion);
  }

  void notificarProductoActualizado(String nombreProducto, String categoria) {
    if (!_isActive) return;
    
    final notificacion = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: '$categoria Actualizado',
      mensaje: '$nombreProducto ha sido actualizado correctamente',
      tipo: TipoNotificacion.sistema,
      fecha: DateTime.now(),
      leida: false,
      data: {
        'accion': 'producto_actualizado',
        'producto': nombreProducto,
        'categoria': categoria,
      },
    );

    _agregarNotificacion(notificacion);
    _mostrarSnackBar(notificacion);
  }

  void notificarProductoEliminado(String nombreProducto, String categoria) {
    if (!_isActive) return;
    
    final notificacion = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: '🗑️ $categoria Eliminado',
      mensaje: '$nombreProducto se ha eliminado del inventario',
      tipo: TipoNotificacion.inventario,
      fecha: DateTime.now(),
      leida: false,
      data: {
        'accion': 'producto_eliminado',
        'producto': nombreProducto,
        'categoria': categoria,
      },
    );

    _agregarNotificacion(notificacion);
    _mostrarSnackBar(notificacion);
  }

  void notificarVentaDulce({
    required String nombreDulce,
    required int cantidad,
    required double total,
    required String cliente,
  }) {
    if (!_isActive) return;
    
    final notificacion = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: '💰 Venta de Dulce',
      mensaje: '$cantidad ${nombreDulce}${cantidad > 1 ? 's' : ''} vendido${cantidad > 1 ? 's' : ''} a $cliente por ${AppConfig.formatCurrency(total)}',
      tipo: TipoNotificacion.venta,
      fecha: DateTime.now(),
      leida: false,
      data: {
        'accion': 'venta_dulce',
        'producto': nombreDulce,
        'cantidad': cantidad,
        'total': total,
        'cliente': cliente,
      },
    );

    _agregarNotificacion(notificacion);
    _mostrarSnackBar(notificacion);
  }

  void mostrarNotificacionStockBajo({
    required String producto,
    required int cantidadActual,
    required int stockMinimo,
    required String sucursal,
  }) {
    if (!_isActive) return;
    
    final notificacion = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: '⚠️ Stock Bajo',
      mensaje: '$producto tiene solo $cantidadActual unidades (mín: $stockMinimo) en $sucursal',
      tipo: TipoNotificacion.inventario,
      fecha: DateTime.now(),
      leida: false,
      data: {
        'producto': producto,
        'cantidadActual': cantidadActual,
        'stockMinimo': stockMinimo,
        'sucursal': sucursal,
      },
    );

    _agregarNotificacion(notificacion);
    _mostrarSnackBar(notificacion);
  }

  void mostrarNotificacionSistema({
    required String titulo,
    required String mensaje,
    Map<String, dynamic>? data,
  }) {
    if (!_isActive) return;
    
    final notificacion = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      titulo: titulo,
      mensaje: mensaje,
      tipo: TipoNotificacion.sistema,
      fecha: DateTime.now(),
      leida: false,
      data: data,
    );

    _agregarNotificacion(notificacion);
    _mostrarSnackBar(notificacion);
  }

  void _agregarNotificacion(AppNotification notificacion) {
    if (!_isActive) return;
    
    _notificaciones.insert(0, notificacion); 
    
    // Limitar el número de notificaciones
    if (_notificaciones.length > 50) {
      _notificaciones.removeRange(50, _notificaciones.length);
    }
    
    _notifyListeners();
  }

  void _mostrarSnackBar(AppNotification notificacion) {
    if (_context == null || !_isActive) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_context != null && _isActive) {
        try {
          // Verificar si el ScaffoldMessenger está disponible
          final messenger = ScaffoldMessenger.maybeOf(_context!);
          if (messenger != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      _getIconForType(notificacion.tipo),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            notificacion.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            notificacion.mensaje,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: _getColorForType(notificacion.tipo),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error mostrando SnackBar: $e');
        }
      }
    });
  }

  void marcarComoLeida(int id) {
    if (!_isActive) return;
    
    final index = _notificaciones.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notificaciones[index] = _notificaciones[index].copyWith(leida: true);
      _notifyListeners();
    }
  }

  void marcarTodasComoLeidas() {
    if (!_isActive) return;
    
    for (int i = 0; i < _notificaciones.length; i++) {
      _notificaciones[i] = _notificaciones[i].copyWith(leida: true);
    }
    _notifyListeners();
  }

  // Eliminar
  void eliminarNotificacion(int id) {
    if (!_isActive) return;
    
    _notificaciones.removeWhere((n) => n.id == id);
    _notifyListeners();
  }

  // Limpiar todas
  void limpiarTodasLasNotificaciones() {
    if (!_isActive) return;
    
    _notificaciones.clear();
    _notifyListeners();
  }

  IconData _getIconForType(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.venta:
        return Icons.point_of_sale;
      case TipoNotificacion.inventario:
        return Icons.inventory;
      case TipoNotificacion.cliente:
        return Icons.person;
      case TipoNotificacion.sistema:
        return Icons.info;
    }
  }

  Color _getColorForType(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.venta:
        return Colors.green;
      case TipoNotificacion.inventario:
        return Colors.orange;
      case TipoNotificacion.cliente:
        return Colors.blue;
      case TipoNotificacion.sistema:
        return Colors.grey;
    }
  }

  void notificarVentaCreada(Map<String, dynamic> ventaData) {
    mostrarNotificacionVenta(
      cliente: ventaData['nombreCliente'] ?? 'Cliente',
      monto: (ventaData['total'] ?? 0.0).toDouble(),
      sucursal: ventaData['sucursal'] ?? 'Sucursal',
      producto: ventaData['producto'] ?? 'Productos varios',
    );
  }

  void notificarStockBajo(Map<String, dynamic> inventarioData) {
    mostrarNotificacionStockBajo(
      producto: inventarioData['nombre'] ?? 'Producto',
      cantidadActual: inventarioData['cantidad']?.toInt() ?? 0,
      stockMinimo: inventarioData['stockMinimo']?.toInt() ?? 0,
      sucursal: inventarioData['sucursal'] ?? 'Sucursal',
    );
  }

  void notificarSucursalCreada(String nombreSucursal) {
    mostrarNotificacionSistema(
      titulo: 'Nueva Sucursal',
      mensaje: 'Se ha creado la sucursal "$nombreSucursal"',
      data: {
        'tipo': 'sucursal_creada',
        'nombre': nombreSucursal,
      },
    );
  }

  void notificarSucursalActualizada(String nombreSucursal) {
    mostrarNotificacionSistema(
      titulo: 'Sucursal Actualizada',
      mensaje: 'Se ha actualizado la información de "$nombreSucursal"',
      data: {
        'tipo': 'sucursal_actualizada',
        'nombre': nombreSucursal,
      },
    );
  }
}

class AppNotification {
  final int id;
  final String titulo;
  final String mensaje;
  final TipoNotificacion tipo;
  final DateTime fecha;
  final bool leida;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.fecha,
    required this.leida,
    this.data,
  });

  AppNotification copyWith({
    int? id,
    String? titulo,
    String? mensaje,
    TipoNotificacion? tipo,
    DateTime? fecha,
    bool? leida,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      leida: leida ?? this.leida,
      data: data ?? this.data,
    );
  }
}

enum TipoNotificacion {
  venta,
  inventario,
  cliente,
  sistema,
}