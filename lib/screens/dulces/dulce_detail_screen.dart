import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/dulce.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import 'dulce_form_screen.dart';

class DulceDetailScreen extends StatefulWidget {
  final DulceTipico dulce;

  const DulceDetailScreen({super.key, required this.dulce});

  @override
  State<DulceDetailScreen> createState() => _DulceDetailScreenState();
}

class _DulceDetailScreenState extends State<DulceDetailScreen> {
  final ApiService _apiService = ApiService();
  late DulceTipico _dulce;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _dulce = widget.dulce;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_dulce.nombre),
        actions: [
          if (_dulce.disponible)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editarDulce,
            ),
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(_dulce.disponible ? Icons.visibility_off : Icons.visibility),
                    const SizedBox(width: 8),
                    Text(_dulce.disponible ? 'Desactivar' : 'Activar'),
                  ],
                ),
              ),
              if (_dulce.stockCritico)
                const PopupMenuItem(
                  value: 'notify_stock',
                  child: Row(
                    children: [
                      Icon(Icons.notifications, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Notificar Stock Bajo'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Duplicar'),
                  ],
                ),
              ),
              if (_dulce.disponible)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadoCard(),
            const SizedBox(height: 16),
            _buildInformacionCard(),
            const SizedBox(height: 16),
            _buildPreciosCard(),
            const SizedBox(height: 16),
            _buildInventarioCard(),
            const SizedBox(height: 16)
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCard() {
    final Color statusColor = _dulce.disponible ? Colors.green : Colors.red;
    final bool estaVencido = _dulce.isVencido;
    final bool stockCritico = _dulce.stockCritico;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _dulce.disponible ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dulce.disponible ? 'Dulce Disponible' : 'No Disponible',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _dulce.tipoDulceTexto,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _dulce.modalidadVentaTexto,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (estaVencido || stockCritico) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (estaVencido) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'VENCIDO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (stockCritico) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'STOCK CRÍTICO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Creado: ${_formatDateTime(_dulce.fechaCreacion)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_dulce.fechaModificacion != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Modificado: ${_formatDateTime(_dulce.fechaModificacion!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformacionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Información General',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Nombre', _dulce.nombre, Icons.cake),
            _buildInfoRow('Tipo', _dulce.tipoDulceTexto, Icons.category),
            _buildInfoRow('Modalidad', _dulce.modalidadVentaTexto, Icons.shopping_bag),
            if (_dulce.capacidadCaja != null)
              _buildInfoRow('Capacidad', '${_dulce.capacidadCaja} unidades', Icons.inventory_2),
            if (_dulce.descripcion != null && _dulce.descripcion!.isNotEmpty)
              _buildInfoRow('Descripción', _dulce.descripcion!, Icons.description),
            _buildInfoRow('Estado', _dulce.disponible ? 'Disponible' : 'No Disponible', 
                _dulce.disponible ? Icons.check_circle : Icons.cancel),
          ],
        ),
      ),
    );
  }

  Widget _buildPreciosCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Información de Precios',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPrecioCard(
                    'Precio por Unidad',
                    AppConfig.formatCurrency(_dulce.precioUnidad),
                    Icons.monetization_on,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPrecioCard(
                    _dulce.modalidadVenta == 0 ? 'Precio Final' : 'Precio por ${_dulce.modalidadVentaTexto}',
                    AppConfig.formatCurrency(_dulce.precio),
                    Icons.sell,
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (_dulce.modalidadVenta > 0 && _dulce.capacidadCaja != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Precio por unidad en caja: ${AppConfig.formatCurrency(_dulce.precio / _dulce.capacidadCaja!)}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrecioCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            titulo,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInventarioCard() {
    final int stock = _dulce.cantidadEnStock;
    final bool stockCritico = _dulce.stockCritico;
    final Color stockColor = stockCritico ? Colors.red : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Inventario',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: stockColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: stockColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2, color: stockColor, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          stock.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: stockColor,
                          ),
                        ),
                        Text(
                          'Unidades en Stock',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        if (stockCritico)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'CRÍTICO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      if (_dulce.fechaVencimiento != null) ...[
                        _buildInfoIconRow(
                          'Vencimiento',
                          _formatDate(_dulce.fechaVencimiento!),
                          Icons.event,
                          _dulce.isVencido ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(height: 8),
                      ],
                      _buildInfoIconRow(
                        'Valor Total',
                        AppConfig.formatCurrency(_dulce.precioUnidad * stock),
                        Icons.calculate,
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIconRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editarDulce() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => DulceFormScreen(dulce: _dulce),
      ),
    );

    if (result == true) {
      Navigator.of(context).pop('updated');
    }
  }

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'toggle_status':
        _cambiarEstado();
        break;
      case 'notify_stock':
        _notificarStockBajo();
        break;
      case 'duplicate':
        _duplicarDulce();
        break;
      case 'delete':
        _confirmarEliminar();
        break;
    }
  }

  void _cambiarEstado() async {
    setState(() {
      isLoading = true;
    });

    try {
      final dulceActualizado = DulceTipico(
        id: _dulce.id,
        nombre: _dulce.nombre,
        precio: _dulce.precio,
        descripcion: _dulce.descripcion,
        tipoDulce: _dulce.tipoDulce,
        cantidadEnStock: _dulce.cantidadEnStock,
        modalidadVenta: _dulce.modalidadVenta,
        capacidadCaja: _dulce.capacidadCaja,
        precioUnidad: _dulce.precioUnidad,
        fechaVencimiento: _dulce.fechaVencimiento,
        proveedor: _dulce.proveedor,
        ingredientes: _dulce.ingredientes,
        pesoGramos: _dulce.pesoGramos,
        disponible: !_dulce.disponible, 
        fechaCreacion: _dulce.fechaCreacion,
        fechaModificacion: DateTime.now(),
      );

      final success = await _apiService.updateDulce(_dulce.id, dulceActualizado);
      
      if (success) {
        setState(() {
          _dulce = dulceActualizado;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_dulce.disponible 
                ? 'Dulce activado' 
                : 'Dulce desactivado'),
            backgroundColor: _dulce.disponible ? Colors.green : Colors.orange,
          ),
        );
      } else {
        _showErrorSnackBar('Error al cambiar el estado');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _notificarStockBajo() {
    NotificationService().mostrarNotificacionStockBajo(
      producto: _dulce.nombre,
      cantidadActual: _dulce.cantidadEnStock,
      stockMinimo: 5,
      sucursal: 'Sucursal Principal',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificación de stock bajo enviada'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _duplicarDulce() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => DulceFormScreen(
          dulce: DulceTipico(
            id: 0,
            nombre: '${_dulce.nombre} (Copia)',
            precio: _dulce.precio,
            descripcion: _dulce.descripcion,
            tipoDulce: _dulce.tipoDulce,
            cantidadEnStock: 0,
            modalidadVenta: _dulce.modalidadVenta,
            capacidadCaja: _dulce.capacidadCaja,
            precioUnidad: _dulce.precioUnidad,
            fechaVencimiento: null, 
            proveedor: _dulce.proveedor,
            ingredientes: _dulce.ingredientes,
            pesoGramos: _dulce.pesoGramos,
            disponible: true,
            fechaCreacion: DateTime.now(),
          ),
        ),
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dulce duplicado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Dulce'),
        content: Text('¿Estás seguro de que deseas eliminar "${_dulce.nombre}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); 
              
              setState(() {
                isLoading = true;
              });

              try {
                final success = await _apiService.deleteDulce(_dulce.id);
                if (success) {
                  Navigator.of(context).pop('deleted');
                } else {
                  _showErrorSnackBar('Error al eliminar el dulce');
                }
              } catch (e) {
                _showErrorSnackBar('Error: ${e.toString()}');
              } finally {
                setState(() {
                  isLoading = false;
                });
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
}