import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../models/inventario.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class InventarioFormScreen extends StatefulWidget {
  final InventarioItem? item;

  const InventarioFormScreen({super.key, this.item});

  @override
  State<InventarioFormScreen> createState() => _InventarioFormScreenState();
}

class _InventarioFormScreenState extends State<InventarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cantidadController = TextEditingController();
  final _unidadController = TextEditingController();
  final _stockMinimoController = TextEditingController();
  final _stockMaximoController = TextEditingController();
  final _precioUnitarioController = TextEditingController();
  final _costoPromedioController = TextEditingController();
  final _puntoReordenController = TextEditingController();
  final _proveedorController = TextEditingController();
  final _codigoProveedorController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _notasController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  
  int _tipo = 0; // 0: Carne, 1: Guarnición, 2: Dulce, 3: Empaque, 4: Combustible
  bool _activo = true;
  bool _isLoading = false;
  DateTime? _fechaVencimiento;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadItemData();
    } else {
      _unidadController.text = 'unidades';
      _stockMinimoController.text = '5';
      _stockMaximoController.text = '100';
      _puntoReordenController.text = '10';
      _cantidadController.text = '0';
      _precioUnitarioController.text = '0.00';
      _costoPromedioController.text = '0.00';
    }
  }

  void _loadItemData() {
    final item = widget.item!;
    _nombreController.text = item.nombre;
    _cantidadController.text = item.cantidad.toString();
    _unidadController.text = item.unidad;
    _stockMinimoController.text = item.stockMinimo.toString();
    _stockMaximoController.text = item.stockMaximo.toString();
    _precioUnitarioController.text = item.precioUnitario.toString();
    _costoPromedioController.text = item.costoPromedio.toString();
    _puntoReordenController.text = item.puntoReorden.toString();
    _proveedorController.text = item.proveedor ?? '';
    _codigoProveedorController.text = item.codigoProveedor ?? '';
    _ubicacionController.text = item.ubicacionAlmacen ?? '';
    _notasController.text = item.notas ?? '';
    _tipo = item.tipo;
    _activo = item.activo;
    _fechaVencimiento = item.fechaVencimiento;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _unidadController.dispose();
    _stockMinimoController.dispose();
    _stockMaximoController.dispose();
    _precioUnitarioController.dispose();
    _costoPromedioController.dispose();
    _puntoReordenController.dispose();
    _proveedorController.dispose();
    _codigoProveedorController.dispose();
    _ubicacionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Item' : 'Nuevo Item de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _mostrarAyuda,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInformacionBasica(),
              const SizedBox(height: 24),
              _buildInventario(),
              const SizedBox(height: 24),
              _buildPrecios(),
              const SizedBox(height: 24),
              _buildProveedor(),
              const SizedBox(height: 24),
              _buildUbicacionYVencimiento(),
              const SizedBox(height: 24),
              _buildNotas(),
              const SizedBox(height: 32),
              _buildBotonesGuardar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformacionBasica() {
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
                  'Información Básica',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Item *',
                hintText: 'Ej: Carne de Res Premium',
                prefixIcon: Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Inventario *',
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConfig.tiposInventario.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(_getIconForTipo(entry.key), size: 20),
                      const SizedBox(width: 8),
                      Text(entry.value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipo = value!;
                  _actualizarUnidadPorDefecto();
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Item Activo'),
              subtitle: Text(_activo 
                  ? 'El item está disponible para uso' 
                  : 'Item temporalmente desactivado'
              ),
              value: _activo,
              onChanged: (value) {
                setState(() {
                  _activo = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventario() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Control de Inventario',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cantidadController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad Actual *',
                      hintText: '0',
                      prefixIcon: Icon(Icons.add_box),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unidadController,
                    decoration: const InputDecoration(
                      labelText: 'Unidad de Medida *',
                      hintText: 'libras, unidades, etc.',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockMinimoController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Mínimo *',
                      hintText: '5',
                      prefixIcon: Icon(Icons.warning),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stockMaximoController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Máximo *',
                      hintText: '100',
                      prefixIcon: Icon(Icons.check_box),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _puntoReordenController,
              decoration: const InputDecoration(
                labelText: 'Punto de Reorden *',
                hintText: '10',
                prefixIcon: Icon(Icons.refresh),
                helperText: 'Cantidad que activa la alerta de reposición',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Requerido';
                }
                if (double.tryParse(value) == null) {
                  return 'Número inválido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecios() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Información de Precios',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioUnitarioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Unitario *',
                      hintText: '0.00',
                      prefixText: 'Q',
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _costoPromedioController,
                    decoration: const InputDecoration(
                      labelText: 'Costo Promedio',
                      hintText: '0.00',
                      prefixText: 'Q',
                      prefixIcon: Icon(Icons.calculate),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Costo inválido';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProveedor() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Información del Proveedor',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _proveedorController,
              decoration: const InputDecoration(
                labelText: 'Proveedor',
                hintText: 'Nombre del proveedor',
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codigoProveedorController,
              decoration: const InputDecoration(
                labelText: 'Código del Proveedor',
                hintText: 'SKU o código interno',
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUbicacionYVencimiento() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Ubicación y Vencimiento',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Ubicación en Almacén',
                hintText: 'Ej: Estante A-3, Refrigerador 1',
                prefixIcon: Icon(Icons.place),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha de Vencimiento'),
              subtitle: Text(_fechaVencimiento != null 
                  ? 'Vence: ${_formatDate(_fechaVencimiento!)}'
                  : 'Sin fecha de vencimiento'),
              leading: const Icon(Icons.event),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_fechaVencimiento != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _fechaVencimiento = null;
                        });
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _seleccionarFechaVencimiento,
                  ),
                ],
              ),
              onTap: _seleccionarFechaVencimiento,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotas() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Notas Adicionales',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                hintText: 'Observaciones adicionales...',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesGuardar() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _guardarItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(_isEditing ? 'Actualizar Item' : 'Crear Item'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }

  void _actualizarUnidadPorDefecto() {
    switch (_tipo) {
      case 0: // Carne
        _unidadController.text = 'libras';
        break;
      case 1: // Guarnición
        _unidadController.text = 'porciones';
        break;
      case 2: // Dulce
        _unidadController.text = 'unidades';
        break;
      case 3: // Empaque
        _unidadController.text = 'unidades';
        break;
      case 4: // Combustible
        _unidadController.text = 'sacos';
        break;
    }
  }

  IconData _getIconForTipo(int tipo) {
    switch (tipo) {
      case 0: return Icons.restaurant; // Carne
      case 1: return Icons.local_dining; // Guarnición
      case 2: return Icons.cake; // Dulce
      case 3: return Icons.inventory_2; // Empaque
      case 4: return Icons.local_fire_department; // Combustible
      default: return Icons.inventory;
    }
  }

  Future<void> _seleccionarFechaVencimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _fechaVencimiento = picked;
      });
    }
  }

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Item de Inventario'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Stock Mínimo: Nivel mínimo antes de alerta'),
              SizedBox(height: 8),
              Text('• Stock Máximo: Capacidad máxima de almacén'),
              SizedBox(height: 8),
              Text('• Punto de Reorden: Cantidad que activa orden de compra'),
              SizedBox(height: 8),
              Text('• Precio Unitario: Precio de venta por unidad'),
              SizedBox(height: 8),
              Text('• Costo Promedio: Costo promedio de adquisición'),
              SizedBox(height: 16),
              Text('Tip: Configura alertas automáticas para optimizar el inventario.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _guardarItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final item = InventarioItem(
          id: _isEditing ? widget.item!.id : 0,
          nombre: _nombreController.text.trim(),
          tipo: _tipo,
          cantidad: double.parse(_cantidadController.text),
          unidad: _unidadController.text.trim(),
          stockMinimo: double.parse(_stockMinimoController.text),
          stockMaximo: double.parse(_stockMaximoController.text),
          precioUnitario: double.parse(_precioUnitarioController.text),
          ultimaActualizacion: DateTime.now(),
          proveedor: _proveedorController.text.trim().isEmpty 
              ? null : _proveedorController.text.trim(),
          codigoProveedor: _codigoProveedorController.text.trim().isEmpty 
              ? null : _codigoProveedorController.text.trim(),
          fechaVencimiento: _fechaVencimiento,
          ubicacionAlmacen: _ubicacionController.text.trim().isEmpty 
              ? null : _ubicacionController.text.trim(),
          costoPromedio: double.tryParse(_costoPromedioController.text) ?? 0.0,
          puntoReorden: double.parse(_puntoReordenController.text),
          activo: _activo,
          notas: _notasController.text.trim().isEmpty 
              ? null : _notasController.text.trim(),
        );

        bool success;
        if (_isEditing) {
          success = await _apiService.updateInventarioItem(widget.item!.id, item);
        } else {
          final result = await _apiService.createInventarioItem(item);
          success = result.containsKey('id') || result.containsKey('success');
        }

        if (success) {
          if (item.stockCritico) {
            NotificationService().mostrarNotificacionStockBajo(
              producto: item.nombre,
              cantidadActual: item.cantidad.toInt(),
              stockMinimo: item.stockMinimo.toInt(),
              sucursal: 'Sucursal Principal',
            );
          }
          
          Navigator.of(context).pop(true);
        } else {
          _showErrorSnackBar('Error al guardar el item');
        }
      } catch (e) {
        _showErrorSnackBar('Error: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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