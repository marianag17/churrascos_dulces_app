import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../models/dulce.dart';
import '../../services/notification_service.dart';
import 'dulce_form_screen.dart';
import 'dulce_detail_screen.dart';

class DulcesScreen extends ConsumerStatefulWidget {
  const DulcesScreen({super.key});

  @override
  ConsumerState<DulcesScreen> createState() => _DulcesScreenState();
}

class _DulcesScreenState extends ConsumerState<DulcesScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  List<DulceTipico> dulces = [];
  List<DulceTipico> dulcesFiltrados = [];
  bool isLoading = true;
  String? error;
  int _filtroActual = -1; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
     WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NotificationService().init(context);
      }
    });
    _loadDulces();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDulces() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final dulcesFromApi = await _apiService.getDulces();
      setState(() {
        dulces = dulcesFromApi;
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
    if (_filtroActual == -1) {
      dulcesFiltrados = List.from(dulces);
    } else {
      dulcesFiltrados = dulces.where((d) => d.tipoDulce == _filtroActual).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('Dulces Típicos'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.all_inclusive),
              text: 'Todos (${dulces.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Disponibles (${dulces.where((d) => d.disponible).length})',
            ),
            Tab(
              icon: const Icon(Icons.warning),
              text: 'Críticos (${dulces.where((d) => d.stockCritico || d.isVencido).length})',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDulces,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDulcesTab(dulcesFiltrados), // todos
                      _buildDulcesTab(dulcesFiltrados.where((d) => d.disponible).toList()), // dsponibles
                      _buildDulcesTab(dulcesFiltrados.where((d) => d.stockCritico || d.isVencido).toList()), //críticos
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevoDulce,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        tooltip: 'Agregar Dulce',
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
            'Error al cargar dulces',
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
            onPressed: _loadDulces,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDulcesTab(List<DulceTipico> dulcesList) {
    if (dulcesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cake,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay dulces en esta categoría',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar el primer dulce',
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
          _buildStatsCards(),
          const SizedBox(height: 16),
          _buildCategoryFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: dulcesList.length,
              itemBuilder: (context, index) {
                final dulce = dulcesList[index];
                return _buildDulceCard(dulce);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final disponibles = dulces.where((d) => d.disponible).length;
    final stockCritico = dulces.where((d) => d.stockCritico).length;
    final vencidos = dulces.where((d) => d.isVencido).length;
    final valorTotal = dulces.fold(0.0, (sum, d) => sum + (d.precioUnidad * d.cantidadEnStock));

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            icon: Icons.check_circle,
            title: 'Disponibles',
            value: disponibles.toString(),
            color: Colors.green,
            width: 120,
          ),
          _buildStatCard(
            icon: Icons.warning,
            title: 'Stock Crítico',
            value: stockCritico.toString(),
            color: stockCritico > 0 ? Colors.orange : Colors.green,
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
            color: Colors.blue,
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

  Widget _buildCategoryFilters() {
    final tiposDulces = AppConfig.tiposDulce;
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tiposDulces.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Todos'),
                selected: _filtroActual == -1,
                onSelected: (selected) {
                  setState(() {
                    _filtroActual = -1;
                    _aplicarFiltros();
                  });
                },
              ),
            );
          }
          
          final tipoIndex = index - 1;
          final tipoNombre = tiposDulces[tipoIndex]!;
          final cantidad = dulces.where((d) => d.tipoDulce == tipoIndex).length;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('$tipoNombre ($cantidad)'),
              selected: _filtroActual == tipoIndex,
              onSelected: (selected) {
                setState(() {
                  _filtroActual = selected ? tipoIndex : -1;
                  _aplicarFiltros();
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDulceCard(DulceTipico dulce) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: dulce.disponible 
              ? Colors.orange.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
        ),
        title: Text(
          dulce.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: dulce.disponible ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConfig.formatCurrency(dulce.precio),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(dulce.tipoDulceTexto),
            Row(
              children: [
                Text('Stock: ${dulce.cantidadEnStock}'),
                const SizedBox(width: 8),
                Text('• ${dulce.modalidadVentaTexto}'),
              ],
            ),
            if (dulce.fechaVencimiento != null)
              Text(
                'Vence: ${_formatDate(dulce.fechaVencimiento!)}',
                style: TextStyle(
                  color: dulce.isVencido ? Colors.red : Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: dulce.disponible ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dulce.disponible ? 'Disponible' : 'No disponible',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (dulce.stockCritico || dulce.isVencido)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: dulce.isVencido ? Colors.red : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dulce.isVencido ? 'Vencido' : 'Stock Bajo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _verDetalleDulce(dulce),
        onLongPress: () => _mostrarOpcionesRapidas(dulce),
      ),
    );
  }


  
  void _mostrarOpcionesRapidas(DulceTipico dulce) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Ver Detalles'),
              onTap: () {
                Navigator.of(context).pop();
                _verDetalleDulce(dulce);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.of(context).pop();
                _editarDulce(dulce);
              },
            ),
            if (dulce.stockCritico)
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.orange),
                title: const Text('Notificar Stock Bajo'),
                onTap: () {
                  Navigator.of(context).pop();
                  NotificationService().mostrarNotificacionStockBajo(
                    producto: dulce.nombre,
                    cantidadActual: dulce.cantidadEnStock,
                    stockMinimo: 5,
                    sucursal: 'Sucursal Principal',
                  );
                },
              ),
            ListTile(
              leading: Icon(
                dulce.disponible ? Icons.visibility_off : Icons.visibility,
                color: dulce.disponible ? Colors.orange : Colors.green,
              ),
              title: Text(dulce.disponible ? 'Desactivar' : 'Activar'),
              onTap: () {
                Navigator.of(context).pop();
                _cambiarDisponibilidad(dulce);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicar'),
              onTap: () {
                Navigator.of(context).pop();
                _duplicarDulce(dulce);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _confirmarEliminar(dulce);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _nuevoDulce() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const DulceFormScreen(),
      ),
    );

    if (result == true) {
      _loadDulces();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dulce creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _verDetalleDulce(DulceTipico dulce) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => DulceDetailScreen(dulce: dulce),
      ),
    );

    if (result == 'updated' || result == 'deleted') {
      _loadDulces();
    }
  }

  void _editarDulce(DulceTipico dulce) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => DulceFormScreen(dulce: dulce),
      ),
    );

    if (result == true) {
      _loadDulces();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dulce actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cambiarDisponibilidad(DulceTipico dulce) async {
    try {
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
        disponible: !dulce.disponible,
        fechaCreacion: dulce.fechaCreacion,
        fechaModificacion: DateTime.now(),
      );

      final success = await _apiService.updateDulce(dulce.id, dulceActualizado);
      
      if (success) {
        _loadDulces();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dulceActualizado.disponible 
                ? 'Dulce activado' 
                : 'Dulce desactivado'),
            backgroundColor: dulceActualizado.disponible ? Colors.green : Colors.orange,
          ),
        );
      } else {
        _showErrorSnackBar('Error al cambiar el estado');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _duplicarDulce(DulceTipico dulce) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => DulceFormScreen(
          dulce: DulceTipico(
            id: 0,
            nombre: '${dulce.nombre} (Copia)',
            precio: dulce.precio,
            descripcion: dulce.descripcion,
            tipoDulce: dulce.tipoDulce,
            cantidadEnStock: 0,
            modalidadVenta: dulce.modalidadVenta,
            capacidadCaja: dulce.capacidadCaja,
            precioUnidad: dulce.precioUnidad,
            fechaVencimiento: null,
            proveedor: dulce.proveedor,
            ingredientes: dulce.ingredientes,
            pesoGramos: dulce.pesoGramos,
            disponible: true,
            fechaCreacion: DateTime.now(),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadDulces();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dulce duplicado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmarEliminar(DulceTipico dulce) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Dulce'),
        content: Text('¿Estás seguro de que deseas eliminar "${dulce.nombre}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                final success = await _apiService.deleteDulce(dulce.id);
                if (success) {
                  _loadDulces();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dulce eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  _showErrorSnackBar('Error al eliminar el dulce');
                }
              } catch (e) {
                _showErrorSnackBar('Error: ${e.toString()}');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}