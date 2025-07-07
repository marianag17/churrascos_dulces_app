import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../models/churrasco.dart';
import '../../services/notification_service.dart';

class GuarnicionesScreen extends ConsumerStatefulWidget {
  const GuarnicionesScreen({super.key});

  @override
  ConsumerState<GuarnicionesScreen> createState() => _GuarnicionesScreenState();
}

class _GuarnicionesScreenState extends ConsumerState<GuarnicionesScreen> {
  final ApiService _apiService = ApiService();
  
  List<Guarnicion> guarniciones = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadGuarniciones();
  }

  Future<void> _loadGuarniciones() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final guarnicionesFromApi = await _apiService.getGuarniciones();
      setState(() {
        guarniciones = guarnicionesFromApi;
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
        title: const Row(
          children: [
            Text('🍽️'),
            SizedBox(width: 8),
            Text('Guarniciones'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGuarniciones,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGuarniciones,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : _buildGuarnicionesList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevaGuarnicion,
        child: const Icon(Icons.add),
        tooltip: 'Nueva Guarnición',
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
            'Error al cargar guarniciones',
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
            onPressed: _loadGuarniciones,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuarnicionesList() {
    if (guarniciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay guarniciones registradas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar la primera guarnición',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        children: [
          _buildStatsCards(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: guarniciones.length,
              itemBuilder: (context, index) {
                final guarnicion = guarniciones[index];
                return _buildGuarnicionCard(guarnicion);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final disponibles = guarniciones.where((g) => g.disponible).length;
    final stockCritico = guarniciones.where((g) => g.cantidadStock <= g.stockMinimo).length;
    final conPrecioExtra = guarniciones.where((g) => g.precioExtra > 0).length;
    final totalStock = guarniciones.fold(0, (sum, g) => sum + g.cantidadStock);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            title: 'Disponibles',
            value: disponibles.toString(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.warning,
            title: 'Stock Crítico',
            value: stockCritico.toString(),
            color: stockCritico > 0 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            title: 'Premium',
            value: conPrecioExtra.toString(),
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.inventory_2,
            title: 'Stock Total',
            value: totalStock.toString(),
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuarnicionCard(Guarnicion guarnicion) {
    final bool stockCritico = guarnicion.cantidadStock <= guarnicion.stockMinimo;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: guarnicion.disponible 
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Icon(
            Icons.restaurant,
            color: guarnicion.disponible ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          guarnicion.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (guarnicion.precioExtra > 0)
              Text(
                'Precio extra: ${AppConfig.formatCurrency(guarnicion.precioExtra)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Text(
                'Sin costo adicional',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Stock: ${guarnicion.cantidadStock}'),
                const SizedBox(width: 8),
                Text('• Mín: ${guarnicion.stockMinimo}'),
              ],
            ),
            if (guarnicion.descripcion != null && guarnicion.descripcion!.isNotEmpty)
              Text(
                guarnicion.descripcion!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: guarnicion.disponible ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                guarnicion.disponible ? 'Disponible' : 'No disponible',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (stockCritico)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Stock Bajo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _mostrarDetalleGuarnicion(guarnicion),
      ),
    );
  }

  void _nuevaGuarnicion() {
    _mostrarFormularioGuarnicion();
  }

  void _mostrarDetalleGuarnicion(Guarnicion guarnicion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(guarnicion.nombre),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nombre', guarnicion.nombre),
              _buildDetailRow('Precio Extra', AppConfig.formatCurrency(guarnicion.precioExtra)),
              _buildDetailRow('Stock Actual', '${guarnicion.cantidadStock} unidades'),
              _buildDetailRow('Stock Mínimo', '${guarnicion.stockMinimo} unidades'),
              _buildDetailRow('Estado', guarnicion.disponible ? 'Disponible' : 'No Disponible'),
              if (guarnicion.descripcion != null && guarnicion.descripcion!.isNotEmpty)
                _buildDetailRow('Descripción', guarnicion.descripcion!),
            ],
          ),
        ),
        actions: [
          if (guarnicion.cantidadStock <= guarnicion.stockMinimo)
            TextButton(
              onPressed: () {
                NotificationService().mostrarNotificacionStockBajo(
                  producto: guarnicion.nombre,
                  cantidadActual: guarnicion.cantidadStock,
                  stockMinimo: guarnicion.stockMinimo,
                  sucursal: 'Sucursal Principal',
                );
                Navigator.of(context).pop();
              },
              child: const Text('Notificar Stock Bajo'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editarGuarnicion(guarnicion);
            },
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _mostrarFormularioGuarnicion({Guarnicion? guarnicion}) {
    final bool isEditing = guarnicion != null;
    final nombreController = TextEditingController(text: guarnicion?.nombre ?? '');
    final descripcionController = TextEditingController(text: guarnicion?.descripcion ?? '');
    final precioExtraController = TextEditingController(
      text: guarnicion?.precioExtra.toString() ?? '0'
    );
    final stockController = TextEditingController(
      text: guarnicion?.cantidadStock.toString() ?? '0'
    );
    final stockMinimoController = TextEditingController(
      text: guarnicion?.stockMinimo.toString() ?? '5'
    );
    bool disponible = guarnicion?.disponible ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Editar Guarnición' : 'Nueva Guarnición'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Ej: Frijoles negros',
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
                    controller: descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción opcional...',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: precioExtraController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Extra',
                      hintText: '0.00',
                      prefixText: 'Q',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Precio inválido';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          decoration: const InputDecoration(
                            labelText: 'Stock Actual *',
                            hintText: '0',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Requerido';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: stockMinimoController,
                          decoration: const InputDecoration(
                            labelText: 'Stock Mínimo *',
                            hintText: '5',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Requerido';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Disponible'),
                    value: disponible,
                    onChanged: (value) {
                      setDialogState(() {
                        disponible = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (isEditing)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmarEliminarGuarnicion(guarnicion);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final nuevaGuarnicion = Guarnicion(
                    id: isEditing ? guarnicion.id : 0,
                    nombre: nombreController.text.trim(),
                    descripcion: descripcionController.text.trim().isEmpty 
                        ? null : descripcionController.text.trim(),
                    precioExtra: double.tryParse(precioExtraController.text) ?? 0.0,
                    cantidadStock: int.parse(stockController.text),
                    stockMinimo: int.parse(stockMinimoController.text),
                    disponible: disponible,
                  );

                  Navigator.of(context).pop();
                  await _guardarGuarnicion(nuevaGuarnicion, isEditing);
                }
              },
              child: Text(isEditing ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _editarGuarnicion(Guarnicion guarnicion) {
    _mostrarFormularioGuarnicion(guarnicion: guarnicion);
  }

  Future<void> _guardarGuarnicion(Guarnicion guarnicion, bool isEditing) async {
    try {
      bool success;
      if (isEditing) {
        success = await _apiService.updateGuarnicion(guarnicion.id, guarnicion);
      } else {
        final result = await _apiService.createGuarnicion(guarnicion);
        success = result.containsKey('id') || result.containsKey('success');
      }

      if (success) {
        _loadGuarniciones();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing 
                ? 'Guarnición actualizada exitosamente' 
                : 'Guarnición creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackBar('Error al guardar la guarnición');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _confirmarEliminarGuarnicion(Guarnicion guarnicion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Guarnición'),
        content: Text('¿Estás seguro de que deseas eliminar "${guarnicion.nombre}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                final success = await _apiService.deleteGuarnicion(guarnicion.id);
                if (success) {
                  _loadGuarniciones();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guarnición eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  _showErrorSnackBar('Error al eliminar la guarnición');
                }
              } catch (e) {
                _showErrorSnackBar('Error: ${e.toString()}');
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