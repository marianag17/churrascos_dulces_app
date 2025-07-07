import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../models/combo.dart';
import '../../models/churrasco.dart';
import '../../models/dulce.dart';
import '../../services/api_service.dart';
import '../guarniciones/guarniciones_screen.dart';

class ComboFormScreen extends StatefulWidget {
  final Combo? combo;

  const ComboFormScreen({super.key, this.combo});

  @override
  State<ComboFormScreen> createState() => _ComboFormScreenState();
}

class _ComboFormScreenState extends State<ComboFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _porcentajeDescuentoController = TextEditingController();
  final _montoDescuentoController = TextEditingController();
  
  final ApiService _apiService = ApiService();

  List<Churrasco> churrascos = [];
  List<DulceTipico> dulces = [];
  
  List<ComboItemRequest> items = [];
  
  int _tipoCombo = 0; // 0: Familiar, 1: Eventos, 2: Personalizado
  bool _esTemporada = false;
  bool _disponible = true;
  bool _isLoading = false;
  bool _loadingProducts = true;
  String? _error;
  
  DateTime? _fechaInicioVigencia;
  DateTime? _fechaFinVigencia;

  bool get _isEditing => widget.combo != null;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    if (_isEditing) {
      _loadComboData();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loadingProducts = true;
      _error = null;
    });

    try {
      final futures = await Future.wait([
        _apiService.getChurrascos(),
        _apiService.getDulces(),
      ]);

      setState(() {
        churrascos = (futures[0] as List<Churrasco>).where((c) => c.disponible).toList();
        dulces = (futures[1] as List<DulceTipico>).where((d) => d.disponible).toList();
        _loadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingProducts = false;
      });
    }
  }

  void _loadComboData() {
    final combo = widget.combo!;
    _nombreController.text = combo.nombre;
    _descripcionController.text = combo.descripcion ?? '';
    _precioController.text = combo.precio.toString();
    _porcentajeDescuentoController.text = combo.porcentajeDescuento.toString();
    _montoDescuentoController.text = combo.montoDescuento.toString();
    _tipoCombo = combo.tipoCombo;
    _esTemporada = combo.esTemporada;
    _disponible = combo.disponible;
    _fechaInicioVigencia = combo.fechaInicioVigencia;
    _fechaFinVigencia = combo.fechaFinVigencia;
    

    if (combo.items != null) {
      items = combo.items!.map((item) => ComboItemRequest(
        productoId: item.productoId,
        nombreProducto: item.nombreProducto,
        cantidad: item.cantidad,
        precioUnitario: item.precioUnitario,
        categoria: item.categoria ?? 'General',
        esObligatorio: item.esObligatorio,
      )).toList();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _porcentajeDescuentoController.dispose();
    _montoDescuentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Combo' : 'Nuevo Combo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _mostrarAyuda,
          ),
        ],
      ),
      body: _loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConfig.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInformacionBasica(),
                        const SizedBox(height: 24),
                        _buildDescuentos(),
                        const SizedBox(height: 24),
                        _buildVigencia(),
                        const SizedBox(height: 24),
                        _buildProductosSection(),
                        const SizedBox(height: 24),
                        if (items.isNotEmpty) _buildResumenItems(),
                        if (items.isNotEmpty) const SizedBox(height: 32),
                        _buildBotonesGuardar(),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GuarnicionesScreen(),
          ),
        ),
        icon: const Icon(Icons.restaurant),
        label: const Text('Gestionar Guarniciones'),
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
            'Error al cargar productos',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProducts,
            child: const Text('Reintentar'),
          ),
        ],
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
                const Icon(Icons.local_offer, color: AppTheme.primaryColor),
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
                labelText: 'Nombre del Combo *',
                hintText: 'Ej: Combo Familiar Especial',
                prefixIcon: Icon(Icons.local_offer),
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
                hintText: 'Describe qué incluye el combo...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _precioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Final *',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El precio es requerido';
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
                  child: DropdownButtonFormField<int>(
                    value: _tipoCombo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Combo',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Familiar')),
                      DropdownMenuItem(value: 1, child: Text('Eventos')),
                      DropdownMenuItem(value: 2, child: Text('Personalizado')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _tipoCombo = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Combo Disponible'),
              subtitle: Text(_disponible 
                  ? 'Los clientes pueden ordenar este combo' 
                  : 'Combo temporalmente no disponible'
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

  Widget _buildDescuentos() {
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
                  'Descuentos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _porcentajeDescuentoController,
                    decoration: const InputDecoration(
                      labelText: 'Descuento %',
                      hintText: '0.0',
                      prefixIcon: Icon(Icons.percent),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final porcentaje = double.tryParse(value);
                        if (porcentaje == null || porcentaje < 0 || porcentaje > 100) {
                          return 'Porcentaje inválido (0-100)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _montoDescuentoController,
                    decoration: const InputDecoration(
                      labelText: 'Descuento Fijo',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.money_off),
                      prefixText: 'Q',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final monto = double.tryParse(value);
                        if (monto == null || monto < 0) {
                          return 'Monto inválido';
                        }
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
                      'Puedes aplicar descuento por porcentaje, monto fijo, o ambos.',
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

  Widget _buildVigencia() {
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
                  'Vigencia',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Combo de Temporada'),
              subtitle: const Text('Combo con fechas de inicio y fin'),
              value: _esTemporada,
              onChanged: (value) {
                setState(() {
                  _esTemporada = value;
                  if (!value) {
                    _fechaInicioVigencia = null;
                    _fechaFinVigencia = null;
                  }
                });
              },
            ),
            if (_esTemporada) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Fecha de Inicio'),
                      subtitle: Text(_fechaInicioVigencia != null 
                          ? _formatDate(_fechaInicioVigencia!)
                          : 'No seleccionada'),
                      leading: const Icon(Icons.play_arrow),
                      onTap: () => _seleccionarFecha(true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Fecha de Fin'),
                      subtitle: Text(_fechaFinVigencia != null 
                          ? _formatDate(_fechaFinVigencia!)
                          : 'No seleccionada'),
                      leading: const Icon(Icons.stop),
                      onTap: () => _seleccionarFecha(false),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.restaurant_menu, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Productos del Combo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 16),
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Churrascos (${churrascos.length})'),
                  Tab(text: 'Dulces (${dulces.length})'),
                ],
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  children: [
                    _buildChurrascosTab(),
                    _buildDulcesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChurrascosTab() {
    if (churrascos.isEmpty) {
      return const Center(
        child: Text('No hay churrascos disponibles'),
      );
    }

    return ListView.builder(
      itemCount: churrascos.length,
      itemBuilder: (context, index) {
        final churrasco = churrascos[index];
        return _buildProductCard(
          id: churrasco.id,
          nombre: churrasco.nombre,
          precio: churrasco.precio,
          descripcion: churrasco.descripcion,
          categoria: 'Churrasco',
          icon: Icons.restaurant,
          color: AppTheme.primaryColor,
        );
      },
    );
  }

  Widget _buildDulcesTab() {
    if (dulces.isEmpty) {
      return const Center(
        child: Text('No hay dulces disponibles'),
      );
    }

    return ListView.builder(
      itemCount: dulces.length,
      itemBuilder: (context, index) {
        final dulce = dulces[index];
        return _buildProductCard(
          id: dulce.id,
          nombre: dulce.nombre,
          precio: dulce.precio,
          descripcion: dulce.descripcion,
          categoria: 'Dulce',
          icon: Icons.cake,
          color: Colors.orange,
          stock: dulce.cantidadEnStock,
        );
      },
    );
  }

  Widget _buildProductCard({
    required int id,
    required String nombre,
    required double precio,
    String? descripcion,
    required String categoria,
    required IconData icon,
    required Color color,
    int? stock,
  }) {
    final cantidadEnCombo = items
        .where((item) => item.productoId == id)
        .fold(0, (sum, item) => sum + item.cantidad);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConfig.formatCurrency(precio),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (descripcion != null && descripcion.isNotEmpty)
              Text(
                descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (stock != null)
              Text(
                'Stock: $stock',
                style: TextStyle(
                  color: stock <= 5 ? Colors.red : Colors.green,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cantidadEnCombo > 0) ...[
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _quitarDelCombo(id),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cantidadEnCombo.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: (stock != null && cantidadEnCombo >= stock)
                  ? null
                  : () => _agregarAlCombo(
                        id: id,
                        nombre: nombre,
                        precio: precio,
                        categoria: categoria,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItems() {
    final precioOriginal = items.fold(0.0, (sum, item) => sum + (item.precioUnitario * item.cantidad));
    final precioCombo = double.tryParse(_precioController.text) ?? 0.0;
    final ahorro = precioOriginal - precioCombo;

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
                  'Productos en el Combo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map(_buildItemCombo).toList(),
            const Divider(),
            _buildResumenRow('Precio Individual:', AppConfig.formatCurrency(precioOriginal)),
            _buildResumenRow('Precio Combo:', AppConfig.formatCurrency(precioCombo)),
            _buildResumenRow(
              'Ahorro:',
              AppConfig.formatCurrency(ahorro),
              color: ahorro > 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCombo(ComboItemRequest item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.cantidad}x ${item.nombreProducto}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Q${item.precioUnitario.toStringAsFixed(2)} c/u - ${item.categoria}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            AppConfig.formatCurrency(item.precioUnitario * item.cantidad),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => _quitarDelCombo(item.productoId),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String valor, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonesGuardar() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _guardarCombo,
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
                : Text(_isEditing ? 'Actualizar Combo' : 'Crear Combo'),
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

  void _agregarAlCombo({
    required int id,
    required String nombre,
    required double precio,
    required String categoria,
  }) {
    setState(() {
      final existingIndex = items.indexWhere((item) => item.productoId == id);
      
      if (existingIndex >= 0) {
        items[existingIndex] = items[existingIndex].copyWith(
          cantidad: items[existingIndex].cantidad + 1,
        );
      } else {
        items.add(ComboItemRequest(
          productoId: id,
          nombreProducto: nombre,
          cantidad: 1,
          precioUnitario: precio,
          categoria: categoria,
          esObligatorio: true,
        ));
      }
    });
  }

  void _quitarDelCombo(int productoId) {
    setState(() {
      final existingIndex = items.indexWhere((item) => item.productoId == productoId);
      
      if (existingIndex >= 0) {
        if (items[existingIndex].cantidad > 1) {
          final item = items[existingIndex];
          items[existingIndex] = item.copyWith(
            cantidad: item.cantidad - 1,
          );
        } else {
          items.removeAt(existingIndex);
        }
      }
    });
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: esInicio 
          ? (_fechaInicioVigencia ?? DateTime.now())
          : (_fechaFinVigencia ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (esInicio) {
          _fechaInicioVigencia = picked;
        } else {
          _fechaFinVigencia = picked;
        }
      });
    }
  }

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Crear Combo'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Completa la información básica del combo.'),
              SizedBox(height: 8),
              Text('2. Configura descuentos (opcional).'),
              SizedBox(height: 8),
              Text('3. Si es de temporada, establece fechas.'),
              SizedBox(height: 8),
              Text('4. Agrega productos desde las pestañas.'),
              SizedBox(height: 8),
              Text('5. Revisa el resumen antes de guardar.'),
              SizedBox(height: 16),
              Text('Tip: El precio del combo debe ser menor al precio individual para generar ahorro.'),
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

  void _guardarCombo() async {
    if (_formKey.currentState!.validate()) {
      if (items.isEmpty) {
        _showErrorSnackBar('Agrega al menos un producto al combo');
        return;
      }

      if (_esTemporada && (_fechaInicioVigencia == null || _fechaFinVigencia == null)) {
        _showErrorSnackBar('Selecciona las fechas de vigencia para combos de temporada');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final combo = Combo(
          id: _isEditing ? widget.combo!.id : 0,
          nombre: _nombreController.text.trim(),
          precio: double.parse(_precioController.text),
          descripcion: _descripcionController.text.trim().isEmpty 
              ? null : _descripcionController.text.trim(),
          tipoCombo: _tipoCombo,
          porcentajeDescuento: double.tryParse(_porcentajeDescuentoController.text) ?? 0.0,
          montoDescuento: double.tryParse(_montoDescuentoController.text) ?? 0.0,
          esTemporada: _esTemporada,
          fechaInicioVigencia: _fechaInicioVigencia,
          fechaFinVigencia: _fechaFinVigencia,
          disponible: _disponible,
          fechaCreacion: _isEditing ? widget.combo!.fechaCreacion : DateTime.now(),
          fechaModificacion: _isEditing ? DateTime.now() : null,
          items: items.map((item) => ComboItem(
            id: 0,
            comboId: 0,
            productoId: item.productoId,
            nombreProducto: item.nombreProducto,
            cantidad: item.cantidad,
            precioUnitario: item.precioUnitario,
            esObligatorio: item.esObligatorio,
            categoria: item.categoria,
          )).toList(),
        );

        bool success;
        if (_isEditing) {
          success = await _apiService.updateCombo(widget.combo!.id, combo);
        } else {
          final result = await _apiService.createCombo(combo);
          success = result.containsKey('id') || result.containsKey('success');
        }

        if (success) {
          Navigator.of(context).pop(true);
        } else {
          _showErrorSnackBar('Error al guardar el combo');
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

class ComboItemRequest {
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double precioUnitario;
  final String categoria;
  final bool esObligatorio;

  ComboItemRequest({
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.categoria,
    required this.esObligatorio,
  });

  ComboItemRequest copyWith({
    int? productoId,
    String? nombreProducto,
    int? cantidad,
    double? precioUnitario,
    String? categoria,
    bool? esObligatorio,
  }) {
    return ComboItemRequest(
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      categoria: categoria ?? this.categoria,
      esObligatorio: esObligatorio ?? this.esObligatorio,
    );
  }
}