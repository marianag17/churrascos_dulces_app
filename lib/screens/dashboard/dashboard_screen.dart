import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../models/churrasco.dart';
import '../../models/dulce.dart';
import '../../models/combo.dart';
import '../../models/venta.dart';
import '../../models/inventario.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/ia_dashboard_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  
  Map<String, dynamic> dashboardData = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadDashboardData();
  }

  void _initializeServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notificationService.init(context);
        _notificationService.addListener(_onNotificationUpdate);
        
      }
    });
  }

  @override
  void dispose() {
    _notificationService.removeListener(_onNotificationUpdate);
    super.dispose();
  }

  void _onNotificationUpdate() {
    if (mounted) {
      setState(() {}); 
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final futures = await Future.wait([
        _apiService.getChurrascos(),
        _apiService.getDulces(),
        _apiService.getCombos(),
        _apiService.getVentas(),
        _apiService.getInventario(),
      ]);

      setState(() {
        dashboardData = {
          'churrascos': futures[0] as List<Churrasco>,
          'dulces': futures[1] as List<DulceTipico>, 
          'combos': futures[2] as List<Combo>,
          'ventas': futures[3] as List<Venta>,
          'inventario': futures[4] as List<InventarioItem>,
        };
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
            const Text('Dashboard'),
          ],
        ),
        actions: [
          _buildNotificationButton(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : _buildDashboard(),
      ),
    );
  }

  Widget _buildNotificationButton() {
    final notificacionesNoLeidas = _notificationService.cantidadNoLeidas;
    
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _showNotificationsScreen,
          tooltip: 'Notificaciones',
        ),
        if (notificacionesNoLeidas > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                notificacionesNoLeidas > 99 ? '99+' : notificacionesNoLeidas.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
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
            'Error al cargar datos',
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
            onPressed: _loadDashboardData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          const IADashboardWidget(),
          const SizedBox(height: 20),
          _buildNotificationsSummary(),
          const SizedBox(height: 20),
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildChartsSection(),
          const SizedBox(height: 20),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildNotificationsSummary() {
    final totalNotifications = _notificationService.notificaciones.length;
    final unreadNotifications = _notificationService.cantidadNoLeidas;
    final recentNotifications = _notificationService.notificaciones.take(3).toList();

    if (totalNotifications == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Centro de Notificaciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (unreadNotifications > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadNotifications nueva${unreadNotifications > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          
            ...recentNotifications.map((notification) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      _getIconForNotificationType(notification.tipo),
                      size: 16,
                      color: _getColorForNotificationType(notification.tipo),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.titulo,
                        style: TextStyle(
                          fontWeight: notification.leida ? FontWeight.normal : FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatNotificationTime(notification.fecha),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            if (totalNotifications > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _showNotificationsScreen,
                  child: Text('Ver todas ($totalNotifications)'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForNotificationType(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.venta:
        return Icons.point_of_sale;
      case TipoNotificacion.inventario:
        return Icons.inventory;
      case TipoNotificacion.cliente:
        return Icons.person;
      case TipoNotificacion.sistema:
        return Icons.settings;
    }
  }

  Color _getColorForNotificationType(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.venta:
        return Colors.green;
      case TipoNotificacion.inventario:
        return Colors.orange;
      case TipoNotificacion.cliente:
        return Colors.blue;
      case TipoNotificacion.sistema:
        return Colors.purple;
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConfig.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                '¡Bienvenido!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _showNotificationsScreen,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${_notificationService.cantidadNoLeidas}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sistema de Gestión - Churrascos & Dulces Típicos',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Versión ${AppConfig.appVersion}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatsCards() {
    final churrascos = dashboardData['churrascos'] as List<Churrasco>? ?? [];
    final dulces = dashboardData['dulces'] as List<DulceTipico>? ?? [];
    final ventas = dashboardData['ventas'] as List<Venta>? ?? [];
    final inventario = dashboardData['inventario'] as List<InventarioItem>? ?? [];

    final ventasHoy = ventas.where((v) {
      final hoy = DateTime.now();
      return v.fecha.day == hoy.day && 
             v.fecha.month == hoy.month && 
             v.fecha.year == hoy.year;
    }).length;

    final ingresosHoy = ventas.where((v) {
      final hoy = DateTime.now();
      return v.fecha.day == hoy.day && 
             v.fecha.month == hoy.month && 
             v.fecha.year == hoy.year;
    }).fold(0.0, (sum, v) => sum + v.total.toDouble());

    final stockCritico = inventario.where((item) {
      return item.cantidad <= item.stockMinimo;
    }).length;

    final productosDisponibles = churrascos.where((c) => c.disponible).length + 
                                dulces.where((d) => d.disponible).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          icon: Icons.point_of_sale,
          title: 'Ventas Hoy',
          value: ventasHoy.toString(),
          subtitle: 'Transacciones',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.monetization_on,
          title: 'Ingresos',
          value: AppConfig.formatCurrency(ingresosHoy),
          subtitle: 'Hoy',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.restaurant_menu,
          title: 'Productos',
          value: productosDisponibles.toString(),
          subtitle: 'Disponibles',
          color: Theme.of(context).primaryColor,
        ),
        _buildStatCard(
          icon: Icons.warning,
          title: 'Stock Bajo',
          value: stockCritico.toString(),
          subtitle: 'Items críticos',
          color: stockCritico > 0 ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis de Ventas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Ventas por Categoría',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _buildSalesChart(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesChart() {
    final churrascos = dashboardData['churrascos'] as List<Churrasco>? ?? [];
    final dulces = dashboardData['dulces'] as List<DulceTipico>? ?? [];
    final combos = dashboardData['combos'] as List<Combo>? ?? [];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: churrascos.length.toDouble(),
            color: Theme.of(context).primaryColor,
            title: 'Churrascos',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: dulces.length.toDouble(),
            color: Colors.orange,
            title: 'Dulces',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: combos.length.toDouble(),
            color: Colors.purple,
            title: 'Combos',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


 

  Widget _buildRecentActivity() {
    final ventas = dashboardData['ventas'] as List<Venta>? ?? [];
    final ventasRecientes = ventas.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad Reciente',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: ventasRecientes.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No hay actividad reciente'),
                  ),
                )
              : Column(
                  children: ventasRecientes.map((venta) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        child: const Icon(
                          Icons.receipt,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(venta.nombreCliente ?? 'Cliente'),
                      subtitle: Text(
                        'Venta #${venta.id} - ${AppConfig.formatCurrency(venta.total.toDouble())}',
                      ),
                      trailing: Text(
                        _formatDate(venta.fecha),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }


  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}