import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/dulce.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class DulceFormScreen extends StatefulWidget {
  final DulceTipico? dulce;

  const DulceFormScreen({super.key, this.dulce});

  @override
  State<DulceFormScreen> createState() => _DulceFormScreenState();
}

class _DulceFormScreenState extends State<DulceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _precioUnidadController = TextEditingController();
  final _stockController = TextEditingController();
  final _proveedorController = TextEditingController();
  final _ingredientesController = TextEditingController();
  final _pesoController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  
  int _tipoDulce = 0;
  int _modalidadVenta = 0; // 0: Unidad, 1: Cajade 6, 2: Cajade 12, 3: Cajade 24
  int? _capacidadCaja;
  bool _disponible = true;
  bool _isLoading = false;
  DateTime? _fechaVencimiento;

  bool get _isEditing => widget.dulce != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadDulceData();
    } else {
      _stockController.text = '0';
      _precioController.text = '0.00';
      _precioUnidadController.text = '0.00';
    }
  }

  void _loadDulceData() {
    final dulce = widget.dulce!;
    _nombreController.text = dulce.nombre;
    _descripcionController.text = dulce.descripcion ?? '';
    _precioController.text = dulce.precio.toString();
    _precioUnidadController.text = dulce.precioUnidad.toString();
    _stockController.text = dulce.cantidadEnStock.toString();
    _proveedorController.text = dulce.proveedor ?? '';
    _ingredientesController.text = dulce.ingredientes ?? '';
    _pesoController.text = dulce.pesoGramos?.toString() ?? '';
    
    _tipoDulce = dulce.tipoDulce;
    _modalidadVenta = dulce.modalidadVenta;
    _capacidadCaja = dulce.capacidadCaja;
    _disponible = dulce.disponible;
    _fechaVencimiento = dulce.fechaVencimiento;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _precioUnidadController.dispose();
    _stockController.dispose();
    _proveedorController.dispose();
    _ingredientesController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Dulce' : 'Nuevo Dulce Típico'),
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
              _buildTipoYModalidad(),
              const SizedBox(height: 24),
              _buildPrecios(),
              const SizedBox(height: 24),
              _buildInventario(),
              const SizedBox(height: 24),
              _buildDetallesAdicionales(),
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
                const Icon(Icons.cake, color: Colors.orange),
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
                labelText: 'Nombre del Dulce *',
                hintText: 'Ej: Canillitas de Leche Premium',
                prefixIcon: Icon(Icons.cake),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe el dulce típico...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dulce Disponible'),
              subtitle: Text(_disponible 
                  ? 'Disponible para venta' 
                  : 'Temporalmente no disponible'
              ),
              value: _disponible,
              onChanged: (value) {
                setState(() {
                  _disponible = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoYModalidad() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Tipo y Modalidad',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _tipoDulce,
              decoration: const InputDecoration(
                labelText: 'Tipo de Dulce *',
                prefixIcon: Icon(Icons.local_dining),
              ),
              items: AppConfig.tiposDulce.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoDulce = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _modalidadVenta,
              decoration: const InputDecoration(
                labelText: 'Modalidad de Venta *',
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              items: AppConfig.modalidadesVenta.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _modalidadVenta = value!;
                  switch (value) {
                    case 0: 
                      _capacidadCaja = null;
                      break;
                    case 1: 
                      _capacidadCaja = 6;
                      break;
                    case 2:
                      _capacidadCaja = 12;
                      break;
                    case 3: 
                      _capacidadCaja = 24;
                      break;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            if (_modalidadVenta > 0) 
              TextFormField(
                initialValue: _capacidadCaja?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Capacidad de Caja',
                  hintText: 'Número de unidades por caja',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                keyboardType: TextInputType.number,
                enabled: false, 
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
                const Icon(Icons.attach_money, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Precios',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioUnidadController,
                    decoration: const InputDecoration(
                      labelText: 'Precio por Unidad *',
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
                    onChanged: (value) => _calcularPrecioFinal(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _precioController,
                    decoration: InputDecoration(
                      labelText: _modalidadVenta == 0 
                          ? 'Precio Final *' 
                          : 'Precio por ${_getModalidadText()} *',
                      hintText: '0.00',
                      prefixText: 'Q',
                      prefixIcon: const Icon(Icons.sell),
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
              ],
            ),
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
                  const Icon(Icons.info, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _modalidadVenta == 0
                          ? 'Precio por unidad individual'
                          : 'El precio por unidad se usa para cálculos de inventario. El precio final es lo que paga el cliente.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
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

  Widget _buildInventario() {
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Cantidad en Stock *',
                hintText: '0',
                prefixIcon: Icon(Icons.inventory_2),
                suffixText: 'unidades',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La cantidad es requerida';
                }
                final cantidad = int.tryParse(value);
                if (cantidad == null || cantidad < 0) {
                  return 'Debe ser un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Fecha de Vencimiento'),
              subtitle: Text(_fechaVencimiento != null 
                  ? _formatDate(_fechaVencimiento!)
                  : 'No especificada (opcional)'),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetallesAdicionales() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.more_horiz, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Detalles Adicionales',
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
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientesController,
              decoration: const InputDecoration(
                labelText: 'Ingredientes Principales',
                hintText: 'Ej: Leche, azúcar, canela...',
                prefixIcon: Icon(Icons.list),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pesoController,
              decoration: const InputDecoration(
                labelText: 'Peso por Unidad',
                hintText: '0',
                prefixIcon: Icon(Icons.scale),
                suffixText: 'gramos',
              ),
              keyboardType: TextInputType.number,
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
            onPressed: _isLoading ? null : _guardarDulce,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
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
                : Text(_isEditing ? 'Actualizar Dulce' : 'Crear Dulce'),
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

  void _calcularPrecioFinal() {
    if (_modalidadVenta > 0 && _capacidadCaja != null) {
      final precioUnidad = double.tryParse(_precioUnidadController.text) ?? 0.0;
      final precioFinal = precioUnidad * _capacidadCaja!;
      _precioController.text = precioFinal.toStringAsFixed(2);
    }
  }

  String _getModalidadText() {
    switch (_modalidadVenta) {
      case 1: return 'Caja de 6';
      case 2: return 'Caja de 12';
      case 3: return 'Caja de 24';
      default: return 'Unidad';
    }
  }

  Future<void> _seleccionarFechaVencimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
        title: const Text('Ayuda - Crear Dulce Típico'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Tipo de Dulce: Selecciona el tipo específico'),
              SizedBox(height: 8),
              Text('• Modalidad: Por unidad o en cajas de diferentes tamaños'),
              SizedBox(height: 8),
              Text('• Precio Unidad: Costo individual del dulce'),
              SizedBox(height: 8),
              Text('• Precio Final: Lo que paga el cliente'),
              SizedBox(height: 8),
              Text('• Stock: Cantidad disponible en inventario'),
              SizedBox(height: 8),
              Text('• Fecha Vencimiento: Opcional para dulces perecederos'),
              SizedBox(height: 16),
              Text('Tip: El precio final se calcula automáticamente para cajas según la capacidad.'),
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

  void _guardarDulce() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final dulce = DulceTipico(
          id: _isEditing ? widget.dulce!.id : 0,
          nombre: _nombreController.text.trim(),
          precio: double.parse(_precioController.text),
          descripcion: _descripcionController.text.trim().isEmpty 
              ? null : _descripcionController.text.trim(),
          tipoDulce: _tipoDulce,
          cantidadEnStock: int.parse(_stockController.text),
          modalidadVenta: _modalidadVenta,
          capacidadCaja: _capacidadCaja,
          precioUnidad: double.parse(_precioUnidadController.text),
          fechaVencimiento: _fechaVencimiento,
          proveedor: _proveedorController.text.trim().isEmpty 
              ? null : _proveedorController.text.trim(),
          ingredientes: _ingredientesController.text.trim().isEmpty 
              ? null : _ingredientesController.text.trim(),
          pesoGramos: _pesoController.text.trim().isEmpty 
              ? null : double.tryParse(_pesoController.text),
          disponible: _disponible,
          fechaCreacion: _isEditing ? widget.dulce!.fechaCreacion : DateTime.now(),
          fechaModificacion: _isEditing ? DateTime.now() : null,
        );

        bool success;
        if (_isEditing) {
          success = await _apiService.updateDulce(widget.dulce!.id, dulce);
        } else {
          final result = await _apiService.createDulce(dulce);
          success = result.containsKey('id') || result.containsKey('success');
        }

        if (success) {
          if (_isEditing) {
            NotificationService().notificarProductoActualizado(dulce.nombre, 'Dulce Típico');
          } else {
            NotificationService().notificarProductoCreado(dulce.nombre, 'Dulce Típico');
          }
          
          Navigator.of(context).pop(true);
        } else {
          _showErrorSnackBar('Error al guardar el dulce');
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