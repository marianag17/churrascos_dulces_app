import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../models/venta.dart';
import '../../models/churrasco.dart';
import '../../models/dulce.dart';
import '../../models/combo.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class VentaFormScreen extends StatefulWidget {
  final Venta? venta;

  const VentaFormScreen({super.key, this.venta});

  @override
  State<VentaFormScreen> createState() => _VentaFormScreenState();
}

class _VentaFormScreenState extends State<VentaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _notasController = TextEditingController();
  final _numeroMesaController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  
  List<Churrasco> churrascos = [];
  List<DulceTipico> dulces = [];
  List<Combo> combos = [];
  

  List<VentaItemRequest> items = [];
  
  int _tipoVenta = 0; // 0: Local, 1: Domicilio, 2: Eventos
  String _metodoPago = 'Efectivo';
  bool _isLoading = false;
  bool _loadingProducts = true;
  String? _error;

  double get _subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _impuestos => _subtotal * 0.12; // 12% IVA
  double get _total => _subtotal + _impuestos;

  bool get _isEditing => widget.venta != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (_isEditing) {
      _loadVentaData();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
      _error = null;
    });

    try {
      final futures = await Future.wait([
        _apiService.getChurrascos(),
        _apiService.getDulces(),
        _apiService.getCombos(),
      ]);

      setState(() {
        churrascos = (futures[0] as List<Churrasco>).where((c) => c.disponible).toList();
        dulces = (futures[1] as List<DulceTipico>).where((d) => d.disponible).toList();
        combos = (futures[2] as List<Combo>).where((c) => c.disponible).toList();
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingProducts = false;
      });
    }
  }

  void _loadVentaData() {
    final venta = widget.venta!;
    _clienteController.text = venta.nombreCliente ?? '';
    _telefonoController.text = venta.telefonoCliente ?? '';
    _direccionController.text = venta.direccionEntrega ?? '';
    _notasController.text = venta.notasEspeciales ?? '';
    _numeroMesaController.text = venta.numeroMesa?.toString() ?? '';
    _tipoVenta = venta.tipoVenta;
    _metodoPago = venta.metodoPago ?? 'Efectivo';
    
    if (venta.items != null) {
      items = venta.items!.map((item) => VentaItemRequest(
        productoId: item.productoId,
        nombreProducto: item.nombreProducto,
        cantidad: item.cantidad,
        precioUnitario: item.precioUnitario,
        subtotal: item.subtotal,
        categoria: item.categoria ?? 'General',
        notasEspeciales: item.notasEspeciales,
      )).toList();
    }
  }

  @override
  void dispose() {
    _clienteController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _notasController.dispose();
    _numeroMesaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Venta' : 'Nueva Venta'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: _mostrarResumenVenta,
            ),
        ],
      ),
      body: _loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConfig.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildClienteSection(),
                        const SizedBox(height: 24),
                        _buildTipoVentaSection(),
                        const SizedBox(height: 24),
                        _buildProductosSection(),
                        const SizedBox(height: 24),
                        if (items.isNotEmpty) _buildResumenSection(),
                        if (items.isNotEmpty) const SizedBox(height: 32),
                        if (items.isNotEmpty) _buildBotonesGuardar(),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: items.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _mostrarResumenVenta,
              icon: const Icon(Icons.receipt),
              label: Text('Total: ${AppConfig.formatCurrency(_total)}'),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar productos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildClienteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Información del Cliente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clienteController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Cliente *',
                hintText: 'Ej: Juan Pérez',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre del cliente es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                hintText: 'Ej: 2222-1111',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            if (_tipoVenta == 1) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección de Entrega *',
                  hintText: 'Dirección completa para delivery',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: _tipoVenta == 1
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La dirección es requerida para delivery';
                        }
                        return null;
                      }
                    : null,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas Especiales',
                hintText: 'Instrucciones adicionales...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoVentaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Tipo de Venta',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('Local'),
                    subtitle: const Text('En restaurante'),
                    value: 0,
                    groupValue: _tipoVenta,
                    onChanged: (value) {
                      setState(() {
                        _tipoVenta = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('Domicilio'),
                    subtitle: const Text('Delivery'),
                    value: 1,
                    groupValue: _tipoVenta,
                    onChanged: (value) {
                      setState(() {
                        _tipoVenta = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            RadioListTile<int>(
              title: const Text('Eventos'),
              subtitle: const Text('Catering para eventos'),
              value: 2,
              groupValue: _tipoVenta,
              onChanged: (value) {
                setState(() {
                  _tipoVenta = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_tipoVenta == 0) ...[
              TextFormField(
                controller: _numeroMesaController,
                decoration: const InputDecoration(
                  labelText: 'Número de Mesa',
                  hintText: 'Ej: 15',
                  prefixIcon: Icon(Icons.table_restaurant),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<String>(
              value: _metodoPago,
              decoration: const InputDecoration(
                labelText: 'Método de Pago',
                prefixIcon: Icon(Icons.payment),
              ),
              items: const [
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                DropdownMenuItem(value: 'QR', child: Text('Código QR')),
              ],
              onChanged: (value) {
                setState(() {
                  _metodoPago = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.restaurant_menu, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Productos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Churrascos (${churrascos.length})'),
                  Tab(text: 'Dulces (${dulces.length})'),
                  Tab(text: 'Combos (${combos.length})'),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _buildChurrascosTab(),
                    _buildDulcesTab(),
                    _buildCombosTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChurrascosTab() {
    if (churrascos.isEmpty) {
      return const Center(
        child: Text('No hay churrascos disponibles'),
      );
    }

    return ListView.builder(
      itemCount: churrascos.length,
      itemBuilder: (context, index) {
        final churrasco = churrascos[index];
        return _buildProductCard(
          id: churrasco.id,
          nombre: churrasco.nombre,
          precio: churrasco.precio,
          descripcion: churrasco.descripcion,
          categoria: 'Churrasco',
          icon: Icons.restaurant,
          color: AppTheme.primaryColor,
        );
      },
    );
  }

  Widget _buildDulcesTab() {
    if (dulces.isEmpty) {
      return const Center(
        child: Text('No hay dulces disponibles'),
      );
    }

    return ListView.builder(
      itemCount: dulces.length,
      itemBuilder: (context, index) {
        final dulce = dulces[index];
        return _buildProductCard(
          id: dulce.id,
          nombre: dulce.nombre,
          precio: dulce.precio,
          descripcion: dulce.descripcion,
          categoria: 'Dulce',
          icon: Icons.cake,
          color: Colors.orange,
          stock: dulce.cantidadEnStock,
        );
      },
    );
  }

  Widget _buildCombosTab() {
    if (combos.isEmpty) {
      return const Center(
        child: Text('No hay combos disponibles'),
      );
    }

    return ListView.builder(
      itemCount: combos.length,
      itemBuilder: (context, index) {
        final combo = combos[index];
        return _buildProductCard(
          id: combo.id,
          nombre: combo.nombre,
          precio: combo.precio,
          descripcion: combo.descripcion,
          categoria: 'Combo',
          icon: Icons.local_offer,
          color: Colors.purple,
        );
      },
    );
  }

  Widget _buildProductCard({
    required int id,
    required String nombre,
    required double precio,
    String? descripcion,
    required String categoria,
    required IconData icon,
    required Color color,
    int? stock,
  }) {
    final cantidadEnCarrito = items
        .where((item) => item.productoId == id)
        .fold(0, (sum, item) => sum + item.cantidad);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConfig.formatCurrency(precio),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (descripcion != null && descripcion.isNotEmpty)
              Text(
                descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (stock != null)
              Text(
                'Stock: $stock',
                style: TextStyle(
                  color: stock <= 5 ? Colors.red : Colors.green,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cantidadEnCarrito > 0) ...[
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _quitarDelCarrito(id),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cantidadEnCarrito.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: (stock != null && cantidadEnCarrito >= stock)
                  ? null
                  : () => _agregarAlCarrito(
                        id: id,
                        nombre: nombre,
                        precio: precio,
                        categoria: categoria,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Resumen de la Venta',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map(_buildItemResumen).toList(),
            const Divider(),
            _buildResumenRow('Subtotal:', AppConfig.formatCurrency(_subtotal)),
            _buildResumenRow('Impuestos (12%):', AppConfig.formatCurrency(_impuestos)),
            const Divider(),
            _buildResumenRow(
              'Total:',
              AppConfig.formatCurrency(_total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemResumen(VentaItemRequest item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.cantidad}x ${item.nombreProducto}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Q${item.precioUnitario.toStringAsFixed(2)} c/u',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            AppConfig.formatCurrency(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _quitarDelCarrito(item.productoId),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String valor, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesGuardar() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _guardarVenta,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(_isEditing ? 'Actualizar Venta' : 'Crear Venta'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }

  void _agregarAlCarrito({
    required int id,
    required String nombre,
    required double precio,
    required String categoria,
  }) {
    setState(() {
      final existingIndex = items.indexWhere((item) => item.productoId == id);
      
      if (existingIndex >= 0) {
        items[existingIndex] = items[existingIndex].copyWith(
          cantidad: items[existingIndex].cantidad + 1,
          subtotal: (items[existingIndex].cantidad + 1) * precio,
        );
      } else {
        items.add(VentaItemRequest(
          productoId: id,
          nombreProducto: nombre,
          cantidad: 1,
          precioUnitario: precio,
          subtotal: precio,
          categoria: categoria,
        ));
      }
    });
  }

  void _quitarDelCarrito(int productoId) {
    setState(() {
      final existingIndex = items.indexWhere((item) => item.productoId == productoId);
      
      if (existingIndex >= 0) {
        if (items[existingIndex].cantidad > 1) {
          final item = items[existingIndex];
          items[existingIndex] = item.copyWith(
            cantidad: item.cantidad - 1,
            subtotal: (item.cantidad - 1) * item.precioUnitario,
          );
        } else {
          items.removeAt(existingIndex);
        }
      }
    });
  }

  void _mostrarResumenVenta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumen de la Venta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...items.map(_buildItemResumen).toList(),
              const Divider(),
              _buildResumenRow('Subtotal:', AppConfig.formatCurrency(_subtotal)),
              _buildResumenRow('Impuestos:', AppConfig.formatCurrency(_impuestos)),
              _buildResumenRow('Total:', AppConfig.formatCurrency(_total), isTotal: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _guardarVenta() async {
    if (_formKey.currentState!.validate() && items.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final numeroOrden = _isEditing 
            ? widget.venta!.numeroOrden
            : 'ORD-${DateTime.now().millisecondsSinceEpoch}';

        final venta = Venta(
          id: _isEditing ? widget.venta!.id : 0,
          fecha: DateTime.now(),
          subtotal: _subtotal,
          impuestos: _impuestos,
          descuento: 0.0,
          total: _total,
          tipoVenta: _tipoVenta,
          estado: 0, 
          nombreCliente: _clienteController.text.trim(),
          telefonoCliente: _telefonoController.text.trim().isEmpty 
              ? null : _telefonoController.text.trim(),
          direccionEntrega: _direccionController.text.trim().isEmpty 
              ? null : _direccionController.text.trim(),
          numeroMesa: _numeroMesaController.text.trim().isEmpty 
              ? null : int.tryParse(_numeroMesaController.text.trim()),
          metodoPago: _metodoPago,
          notasEspeciales: _notasController.text.trim().isEmpty 
              ? null : _notasController.text.trim(),
          numeroOrden: numeroOrden,
          items: items.map((item) => VentaItem(
            id: 0,
            ventaId: 0,
            productoId: item.productoId,
            nombreProducto: item.nombreProducto,
            cantidad: item.cantidad,
            precioUnitario: item.precioUnitario,
            subtotal: item.subtotal,
            categoria: item.categoria,
            notasEspeciales: item.notasEspeciales,
          )).toList(),
          fechaCreacion: DateTime.now(),
        );

        bool success;

          final result = await _apiService.createVenta(venta);
          success = result.containsKey('id') || result.containsKey('success');
        

        if (success) {
          if (!_isEditing) {
            NotificationService().mostrarNotificacionVenta(
              cliente: _clienteController.text.trim(),
              monto: _total,
              sucursal: 'Sucursal Principal',
              producto: '${items.length} productos',
            );
          }
          
          Navigator.of(context).pop(true);
        } else {
          _showErrorSnackBar('Error al guardar la venta');
        }
      } catch (e) {
        _showErrorSnackBar('Error: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (items.isEmpty) {
      _showErrorSnackBar('Agrega al menos un producto a la venta');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class VentaItemRequest {
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;
  final String categoria;
  final String? notasEspeciales;

  VentaItemRequest({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.categoria,
    this.notasEspeciales,
  });

  VentaItemRequest copyWith({
    int? productoId,
    String? nombreProducto,
    int? cantidad,
    double? precioUnitario,
    double? subtotal,
    String? categoria,
    String? notasEspeciales,
  }) {
    return VentaItemRequest(
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      categoria: categoria ?? this.categoria,
      notasEspeciales: notasEspeciales ?? this.notasEspeciales,
    );
  }
}