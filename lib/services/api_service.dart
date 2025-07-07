import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/churrasco.dart';
import '../models/dulce.dart';
import '../models/combo.dart';
import '../models/venta.dart';
import '../models/inventario.dart';
import '../models/sucursal.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      throw HttpException(
        'Error ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }

  Future<T> _get<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: _headers,
      ).timeout(const Duration(seconds: AppConfig.timeoutSeconds));

      _handleError(response);
      
      final data = json.decode(response.body) as Map<String, dynamic>;
      return fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener datos: $e');
    }
  }

  Future<List<T>> _getList<T>(String endpoint, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: _headers,
      ).timeout(const Duration(seconds: AppConfig.timeoutSeconds));

      _handleError(response);
      
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error al obtener lista: $e');
    }
  }

  Future<T> _post<T>(String endpoint, Map<String, dynamic> data, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: AppConfig.timeoutSeconds));

      _handleError(response);
      
      if (response.body.isEmpty) {
        return fromJson({'success': true});
      }
      
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      return fromJson(responseData);
    } catch (e) {
      throw Exception('Error al crear: $e');
    }
  }

  Future<bool> _put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: _headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: AppConfig.timeoutSeconds));

      _handleError(response);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar: $e');
    }
  }

  Future<bool> _delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('${AppConfig.baseUrl}/$endpoint'),
        headers: _headers,
      ).timeout(const Duration(seconds: AppConfig.timeoutSeconds));

      _handleError(response);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al eliminar: $e');
    }
  }

  // === CHURRASCOS ===
  Future<List<Churrasco>> getChurrascos() async {
    return await _getList('churrascos', Churrasco.fromJson);
  }

  Future<Churrasco> getChurrasco(int id) async {
    return await _get('churrascos/$id', Churrasco.fromJson);
  }

  Future<Map<String, dynamic>> createChurrasco(ChurrascoCreateRequest churrasco) async {
    return await _post('churrascos', churrasco.toJson(), (data) => data);
  }

  Future<bool> updateChurrasco(int id, ChurrascoCreateRequest churrasco) async {
    return await _put('churrascos/$id', churrasco.toJson());
  }

  Future<bool> deleteChurrasco(int id) async {
    return await _delete('churrascos/$id');
  }

  // === DULCES TÍPICOS ===
  Future<List<DulceTipico>> getDulces() async {
    return await _getList('dulces', DulceTipico.fromJson);
  }

  Future<DulceTipico> getDulce(int id) async {
    return await _get('dulces/$id', DulceTipico.fromJson);
  }

  Future<Map<String, dynamic>> createDulce(DulceTipico dulce) async {
    return await _post('dulces', dulce.toJson(), (data) => data);
  }

  Future<bool> updateDulce(int id, DulceTipico dulce) async {
    return await _put('dulces/$id', dulce.toJson());
  }

  Future<bool> deleteDulce(int id) async {
    return await _delete('dulces/$id');
  }

  Future<List<DulceTipico>> searchDulces(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/dulces?search=${Uri.encodeComponent(query)}'),
        headers: _headers,
      ).timeout(const Duration(seconds: AppConfig.timeoutSeconds));

      _handleError(response);
      
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => DulceTipico.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Si no hay endpoint de búsqueda, filtrar localmente
      final allDulces = await getDulces();
      return allDulces.where((dulce) => 
        dulce.nombre.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }
 
  // Cambiar solo la disponibilidad de un dulce
  Future<bool> toggleDisponibilidadDulce(int id, bool disponible) async {
    try {
      final response = await _client.patch(
        Uri.parse('${AppConfig.baseUrl}/dulces/$id/disponibilidad'),
        headers: _headers,
        body: json.encode({'disponible': disponible}),
      ).timeout(const Duration(seconds: AppConfig.timeoutSeconds));

      _handleError(response);
      return response.statusCode == 200;
    } catch (e) {
      // Fallback: actualizar el dulce completo
      final dulce = await getDulce(id);
      final dulceActualizado = DulceTipico(
        id: dulce.id,
        nombre: dulce.nombre,
        precio: dulce.precio,
        descripcion: dulce.descripcion,
        tipoDulce: dulce.tipoDulce,
        cantidadEnStock: dulce.cantidadEnStock,
        modalidadVenta: dulce.modalidadVenta,
        capacidadCaja: dulce.capacidadCaja,
        precioUnidad: dulce.precioUnidad,
        fechaVencimiento: dulce.fechaVencimiento,
        proveedor: dulce.proveedor,
        ingredientes: dulce.ingredientes,
        pesoGramos: dulce.pesoGramos,
        disponible: disponible,
        fechaCreacion: dulce.fechaCreacion,
        fechaModificacion: DateTime.now(),
      );
      return await updateDulce(id, dulceActualizado);
    }
  }

  // === GUARNICIONES ===
  Future<List<Guarnicion>> getGuarniciones() async {
    return await _getList('guarniciones', Guarnicion.fromJson);
  }

  Future<List<Guarnicion>> getGuarnicionesDisponibles() async {
    return await _getList('guarniciones/disponibles', Guarnicion.fromJson);
  }

  Future<Map<String, dynamic>> createGuarnicion(Guarnicion guarnicion) async {
    return await _post('guarniciones', guarnicion.toJson(), (data) => data);
  }

  Future<bool> updateGuarnicion(int id, Guarnicion guarnicion) async {
    return await _put('guarniciones/$id', guarnicion.toJson());
  }

  Future<bool> deleteGuarnicion(int id) async {
    return await _delete('guarniciones/$id');
  }

  // === COMBOS ===
  Future<List<Combo>> getCombos() async {
    return await _getList('combos', Combo.fromJson);
  }

  Future<Combo> getCombo(int id) async {
    return await _get('combos/$id', Combo.fromJson);
  }

  Future<Map<String, dynamic>> createCombo(Combo combo) async {
    return await _post('combos', combo.toJson(), (data) => data);
  }

  Future<bool> updateCombo(int id, Combo combo) async {
    return await _put('combos/$id', combo.toJson());
  }

  Future<bool> deleteCombo(int id) async {
    return await _delete('combos/$id');
  }

  // === INVENTARIO ===
  Future<List<InventarioItem>> getInventario() async {
    return await _getList('inventario', InventarioItem.fromJson);
  }

  Future<List<InventarioItem>> getInventarioBajoStock() async {
    return await _getList('inventario/bajo-stock', InventarioItem.fromJson);
  }

  Future<InventarioItem> getInventarioItem(int id) async {
    return await _get('inventario/$id', InventarioItem.fromJson);
  }

  Future<Map<String, dynamic>> createInventarioItem(InventarioItem item) async {
    return await _post('inventario', item.toJson(), (data) => data);
  }

  Future<bool> updateInventarioItem(int id, InventarioItem item) async {
    return await _put('inventario/$id/completo', item.toJson());
  }

  Future<bool> updateInventarioStock(int id, double cantidad) async {
    return await _put('inventario/$id', {'cantidad': cantidad});
  }

  Future<bool> deleteInventarioItem(int id) async {
    return await _delete('inventario/$id');
  }

  // === VENTAS ===
  Future<List<Venta>> getVentas() async {
    return await _getList('ventas', Venta.fromJson);
  }

  Future<Venta> getVenta(int id) async {
    return await _get('ventas/$id', Venta.fromJson);
  }

  Future<Map<String, dynamic>> createVenta(Venta venta) async {
    return await _post('ventas', venta.toJson(), (data) => data);
  }

  Future<bool> updateVenta(int id, Venta venta) async {
    return await _put('ventas/$id', venta.toJson());
  }

  Future<bool> deleteVenta(int id) async {
    return await _delete('ventas/$id');
  }

  // === SUCURSALES (NUEVO) ===
  Future<List<Sucursal>> getSucursales() async {
    return await _getList('sucursales', Sucursal.fromJson);
  }

  Future<Sucursal> getSucursal(int id) async {
    return await _get('sucursales/$id', Sucursal.fromJson);
  }

  Future<Map<String, dynamic>> createSucursal(SucursalCreateRequest sucursal) async {
    return await _post('sucursales', sucursal.toJson(), (data) => data);
  }

  Future<bool> updateSucursal(int id, SucursalCreateRequest sucursal) async {
    return await _put('sucursales/$id', sucursal.toJson());
  }

  Future<bool> deleteSucursal(int id) async {
    return await _delete('sucursales/$id');
  }

  Future<Map<String, dynamic>> getSucursalEstadisticas(int id) async {
    return await _get('sucursales/$id/estadisticas', (data) => data);
  }

  // === DASHBOARD ===
  Future<Map<String, dynamic>> getDashboardData() async {
    return await _get('dashboard', (data) => data);
  }

  // === IA  ===
  Future<Map<String, dynamic>> getIAInsights() async {
    return await _get('ia/dashboard-insights', (data) => data);
  }

  Future<Map<String, dynamic>> chatWithIA(String message, String conversationId) async {
    final data = {
      'message': message,
      'conversationId': conversationId,
      'userId': 'mobile_user',
    };
    return await _post('ia/chat', data, (data) => data);
  }

  // === REPORTES ===
  Future<Map<String, dynamic>> getReporteVentas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? sucursalId,
  }) async {
    String endpoint = 'reportes/ventas';
    Map<String, String> queryParams = {};
    
    if (fechaInicio != null) {
      queryParams['fechaInicio'] = fechaInicio.toIso8601String();
    }
    if (fechaFin != null) {
      queryParams['fechaFin'] = fechaFin.toIso8601String();
    }
    if (sucursalId != null) {
      queryParams['sucursalId'] = sucursalId.toString();
    }
    
    if (queryParams.isNotEmpty) {
      endpoint += '?' + queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }
    
    return await _get(endpoint, (data) => data);
  }

  Future<Map<String, dynamic>> getReporteInventario({int? sucursalId}) async {
    String endpoint = 'reportes/inventario';
    if (sucursalId != null) {
      endpoint += '?sucursalId=$sucursalId';
    }
    return await _get(endpoint, (data) => data);
  }

  Future<Map<String, dynamic>> getReporteProductos({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    String endpoint = 'reportes/productos';
    Map<String, String> queryParams = {};
    
    if (fechaInicio != null) {
      queryParams['fechaInicio'] = fechaInicio.toIso8601String();
    }
    if (fechaFin != null) {
      queryParams['fechaFin'] = fechaFin.toIso8601String();
    }
    
    if (queryParams.isNotEmpty) {
      endpoint += '?' + queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }
    
    return await _get(endpoint, (data) => data);
  }

  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse(AppConfig.baseUrl.replaceAll('/api', '')),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}