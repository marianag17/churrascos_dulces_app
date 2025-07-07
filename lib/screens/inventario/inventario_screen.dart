import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../models/inventario.dart';
import '../../services/notification_service.dart';
import 'inventario_form_screen.dart';

class InventarioScreen extends ConsumerStatefulWidget {
  const InventarioScreen({super.key});

  @override
  ConsumerState<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends ConsumerState<InventarioScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  List<InventarioItem> inventario = [];
  List<InventarioItem> stockBajo = [];
  bool isLoading = true;
  String? error;
  int _filtroTipo = -1; // -1 = todos

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInventario();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInventario() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final futures = await Future.wait([
        _apiService.getInventario(),
        _apiService.getInventarioBajoStock(),
      ]);

      setState(() {
        inventario = futures[0];
        stockBajo = futures[1];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('Inventario'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventario,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.inventory),
              text: 'Todos (${inventario.length})',
            ),
            Tab(
              icon: const Icon(Icons.warning),
              text: 'Stock Bajo (${stockBajo.length})',
            ),
            Tab(
              icon: const Icon(Icons.analytics),
              text: 'Estadísticas',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInventario,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildInventarioTab(),
                      _buildStockBajoTab(),
                      _buildEstadisticasTab(),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _nuevoItem(),
        child: const Icon(Icons.add),
        tooltip: 'Agregar Item',
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
            'Error al cargar inventario',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInventario,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInventarioTab() {
    final inventarioFiltrado = _filtroTipo == -1 
        ? inventario 
        : inventario.where((item) => item.tipo == _filtroTipo).toList();

    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        children: [
          _buildStatsCardsInventario(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: inventarioFiltrado.length,
              itemBuilder: (context, index) {
                final item = inventarioFiltrado[index];
                return _buildInventarioCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBajoTab() {
    if (stockBajo.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green[400],
            ),
            const SizedBox(height: 16),
            Text(
              '¡Perfecto!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay items con stock bajo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Atención requerida',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        '${stockBajo.length} items requieren reposición',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: stockBajo.length,
              itemBuilder: (context, index) {
                final item = stockBajo[index];
                return _buildStockBajoCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasTab() {
    final totalItems = inventario.length;
    final totalValor = inventario.fold(0.0, (sum, item) => 
        sum + (item.cantidad * item.precioUnitario).toDouble());
    final itemsPorTipo = <int, int>{};
    
    for (final item in inventario) {
      itemsPorTipo[item.tipo] = (itemsPorTipo[item.tipo] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadisticaCard(
              'Resumen General',
              [
                _buildEstadisticaRow('Total de Items', totalItems.toString()),
                _buildEstadisticaRow('Valor Total', AppConfig.formatCurrency(totalValor)),
                _buildEstadisticaRow('Stock Crítico', stockBajo.length.toString()),
                _buildEstadisticaRow('Items Activos', 
                    inventario.where((i) => i.activo).length.toString()),
              ],
            ),
            const SizedBox(height: 16),
            _buildEstadisticaCard(
              'Por Categoría',
              itemsPorTipo.entries.map((entry) => 
                _buildEstadisticaRow(
                  AppConfig.getInventoryTypeLabel(entry.key),
                  entry.value.toString(),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCardsInventario() {
    final totalItems = inventario.length;
    final stockCritico = inventario.where((item) => item.stockCritico).length;
    final vencidos = inventario.where((item) => item.estaVencido).length;
    final valorTotal = inventario.fold(0.0, (sum, item) => 
        sum + (item.cantidad * item.precioUnitario).toDouble());

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            icon: Icons.inventory_2,
            title: 'Total Items',
            value: totalItems.toString(),
            color: Colors.blue,
            width: 120,
          ),
          _buildStatCard(
            icon: Icons.warning,
            title: 'Stock Crítico',
            value: stockCritico.toString(),
            color: stockCritico > 0 ? Colors.red : Colors.green,
            width: 120,
          ),
          _buildStatCard(
            icon: Icons.access_time,
            title: 'Vencidos',
            value: vencidos.toString(),
            color: vencidos > 0 ? Colors.red : Colors.green,
            width: 120,
          ),
          _buildStatCard(
            icon: Icons.monetization_on,
            title: 'Valor Total',
            value: AppConfig.formatCurrency(valorTotal),
            color: Colors.green,
            width: 140,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildInventarioCard(InventarioItem item) {
    final porcentajeStock = item.stockMaximo > 0 
        ? (item.cantidad / item.stockMaximo).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForTipo(item.tipo).withOpacity(0.1),
          child: Icon(
            _getIconForTipo(item.tipo),
            color: _getColorForTipo(item.tipo),
          ),
        ),
        title: Text(
          item.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.tipoTexto),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${item.cantidad.toStringAsFixed(1)} ${item.unidad}'),
                const SizedBox(width: 8),
                Text('• ${AppConfig.formatCurrency(item.precioUnitario.toDouble())}'),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: porcentajeStock,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                item.stockCritico ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Min: ${item.stockMinimo} | Max: ${item.stockMaximo}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.stockCritico)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Crítico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (item.proximoAVencer)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Por vencer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (!item.activo)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Inactivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _showInventarioDialog(item: item),
      ),
    );
  }

  Widget _buildStockBajoCard(InventarioItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.1),
          child: const Icon(
            Icons.warning,
            color: Colors.red,
          ),
        ),
        title: Text(
          item.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.tipoTexto),
            const SizedBox(height: 4),
            Text(
              'Stock actual: ${item.cantidad.toStringAsFixed(1)} ${item.unidad}',
              style: const TextStyle(color: Colors.red),
            ),
            Text('Mínimo requerido: ${item.stockMinimo}'),
            Text('Punto de reorden: ${item.puntoReorden}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _reabastecer(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
          ),
          child: const Text('Reabastecer'),
        ),
        onTap: () => _showInventarioDialog(item: item),
      ),
    );
  }

  Widget _buildEstadisticaCard(String titulo, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _nuevoItem() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const InventarioFormScreen(),
      ),
    );

    if (result == true) {
      _loadInventario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item agregado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showInventarioDialog({InventarioItem? item}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Nuevo Item de Inventario' : 'Detalles del Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item != null) ...[
                _buildDetailRow('Nombre', item.nombre),
                _buildDetailRow('Tipo', item.tipoTexto),
                _buildDetailRow('Cantidad', '${item.cantidad.toStringAsFixed(1)} ${item.unidad}'),
                _buildDetailRow('Precio Unitario', AppConfig.formatCurrency(item.precioUnitario.toDouble())),
                _buildDetailRow('Stock Mínimo', item.stockMinimo.toString()),
                _buildDetailRow('Stock Máximo', item.stockMaximo.toString()),
                _buildDetailRow('Punto de Reorden', item.puntoReorden.toString()),
                if (item.proveedor != null && item.proveedor!.isNotEmpty)
                  _buildDetailRow('Proveedor', item.proveedor!),
                if (item.codigoProveedor != null && item.codigoProveedor!.isNotEmpty)
                  _buildDetailRow('Código Proveedor', item.codigoProveedor!),
                if (item.fechaVencimiento != null)
                  _buildDetailRow('Vencimiento', _formatDate(item.fechaVencimiento!)),
                if (item.ubicacionAlmacen != null && item.ubicacionAlmacen!.isNotEmpty)
                  _buildDetailRow('Ubicación', item.ubicacionAlmacen!),
                _buildDetailRow('Estado', item.activo ? 'Activo' : 'Inactivo'),
                _buildDetailRow('Última Actualización', _formatDate(item.ultimaActualizacion)),
              ] else
                const Text('Funcionalidad de crear/editar próximamente...'),
            ],
          ),
        ),
        actions: [
          if (item != null && item.stockCritico)
            TextButton(
              onPressed: () {
                NotificationService().mostrarNotificacionStockBajo(
                  producto: item.nombre,
                  cantidadActual: item.cantidad.toInt(),
                  stockMinimo: item.stockMinimo.toInt(),
                  sucursal: 'Sucursal Principal',
                );
                Navigator.of(context).pop();
              },
              child: const Text('Notificar'),
            ),
          if (item != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editarItem(item);
              },
              child: const Text('Editar'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _reabastecer(InventarioItem item) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Reabastecer ${item.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Stock actual: ${item.cantidad.toStringAsFixed(1)} ${item.unidad}'),
              Text('Stock mínimo: ${item.stockMinimo}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cantidad a agregar (${item.unidad})',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final cantidad = double.tryParse(controller.text);
                if (cantidad != null && cantidad > 0) {
                  try {
                    final nuevaCantidad = item.cantidad + cantidad;
                    final success = await _apiService.updateInventarioStock(item.id, nuevaCantidad);
                    
                    if (success) {
                      Navigator.of(context).pop();
                      _loadInventario();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Stock actualizado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error al actualizar stock'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa una cantidad válida'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Reabastecer'),
            ),
          ],
        );
      },
    );
  }

  void _editarItem(InventarioItem item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => InventarioFormScreen(item: item),
      ),
    );

    if (result == true) {
      _loadInventario();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Color _getColorForTipo(int tipo) {
    switch (tipo) {
      case 0: return Colors.red; // Carne
      case 1: return Colors.green; // Guarnición
      case 2: return Colors.orange; // Dulce
      case 3: return Colors.brown; // Empaque
      case 4: return Colors.grey; // Combustible
      default: return Colors.blue;
    }
  }

  IconData _getIconForTipo(int tipo) {
    switch (tipo) {
      case 0: return Icons.restaurant; // Carne
      case 1: return Icons.local_dining; // Guarnición
      case 2: return Icons.cake; // Dulce
      case 3: return Icons.inventory_2; // Empaque
      case 4: return Icons.local_fire_department; // Combustible
      default: return Icons.inventory;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}