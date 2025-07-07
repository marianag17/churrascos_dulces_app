import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../models/venta.dart';
import 'venta_form_screen.dart';
import 'venta_detail_screen.dart';

class VentasScreen extends ConsumerStatefulWidget {
  const VentasScreen({super.key});

  @override
  ConsumerState<VentasScreen> createState() => _VentasScreenState();
}

class _VentasScreenState extends ConsumerState<VentasScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  List<Venta> ventas = [];
  List<Venta> ventasFiltradas = [];
  bool isLoading = true;
  String? error;
  int _filtroEstado = -1; // -1 = todas
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVentas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVentas() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final ventasFromApi = await _apiService.getVentas();
      setState(() {
        ventas = ventasFromApi;
        _aplicarFiltros();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _aplicarFiltros() {
    ventasFiltradas = ventas.where((venta) {
      bool coincideFiltro = _filtroEstado == -1 || venta.estado == _filtroEstado;
      bool coincideBusqueda = _busqueda.isEmpty ||
          venta.nombreCliente?.toLowerCase().contains(_busqueda.toLowerCase()) == true ||
          venta.numeroOrden.toLowerCase().contains(_busqueda.toLowerCase());
      return coincideFiltro && coincideBusqueda;
    }).toList();

    ventasFiltradas.sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('Ventas'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVentas,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.all_inclusive),
              text: 'Todas (${ventas.length})',
            ),
            Tab(
              icon: const Icon(Icons.pending),
              text: 'Pendientes (${ventas.where((v) => v.estado == 0).length})',
            ),
            Tab(
              icon: const Icon(Icons.schedule),
              text: 'En Proceso (${ventas.where((v) => v.estado == 1 || v.estado == 2).length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Completadas (${ventas.where((v) => v.estado == 3).length})',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadVentas,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVentasTab(-1), 
                      _buildVentasTab(0),  
                      _buildVentasTab([1, 2]), 
                      _buildVentasTab(3),  
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevaVenta,
        child: const Icon(Icons.add),
        tooltip: 'Nueva Venta',
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
            'Error al cargar ventas',
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
            onPressed: _loadVentas,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildVentasTab(dynamic filtroEstado) {
    List<Venta> ventasTab;
    
    if (filtroEstado == -1) {
      ventasTab = ventasFiltradas;
    } else if (filtroEstado is List) {
      ventasTab = ventasFiltradas.where((v) => filtroEstado.contains(v.estado)).toList();
    } else {
      ventasTab = ventasFiltradas.where((v) => v.estado == filtroEstado).toList();
    }

    if (ventasTab.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ventas registradas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para crear la primera venta',
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
          if (filtroEstado == -1) _buildStatsCards(),
          if (filtroEstado == -1) const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: ventasTab.length,
              itemBuilder: (context, index) {
                final venta = ventasTab[index];
                return _buildVentaCard(venta);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final ventasHoy = ventas.where((v) {
      final hoy = DateTime.now();
      return v.fecha.day == hoy.day && 
             v.fecha.month == hoy.month && 
             v.fecha.year == hoy.year;
    }).length;

    final ingresosDia = ventas.where((v) {
      final hoy = DateTime.now();
      return v.fecha.day == hoy.day && 
             v.fecha.month == hoy.month && 
             v.fecha.year == hoy.year &&
             v.estado == 3; 
    }).fold(0.0, (sum, v) => sum + v.total);

    final promedioVenta = ventas.isNotEmpty
        ? ventas.where((v) => v.estado == 3).fold(0.0, (sum, v) => sum + v.total) / 
          ventas.where((v) => v.estado == 3).length
        : 0.0;

    final pendientes = ventas.where((v) => v.estado == 0).length;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            icon: Icons.today,
            title: 'Ventas Hoy',
            value: ventasHoy.toString(),
            color: Colors.blue,
            width: 120,
          ),
          _buildStatCard(
            icon: Icons.monetization_on,
            title: 'Ingresos Día',
            value: AppConfig.formatCurrency(ingresosDia),
            color: Colors.green,
            width: 140,
          ),
          _buildStatCard(
            icon: Icons.trending_up,
            title: 'Promedio',
            value: AppConfig.formatCurrency(promedioVenta),
            color: Colors.purple,
            width: 130,
          ),
          _buildStatCard(
            icon: Icons.pending,
            title: 'Pendientes',
            value: pendientes.toString(),
            color: pendientes > 0 ? Colors.orange : Colors.green,
            width: 120,
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
              Icon(icon, color: color, size: 24),
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

  Widget _buildVentaCard(Venta venta) {
    final Color statusColor = _getStatusColor(venta.estado);
    final IconData statusIcon = _getStatusIcon(venta.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Orden #${venta.numeroOrden}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                venta.estadoTexto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (venta.nombreCliente != null)
              Text('Cliente: ${venta.nombreCliente}'),
            Text(
              'Total: ${AppConfig.formatCurrency(venta.total)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getTipoVentaIcon(venta.tipoVenta),
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(venta.tipoVentaTexto),
                const Spacer(),
                Text(
                  _formatFecha(venta.fecha),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (venta.cantidadItems > 0)
              Text(
                '${venta.cantidadItems} item${venta.cantidadItems != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onMenuSelected(value, venta),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ver',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Ver Detalles'),
                ],
              ),
            ),
            if (venta.estado < 3)
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
            if (venta.estado == 0)
              const PopupMenuItem(
                value: 'procesar',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 8),
                    Text('Procesar'),
                  ],
                ),
              ),
            if (venta.estado == 2) 
              const PopupMenuItem(
                value: 'completar',
                child: Row(
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text('Completar'),
                  ],
                ),
              ),
            if (venta.estado < 3) 
              const PopupMenuItem(
                value: 'cancelar',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cancelar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _verDetalleVenta(venta),
      ),
    );
  }

  Color _getStatusColor(int estado) {
    switch (estado) {
      case 0: return Colors.orange; 
      case 1: return Colors.blue;   
      case 2: return Colors.purple; 
      case 3: return Colors.green;  
      case 4: return Colors.red;    
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(int estado) {
    switch (estado) {
      case 0: return Icons.schedule;      
      default: return Icons.help;
    }
  }

  IconData _getTipoVentaIcon(int tipo) {
    switch (tipo) {
      case 0: return Icons.store;          
      case 1: return Icons.delivery_dining;
      case 2: return Icons.event;          
      default: return Icons.point_of_sale;
    }
  }

  String _formatFecha(DateTime fecha) {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inDays == 0) {
      return 'Hoy ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchText = _busqueda;
        return AlertDialog(
          title: const Text('Buscar Ventas'),
          content: TextField(
            onChanged: (value) => searchText = value,
            decoration: const InputDecoration(
              hintText: 'Buscar por cliente o número de orden...',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _busqueda = searchText;
                  _aplicarFiltros();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedFilter = _filtroEstado;
        return AlertDialog(
          title: const Text('Filtrar por Estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: const Text('Todas'),
                value: -1,
                groupValue: selectedFilter,
                onChanged: (value) => selectedFilter = value!,
              ),
              RadioListTile<int>(
                title: const Text('Pendientes'),
                value: 0,
                groupValue: selectedFilter,
                onChanged: (value) => selectedFilter = value!,
              ),
              RadioListTile<int>(
                title: const Text('Preparando'),
                value: 1,
                groupValue: selectedFilter,
                onChanged: (value) => selectedFilter = value!,
              ),
              RadioListTile<int>(
                title: const Text('Listo'),
                value: 2,
                groupValue: selectedFilter,
                onChanged: (value) => selectedFilter = value!,
              ),
              RadioListTile<int>(
                title: const Text('Entregado'),
                value: 3,
                groupValue: selectedFilter,
                onChanged: (value) => selectedFilter = value!,
              ),
              RadioListTile<int>(
                title: const Text('Cancelado'),
                value: 4,
                groupValue: selectedFilter,
                onChanged: (value) => selectedFilter = value!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filtroEstado = selectedFilter;
                  _aplicarFiltros();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
  }

  void _nuevaVenta() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const VentaFormScreen(),
      ),
    );

    if (result == true) {
      _loadVentas();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Venta creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _verDetalleVenta(Venta venta) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => VentaDetailScreen(venta: venta),
      ),
    );

    if (result == 'updated' || result == 'deleted') {
      _loadVentas();
    }
  }

  void _onMenuSelected(String value, Venta venta) async {
    switch (value) {
      case 'ver':
        _verDetalleVenta(venta);
        break;
      case 'editar':
        _editarVenta(venta);
        break;
      case 'cancelar':
        _confirmarCancelarVenta(venta);
        break;
    }
  }

  void _editarVenta(Venta venta) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => VentaFormScreen(venta: venta),
      ),
    );

    if (result == true) {
      _loadVentas();
    }
  }

  

  void _confirmarCancelarVenta(Venta venta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Venta'),
        content: Text('¿Estás seguro de que deseas cancelar la orden #${venta.numeroOrden}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

}