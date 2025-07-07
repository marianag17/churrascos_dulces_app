import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../screens/notifications/notifications_screen.dart';

class NotificationFAB extends StatefulWidget {
  final String? heroTag;
  final EdgeInsets? margin;

  const NotificationFAB({
    super.key,
    this.heroTag,
    this.margin,
  });

  @override
  State<NotificationFAB> createState() => _NotificationFABState();
}

class _NotificationFABState extends State<NotificationFAB>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _notificationService.addListener(_onNotificationUpdate);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationService.removeListener(_onNotificationUpdate);
    super.dispose();
  }

  void _onNotificationUpdate() {
    if (mounted) {
      setState(() {});
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cantidadNoLeidas = _notificationService.cantidadNoLeidas;

    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                FloatingActionButton(
                  heroTag: widget.heroTag ?? "notification_fab",
                  onPressed: _openNotifications,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.notifications),
                ),
                if (cantidadNoLeidas > 0)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      child: Text(
                        cantidadNoLeidas > 99 ? '99+' : cantidadNoLeidas.toString(),
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
            ),
          );
        },
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }
}

class QuickNotificationWidget extends StatefulWidget {
  const QuickNotificationWidget({super.key});

  @override
  State<QuickNotificationWidget> createState() => _QuickNotificationWidgetState();
}

class _QuickNotificationWidgetState extends State<QuickNotificationWidget>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  AppNotification? _currentNotification;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // CAMBIO: Animación desde la IZQUIERDA en lugar de la derecha
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Cambiado de 1.0 a -1.0
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _notificationService.addListener(_onNotificationUpdate);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationService.removeListener(_onNotificationUpdate);
    super.dispose();
  }

  void _onNotificationUpdate() {
    final notifications = _notificationService.notificaciones;
    if (notifications.isNotEmpty && mounted) {
      final latestNotification = notifications.first;
      if (_currentNotification?.id != latestNotification.id) {
        _showNotification(latestNotification);
      }
    }
  }

  void _showNotification(AppNotification notification) {
    setState(() {
      _currentNotification = notification;
      _isVisible = true;
    });
    
    _animationController.forward();
    
    // Auto-hide después de 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      _hideNotification();
    });
  }

  void _hideNotification() {
    if (mounted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
            _currentNotification = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible || _currentNotification == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      // CAMBIO: Posicionado más hacia la izquierda
      left: 16,
      right: 80, // Deja espacio a la derecha para que no tape otros elementos
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getColorForType(_currentNotification!.tipo).withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForType(_currentNotification!.tipo),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentNotification!.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentNotification!.mensaje,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _hideNotification,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
}