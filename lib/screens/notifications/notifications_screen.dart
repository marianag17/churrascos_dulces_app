import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _notificationService.addListener(_onNotificationUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notificationService.removeListener(_onNotificationUpdate);
    super.dispose();
  }

  void _onNotificationUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final todasLasNotificaciones = _notificationService.notificaciones;
    final noLeidas = _notificationService.notificacionesNoLeidas;
    final ventas = todasLasNotificaciones.where((n) => n.tipo == TipoNotificacion.venta).toList();
    final inventario = todasLasNotificaciones.where((n) => n.tipo == TipoNotificacion.inventario).toList();
    final sistema = todasLasNotificaciones.where((n) => n.tipo == TipoNotificacion.sistema).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 8),
                    Text('Marcar todas como leídas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Limpiar todas', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              text: 'Todas (${todasLasNotificaciones.length})',
              icon: const Icon(Icons.notifications),
            ),
            Tab(
              text: 'Ventas (${ventas.length})',
              icon: const Icon(Icons.point_of_sale),
            ),
            Tab(
              text: 'Inventario (${inventario.length})',
              icon: const Icon(Icons.inventory),
            ),
            Tab(
              text: 'Sistema (${sistema.length})',
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildNotificationsSummary(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(todasLasNotificaciones, 'todas'),
                _buildNotificationsList(ventas, 'ventas'),
                _buildNotificationsList(inventario, 'inventario'),
                _buildNotificationsList(sistema, 'sistema'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: noLeidas.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
              label: Text('Marcar ${noLeidas.length} como leídas'),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }

  Widget _buildNotificationsSummary() {
    final total = _notificationService.notificaciones.length;
    final noLeidas = _notificationService.cantidadNoLeidas;
    
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total notificaciones totales',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (noLeidas > 0)
                  Text(
                    '$noLeidas sin leer',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          if (noLeidas > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                noLeidas.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications, String categoria) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIconForCategory(categoria),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessageForCategory(categoria),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las notificaciones aparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final isUnread = !notification.leida;
    final color = _getColorForType(notification.tipo);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isUnread ? 3 : 1,
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isUnread 
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconForType(notification.tipo),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.titulo,
                        style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 16,
                          color: isUnread ? Colors.black87 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      Text(
                        notification.mensaje,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUnread ? Colors.black87 : Colors.black54,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getTypeLabel(notification.tipo),
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTime(notification.fecha),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                PopupMenuButton<String>(
                  onSelected: (value) => _onNotificationAction(value, notification),
                  itemBuilder: (context) => [
                    if (isUnread)
                      const PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            Icon(Icons.done, size: 18),
                            SizedBox(width: 8),
                            Text('Marcar como leída'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getEmptyIconForCategory(String categoria) {
    switch (categoria) {
      case 'ventas':
        return Icons.point_of_sale;
      case 'inventario':
        return Icons.inventory;
      case 'sistema':
        return Icons.settings;
      default:
        return Icons.notifications_none;
    }
  }

  String _getEmptyMessageForCategory(String categoria) {
    switch (categoria) {
      case 'ventas':
        return 'No hay notificaciones de ventas';
      case 'inventario':
        return 'No hay alertas de inventario';
      case 'sistema':
        return 'No hay notificaciones del sistema';
      default:
        return 'No hay notificaciones';
    }
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
        return Icons.settings;
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
        return Colors.purple;
    }
  }

  String _getTypeLabel(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.venta:
        return 'VENTA';
      case TipoNotificacion.inventario:
        return 'INVENTARIO';
      case TipoNotificacion.cliente:
        return 'CLIENTE';
      case TipoNotificacion.sistema:
        return 'SISTEMA';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _onNotificationTap(AppNotification notification) {
    if (!notification.leida) {
      _notificationService.marcarComoLeida(notification.id);
    }
    _showNotificationDetails(notification);
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForType(notification.tipo),
              color: _getColorForType(notification.tipo),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(notification.titulo)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.mensaje,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Fecha: ${_formatTime(notification.fecha)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.category, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Tipo: ${_getTypeLabel(notification.tipo)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          if (!notification.leida)
            TextButton(
              onPressed: () {
                _notificationService.marcarComoLeida(notification.id);
                Navigator.of(context).pop();
              },
              child: const Text('Marcar como leída'),
            ),
        ],
      ),
    );
  }

  void _onNotificationAction(String action, AppNotification notification) {
    switch (action) {
      case 'mark_read':
        _notificationService.marcarComoLeida(notification.id);
        break;
      case 'delete':
        _notificationService.eliminarNotificacion(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación eliminada'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'mark_all_read':
        _markAllAsRead();
        break;
      case 'clear_all':
        _confirmClearAll();
        break;
    }
  }

  void _markAllAsRead() {
    _notificationService.marcarTodasComoLeidas();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Todas las notificaciones marcadas como leídas'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar todas las notificaciones'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todas las notificaciones?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _notificationService.limpiarTodasLasNotificaciones();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Todas las notificaciones eliminadas'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar todas'),
          ),
        ],
      ),
    );
  }

  
}