import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../models/combo.dart';
import '../../services/api_service.dart';
import 'combo_form_screen.dart';

class ComboDetailScreen extends StatefulWidget {
  final Combo combo;

  const ComboDetailScreen({super.key, required this.combo});

  @override
  State<ComboDetailScreen> createState() => _ComboDetailScreenState();
}

class _ComboDetailScreenState extends State<ComboDetailScreen> {
  final ApiService _apiService = ApiService();
  late Combo _combo;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _combo = widget.combo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_combo.nombre),
        actions: [
          if (_combo.disponible)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editarCombo,
            ),
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(_combo.disponible ? Icons.visibility_off : Icons.visibility),
                    const SizedBox(width: 8),
                    Text(_combo.disponible ? 'Desactivar' : 'Activar'),
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
              if (_combo.disponible)
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
            _buildDescuentosCard(),
            const SizedBox(height: 16),
            if (_combo.esTemporada) _buildVigenciaCard(),
            if (_combo.esTemporada) const SizedBox(height: 16),
            _buildItemsCard(),
            const SizedBox(height: 16),
            _buildCalculosCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoCard() {
    final bool isVigente = _combo.estaVigente;
    final Color statusColor = isVigente ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isVigente ? Icons.check_circle : Icons.cancel,
                  color: statusColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVigente ? 'Combo Vigente' : 'Combo Vencido',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _combo.tipoComboTexto,
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
                    _combo.disponible ? 'Disponible' : 'No Disponible',
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
                  'Creado: ${_formatDateTime(_combo.fechaCreacion)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_combo.fechaModificacion != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Modificado: ${_formatDateTime(_combo.fechaModificacion!)}',
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
                const Icon(Icons.info, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Información General',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Nombre', _combo.nombre, Icons.local_offer),
            _buildInfoRow('Tipo', _combo.tipoComboTexto, Icons.category),
            _buildInfoRow('Precio', AppConfig.formatCurrency(_combo.precio), Icons.attach_money),
            if (_combo.descripcion != null && _combo.descripcion!.isNotEmpty)
              _buildInfoRow('Descripción', _combo.descripcion!, Icons.description),
            _buildInfoRow('Estado', _combo.disponible ? 'Disponible' : 'No Disponible', 
                _combo.disponible ? Icons.check_circle : Icons.cancel),
          ],
        ),
      ),
    );
  }

  Widget _buildDescuentosCard() {
    final bool tieneDescuentos = _combo.porcentajeDescuento > 0 || _combo.montoDescuento > 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.percent, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Descuentos Aplicados',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (tieneDescuentos) ...[
              if (_combo.porcentajeDescuento > 0)
                _buildInfoRow(
                  'Descuento %',
                  '${_combo.porcentajeDescuento.toStringAsFixed(1)}%',
                  Icons.percent,
                ),
              if (_combo.montoDescuento > 0)
                _buildInfoRow(
                  'Descuento Fijo',
                  AppConfig.formatCurrency(_combo.montoDescuento),
                  Icons.money_off,
                ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No hay descuentos configurados',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVigenciaCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Vigencia del Combo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_combo.fechaInicioVigencia != null)
              _buildInfoRow(
                'Fecha de Inicio',
                _formatDate(_combo.fechaInicioVigencia!),
                Icons.play_arrow,
              ),
            if (_combo.fechaFinVigencia != null)
              _buildInfoRow(
                'Fecha de Fin',
                _formatDate(_combo.fechaFinVigencia!),
                Icons.stop,
              ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _combo.estaVigente 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _combo.estaVigente 
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _combo.estaVigente ? Icons.check_circle : Icons.warning,
                    color: _combo.estaVigente ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _combo.estaVigente 
                        ? 'El combo está vigente y disponible'
                        : 'El combo ha vencido o no está en vigencia',
                    style: TextStyle(
                      color: _combo.estaVigente ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
                  'Productos Incluidos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_combo.items != null && _combo.items!.isNotEmpty)
              ...(_combo.items!.map(_buildItemRow).toList())
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No hay productos configurados en este combo',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(ComboItem item) {
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
                Row(
                  children: [
                    Text(
                      item.esObligatorio ? 'Obligatorio' : 'Opcional',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.esObligatorio ? Colors.red : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppConfig.formatCurrency(item.precioTotal),
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

  Widget _buildCalculosCard() {
    if (_combo.items == null || _combo.items!.isEmpty) {
      return const SizedBox.shrink();
    }

    final precioIndividual = _combo.items!.fold(0.0, 
        (sum, item) => sum + (item.precioUnitario * item.cantidad));
    final ahorro = precioIndividual - _combo.precio;
    final porcentajeAhorro = precioIndividual > 0 ? (ahorro / precioIndividual) * 100 : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calculate, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Análisis de Precios',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCalculoRow('Precio Individual:', AppConfig.formatCurrency(precioIndividual)),
            _buildCalculoRow('Precio del Combo:', AppConfig.formatCurrency(_combo.precio)),
            const Divider(thickness: 2),
            _buildCalculoRow(
              'Ahorro Total:',
              AppConfig.formatCurrency(ahorro),
              color: ahorro > 0 ? Colors.green : Colors.red,
              isHighlight: true,
            ),
            _buildCalculoRow(
              'Porcentaje de Ahorro:',
              '${porcentajeAhorro.toStringAsFixed(1)}%',
              color: ahorro > 0 ? Colors.green : Colors.red,
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

  Widget _buildCalculoRow(String label, String valor, {Color? color, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlight ? 16 : 14,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHighlight ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editarCombo() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ComboFormScreen(combo: _combo),
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
      case 'duplicate':
        _duplicarCombo();
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
      final comboActualizado = _combo.copyWith(
        disponible: !_combo.disponible,
        fechaModificacion: DateTime.now(),
      );

      final success = await _apiService.updateCombo(_combo.id, comboActualizado);
      
      if (success) {
        setState(() {
          _combo = comboActualizado;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_combo.disponible 
                ? 'Combo activado' 
                : 'Combo desactivado'),
            backgroundColor: _combo.disponible ? Colors.green : Colors.orange,
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

  void _duplicarCombo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de duplicar próximamente'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Combo'),
        content: Text('¿Estás seguro de que deseas eliminar el combo "${_combo.nombre}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Cerrar diálogo
              
              setState(() {
                isLoading = true;
              });

              try {
                final success = await _apiService.deleteCombo(_combo.id);
                if (success) {
                  Navigator.of(context).pop('deleted');
                } else {
                  _showErrorSnackBar('Error al eliminar el combo');
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