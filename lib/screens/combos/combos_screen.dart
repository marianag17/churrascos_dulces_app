import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../models/combo.dart';
import 'combo_form_screen.dart';
import 'combo_detail_screen.dart';

class CombosScreen extends ConsumerStatefulWidget {
  const CombosScreen({super.key});

  @override
  ConsumerState<CombosScreen> createState() => _CombosScreenState();
}

class _CombosScreenState extends ConsumerState<CombosScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  List<Combo> combos = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCombos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCombos() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final combosFromApi = await _apiService.getCombos();
      setState(() {
        combos = combosFromApi;
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
            const Text('Combos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCombos,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.all_inclusive),
              text: 'Todos (${combos.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Activos (${combos.where((c) => c.disponible && c.estaVigente).length})',
            ),
            Tab(
              icon: const Icon(Icons.schedule),
              text: 'Temporada (${combos.where((c) => c.esTemporada).length})',
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCombos,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCombosTab(combos), // todos
                      _buildCombosTab(combos.where((c) => c.disponible && c.estaVigente).toList()), // sctivos
                      _buildCombosTab(combos.where((c) => c.esTemporada).toList()), // temporada
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevoCombo,
        child: const Icon(Icons.add),
        tooltip: 'Nuevo Combo',
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
            'Error al cargar combos',
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
            onPressed: _loadCombos,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCombosTab(List<Combo> combosList) {
    if (combosList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay combos disponibles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar el primer combo',
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
          _buildTipoFilters(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: combosList.length,
              itemBuilder: (context, index) {
                final combo = combosList[index];
                return _buildComboCard(combo);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final activos = combos.where((c) => c.disponible && c.estaVigente).length;
    final temporada = combos.where((c) => c.esTemporada).length;
    final vencidos = combos.where((c) => !c.estaVigente && c.esTemporada).length;
    final promedioDescuento = combos.isNotEmpty
        ? combos.map((c) => c.porcentajeDescuento).reduce((a, b) => a + b) / combos.length
        : 0.0;

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            icon: Icons.check_circle,
            title: 'Activos',
            value: activos.toString(),
            color: Colors.green,
            width: 120,
          ),
          _buildStatCard(
            icon: Icons.schedule,
            title: 'Temporada',
            value: temporada.toString(),
            color: Colors.blue,
            width: 120,
          ),
          _buildStatCard(
            icon: Icons.warning,
            title: 'Vencidos',
            value: vencidos.toString(),
            color: vencidos > 0 ? Colors.red : Colors.green,
            width: 120,
          ),
          _buildStatCard(
            icon: Icons.percent,
            title: 'Desc. Promedio',
            value: '${promedioDescuento.toStringAsFixed(1)}%',
            color: Colors.purple,
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

  Widget _buildTipoFilters() {
    final tiposCombos = AppConfig.tiposCombos;
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tiposCombos.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Todos'),
                selected: true,
                onSelected: (selected) {},
              ),
            );
          }
          
          final tipoIndex = index - 1;
          final tipoNombre = tiposCombos[tipoIndex]!;
          final cantidad = combos.where((c) => c.tipoCombo == tipoIndex).length;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('$tipoNombre ($cantidad)'),
              selected: false,
              onSelected: (selected) {
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildComboCard(Combo combo) {
    final bool isVigente = combo.estaVigente;
    final Color statusColor = isVigente ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: Icon(
            Icons.local_offer,
            color: isVigente ? Colors.purple : Colors.grey,
          ),
        ),
        title: Text(
          combo.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isVigente ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConfig.formatCurrency(combo.precio),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(combo.tipoComboTexto),
            Row(
              children: [
                if (combo.porcentajeDescuento > 0)
                  Text('${combo.porcentajeDescuento.toStringAsFixed(0)}% desc.'),
                if (combo.porcentajeDescuento > 0 && combo.montoDescuento > 0)
                  const Text(' + '),
                if (combo.montoDescuento > 0)
                  Text('${AppConfig.formatCurrency(combo.montoDescuento)} desc.'),
              ],
            ),
            if (combo.esTemporada && combo.fechaFinVigencia != null)
              Text(
                'Vence: ${_formatDate(combo.fechaFinVigencia!)}',
                style: TextStyle(
                  color: isVigente ? Colors.orange : Colors.red,
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
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isVigente ? 'Vigente' : 'Vencido',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (combo.esTemporada)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Temporada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _verDetalleCombo(combo),
      ),
    );
  }


  void _nuevoCombo() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ComboFormScreen(),
      ),
    );

    if (result == true) {
      _loadCombos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Combo creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _verDetalleCombo(Combo combo) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => ComboDetailScreen(combo: combo),
      ),
    );

    if (result == 'updated' || result == 'deleted') {
      _loadCombos();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}