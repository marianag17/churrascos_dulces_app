import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../models/venta.dart';

class VentaDetailScreen extends StatefulWidget {
  final Venta venta;

  const VentaDetailScreen({super.key, required this.venta});

  @override
  State<VentaDetailScreen> createState() => _VentaDetailScreenState();
}

class _VentaDetailScreenState extends State<VentaDetailScreen> {
  late Venta _venta;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _venta = widget.venta;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${_venta.numeroOrden}'),
        actions: [
          
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              if (_venta.estado == 0) 
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
              if (_venta.estado == 2) 
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
              if (_venta.estado < 3) 
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
              const PopupMenuItem(
                value: 'imprimir',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Imprimir'),
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
            _buildClienteCard(),
            const SizedBox(height: 16),
            _buildItemsCard(),
            const SizedBox(height: 16),
            _buildResumenCard(),
            const SizedBox(height: 16),
            _buildDetallesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCard() {
    final Color statusColor = _getStatusColor(_venta.estado);
    final IconData statusIcon = _getStatusIcon(_venta.estado);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _venta.estadoTexto,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Orden #${_venta.numeroOrden}',
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
                    _venta.tipoVentaTexto,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Creada: ${_formatDateTime(_venta.fechaCreacion)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_venta.fechaModificacion != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Modificada: ${_formatDateTime(_venta.fechaModificacion!)}',
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

  Widget _buildClienteCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Información del Cliente',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_venta.nombreCliente != null)
              _buildInfoRow('Nombre', _venta.nombreCliente!, Icons.person_outline),
            if (_venta.telefonoCliente != null)
              _buildInfoRow('Teléfono', _venta.telefonoCliente!, Icons.phone),
            if (_venta.direccionEntrega != null)
              _buildInfoRow('Dirección', _venta.direccionEntrega!, Icons.location_on),
            if (_venta.numeroMesa != null)
              _buildInfoRow('Mesa', _venta.numeroMesa.toString(), Icons.table_restaurant),
            if (_venta.metodoPago != null)
              _buildInfoRow('Método de Pago', _venta.metodoPago!, Icons.payment),
            if (_venta.notasEspeciales != null && _venta.notasEspeciales!.isNotEmpty)
              _buildInfoRow('Notas', _venta.notasEspeciales!, Icons.note),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Productos (${_venta.cantidadItems} items)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_venta.items != null && _venta.items!.isNotEmpty)
              ...(_venta.items!.map(_buildItemRow).toList())
            else
              const Text('No hay items en esta venta'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(VentaItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${item.cantidad}x',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombreProducto,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (item.categoria != null)
                  Text(
                    item.categoria!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                if (item.notasEspeciales != null && item.notasEspeciales!.isNotEmpty)
                  Text(
                    'Nota: ${item.notasEspeciales}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.orange[700],
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppConfig.formatCurrency(item.subtotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${AppConfig.formatCurrency(item.precioUnitario)} c/u',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Resumen de Pago',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResumenRow('Subtotal:', AppConfig.formatCurrency(_venta.subtotal)),
            if (_venta.descuento > 0)
              _buildResumenRow('Descuento:', '-${AppConfig.formatCurrency(_venta.descuento)}', textColor: Colors.red),
            _buildResumenRow('Impuestos:', AppConfig.formatCurrency(_venta.impuestos)),
            const Divider(thickness: 2),
            _buildResumenRow(
              'Total:',
              AppConfig.formatCurrency(_venta.total),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Detalles Adicionales',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('ID de Venta', _venta.id.toString(), Icons.tag),
            _buildInfoRow('Fecha de Venta', _formatDate(_venta.fecha), Icons.calendar_today),
            _buildInfoRow('Tipo de Venta', _venta.tipoVentaTexto, _getTipoVentaIcon(_venta.tipoVenta)),
            _buildInfoRow('Estado', _venta.estadoTexto, _getStatusIcon(_venta.estado)),
            if (_venta.metodoPago != null)
              _buildInfoRow('Método de Pago', _venta.metodoPago!, Icons.payment),
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
            width: 100,
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

  Widget _buildResumenRow(String label, String valor, {bool isTotal = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
              color: textColor ?? (isTotal ? Colors.green : null),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int estado) {
    switch (estado) {
      case 0: return Colors.orange; // Pendiente
      case 1: return Colors.blue;   // Preparando
      case 2: return Colors.purple; // Listo
      case 3: return Colors.green;  // Entregado
      case 4: return Colors.red;    // Cancelado
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(int estado) {
    switch (estado) {
      case 0: return Icons.schedule;        // Pendiente
      case 1: return Icons.restaurant;      // Preparando
      case 2: return Icons.done;           // Listo
      case 3: return Icons.check_circle;   // Entregado
      case 4: return Icons.cancel;         // Cancelado
      default: return Icons.help;
    }
  }

  IconData _getTipoVentaIcon(int tipo) {
    switch (tipo) {
      case 0: return Icons.store;           // Local
      case 1: return Icons.delivery_dining; // Domicilio
      case 2: return Icons.event;          // Eventos
      default: return Icons.point_of_sale;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _onMenuSelected(String value) async {
    switch (value) {

      case 'cancelar':
        _confirmarCancelarVenta();
        break;
      case 'imprimir':
        _imprimirVenta();
        break;
    }
  }

 
  void _confirmarCancelarVenta() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Venta'),
        content: Text('¿Estás seguro de que deseas cancelar la orden #${_venta.numeroOrden}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  void _imprimirVenta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('test'),
        backgroundColor: Colors.blue,
      ),
    );
  }

}