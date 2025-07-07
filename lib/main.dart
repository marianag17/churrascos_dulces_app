import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/churrascos/churrascos_screen.dart';
import 'screens/dulces/dulces_screen.dart';
import 'screens/combos/combos_screen.dart';
import 'screens/inventario/inventario_screen.dart';
import 'screens/ventas/ventas_screen.dart';
import 'screens/sucursales/sucursales_screen.dart';
import 'services/notification_service.dart';
import 'widgets/notification_fab.dart';
import 'screens/notifications/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Churrascos & Dulces',
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final NotificationService _notificationService = NotificationService();
  bool _isInitialized = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ChurrascosScreen(),
    const DulcesScreen(),
    const CombosScreen(),
    const InventarioScreen(),
    const VentasScreen(),
    const SucursalesScreen(),
  ];

  final List<String> _screenTitles = [
    'Dashboard',
    'Churrascos',
    'Dulces Típicos',
    'Combos',
    'Inventario',
    'Ventas',
    'Sucursales',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotificationService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationService.removeListener(_onNotificationUpdate);
    _notificationService.dispose(); // Agregar dispose del servicio
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Manejar el ciclo de vida de la aplicación
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isInitialized && mounted) {
          _initializeNotificationService();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _notificationService.dispose();
        _isInitialized = false;
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _initializeNotificationService() {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _notificationService.init(context);
        _notificationService.addListener(_onNotificationUpdate);
        _isInitialized = true;
      }
    });
  }

  void _onNotificationUpdate() {
    if (mounted) {
      setState(() {}); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          
          if (_isInitialized)
            const QuickNotificationWidget(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      
      floatingActionButton: _shouldShowNotificationFAB() && _isInitialized
          ? NotificationFAB(
              heroTag: "main_notification_fab",
            )
          : null,
      floatingActionButtonLocation: _shouldShowNotificationFAB() && _isInitialized
          ? FloatingActionButtonLocation.startFloat 
          : null,
    );
  }

  Widget _buildBottomNavigationBar() {
    final cantidadNoLeidas = _isInitialized ? _notificationService.cantidadNoLeidas : 0;

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.dashboard, 0, cantidadNoLeidas > 0 ? cantidadNoLeidas : null),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.restaurant, 1),
          label: 'Churrascos',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.cake, 2),
          label: 'Dulces',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.local_offer, 3),
          label: 'Combos',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.inventory, 4),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.point_of_sale, 5),
          label: 'Ventas',
        ),
        BottomNavigationBarItem(
          icon: _buildNavIcon(Icons.store, 6),
          label: 'Sucursales',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedFontSize: 11,
      unselectedFontSize: 10,
    );
  }

  Widget _buildNavIcon(IconData iconData, int index, [int? badgeCount]) {
    return Stack(
      children: [
        Icon(iconData),
        if (badgeCount != null && badgeCount > 0 && index == 0) 
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeCount > 9 ? '9+' : badgeCount.toString(),
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

  bool _shouldShowNotificationFAB() {
    return _currentIndex != 0;
  }
}

extension MainScreenNavigation on _MainScreenState {
  void navigateToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
  
  void navigateToNotifications() {
    if (_isInitialized) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const NotificationsScreen(),
        ),
      );
    }
  }
  
  String get currentScreenTitle => _screenTitles[_currentIndex];
}

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  
  List<AppNotification> get notifications => _service.notificaciones;
  List<AppNotification> get unreadNotifications => _service.notificacionesNoLeidas;
  int get unreadCount => _service.cantidadNoLeidas;
  
  void markAsRead(int id) {
    _service.marcarComoLeida(id);
    notifyListeners();
  }
  
  void markAllAsRead() {
    _service.marcarTodasComoLeidas();
    notifyListeners();
  }
  
  void clearAll() {
    _service.limpiarTodasLasNotificaciones();
    notifyListeners();
  }
}

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? backgroundColor;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
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
}