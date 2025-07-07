import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/sucursal.dart';
import 'sucursal_form_screen.dart';
import 'sucursal_detail_screen.dart';

class SucursalesScreen extends ConsumerStatefulWidget {
  const SucursalesScreen({super.key});

  @override
  ConsumerState<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends ConsumerState<SucursalesScreen> {
  final ApiService _apiService = ApiService();
  
  List<Sucursal> sucursales = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadSucursales();
  }

  Future<void> _loadSucursales() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final sucursalesFromDb = await _apiService.getSucursales();
      
      setState(() {
        sucursales = sucursalesFromDb;
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
            const Text('Sucursales'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSucursales,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSucursales,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : _buildSucursalesList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarSucursal,
        child: const Icon(Icons.add),
        tooltip: 'Agregar Sucursal',
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
            'Error al cargar sucursales',
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
            onPressed: _loadSucursales,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSucursalesList() {
    if (sucursales.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay sucursales registradas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar tu primera sucursal',
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
          Expanded(
            child: ListView.builder(
              itemCount: sucursales.length,
              itemBuilder: (context, index) {
                final sucursal = sucursales[index];
                return _buildSucursalCard(sucursal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final activas = sucursales.where((s) => s.activa).length;
    final inactivas = sucursales.length - activas;
    final abiertas = sucursales.where((s) => s.activa && s.estaAbierta).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.store,
            title: 'Activas',
            value: activas.toString(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.store_mall_directory,
            title: 'Inactivas',
            value: inactivas.toString(),
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            title: 'Abiertas',
            value: abiertas.toString(),
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSucursalCard(Sucursal sucursal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sucursal.activa 
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Icon(
            Icons.store,
            color: sucursal.activa ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          sucursal.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sucursal.direccion.isNotEmpty) Text(sucursal.direccion),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  sucursal.estaAbierta ? Icons.access_time : Icons.access_time_filled,
                  size: 16,
                  color: sucursal.estaAbierta ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  sucursal.estaAbierta ? 'Abierta' : 'Cerrada',
                  style: TextStyle(
                    color: sucursal.estaAbierta ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (sucursal.horarioApertura != null && sucursal.horarioCierre != null)
                  Text(
                    '${sucursal.horarioApertura} - ${sucursal.horarioCierre}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: sucursal.activa ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                sucursal.activa ? 'Activa' : 'Inactiva',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _verDetalleSucursal(sucursal),
      ),
    );
  }

  void _agregarSucursal() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const SucursalFormScreen(),
      ),
    );

    if (result == true) {
      _loadSucursales(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sucursal agregada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _verDetalleSucursal(Sucursal sucursal) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => SucursalDetailScreen(sucursal: sucursal),
      ),
    );

    if (result == 'updated' || result == 'deleted') {
      _loadSucursales(); 
    }
  }

}