import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/churrasco.dart';
import 'churrasco_form_screen.dart';

class ChurrascosScreen extends ConsumerStatefulWidget {
  const ChurrascosScreen({super.key});

  @override
  ConsumerState<ChurrascosScreen> createState() => _ChurrascosScreenState();
}

class _ChurrascosScreenState extends ConsumerState<ChurrascosScreen> {
  final ApiService _apiService = ApiService();
  
  List<Churrasco> churrascos = [];
  List<Guarnicion> guarniciones = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final futures = await Future.wait([
        _apiService.getChurrascos(),
        _apiService.getGuarnicionesDisponibles(),
      ]);

      setState(() {
        churrascos = futures[0] as List<Churrasco>;
        guarniciones = futures[1] as List<Guarnicion>;
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
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text('Churrascos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : _buildChurrascosList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _nuevoChurrasco(),
        child: const Icon(Icons.add),
        tooltip: 'Nuevo Churrasco',
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
            'Error al cargar churrascos',
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
            onPressed: _loadData,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildChurrascosList() {
    if (churrascos.isEmpty) {
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
              'No hay churrascos registrados',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar tu primer churrasco',
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
              itemCount: churrascos.length,
              itemBuilder: (context, index) {
                final churrasco = churrascos[index];
                return _buildChurrascoCard(churrasco);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final disponibles = churrascos.where((c) => c.disponible).length;
    final noDisponibles = churrascos.length - disponibles;
    final promedioPrecios = churrascos.isNotEmpty
        ? churrascos.map((c) => c.precio).reduce((a, b) => a + b) / churrascos.length
        : 0.0;

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
            icon: Icons.cancel,
            title: 'No Disponibles',
            value: noDisponibles.toString(),
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            title: 'Precio Promedio',
            value: AppConfig.formatCurrency(promedioPrecios),
            color: AppTheme.primaryColor,
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

  Widget _buildChurrascoCard(Churrasco churrasco) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: churrasco.disponible 
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
        ),
        title: Text(
          churrasco.nombre,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConfig.formatCurrency(churrasco.precio),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(AppConfig.getMeatTypeLabel(churrasco.tipoCarne)),
            Text('${churrasco.cantidadPorciones} porción${churrasco.cantidadPorciones > 1 ? 'es' : ''}'),
            if (churrasco.guarniciones != null && churrasco.guarniciones!.isNotEmpty)
              Text(
                '${churrasco.guarniciones!.length} guarnición${churrasco.guarniciones!.length > 1 ? 'es' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onMenuSelected(value, churrasco),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'ver',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('Ver Detalles'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(churrasco.disponible ? Icons.visibility_off : Icons.visibility),
                  const SizedBox(width: 8),
                  Text(churrasco.disponible ? 'Desactivar' : 'Activar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'eliminar',
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
        onTap: () => _mostrarDetalleChurrasco(churrasco),
      ),
    );
  }

  void _nuevoChurrasco() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const ChurrascoFormScreen(),
      ),
    );

    if (result == true) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Churrasco creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _mostrarDetalleChurrasco(Churrasco churrasco) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(churrasco.nombre),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Precio', AppConfig.formatCurrency(churrasco.precio)),
              _buildDetailRow('Precio Base', AppConfig.formatCurrency(churrasco.precioBase)),
              _buildDetailRow('Tipo de Carne', AppConfig.getMeatTypeLabel(churrasco.tipoCarne)),
              _buildDetailRow('Término', AppConfig.getCookingTermLabel(churrasco.terminoCoccion)),
              _buildDetailRow('Tipo de Plato', AppConfig.getPlateTypeLabel(churrasco.tipoPlato)),
              _buildDetailRow('Porciones', '${churrasco.cantidadPorciones}'),
              _buildDetailRow('Estado', churrasco.disponible ? 'Disponible' : 'No Disponible'),
              if (churrasco.descripcion != null && churrasco.descripcion!.isNotEmpty)
                _buildDetailRow('Descripción', churrasco.descripcion!),
              if (churrasco.guarniciones != null && churrasco.guarniciones!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Guarniciones:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...churrasco.guarniciones!.map((gc) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        gc.esExtra ? Icons.add_circle : Icons.check_circle,
                        size: 16,
                        color: gc.esExtra ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${gc.cantidadPorciones}x ${gc.nombreGuarnicion}${gc.esExtra ? ' (Extra)' : ''}',
                          style: TextStyle(
                            color: gc.esExtra ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                      if (gc.esExtra)
                        Text(
                          AppConfig.formatCurrency(gc.precioTotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editarChurrasco(churrasco);
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

  void _onMenuSelected(String value, Churrasco churrasco) async {
    switch (value) {
      case 'ver':
        _mostrarDetalleChurrasco(churrasco);
        break;
      case 'editar':
        _editarChurrasco(churrasco);
        break;
      case 'toggle':
        _cambiarDisponibilidad(churrasco);
        break;
      case 'eliminar':
        _confirmarEliminar(churrasco);
        break;
    }
  }

  void _editarChurrasco(Churrasco churrasco) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ChurrascoFormScreen(churrasco: churrasco),
      ),
    );

    if (result == true) {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Churrasco actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _cambiarDisponibilidad(Churrasco churrasco) async {
    try {
      final churrascoActualizado = churrasco.copyWith(
        disponible: !churrasco.disponible,
        fechaModificacion: DateTime.now(),
      );

      final request = ChurrascoCreateRequest(
        nombre: churrascoActualizado.nombre,
        precio: churrascoActualizado.precio,
        descripcion: churrascoActualizado.descripcion,
        tipoCarne: churrascoActualizado.tipoCarne,
        terminoCoccion: churrascoActualizado.terminoCoccion,
        tipoPlato: churrascoActualizado.tipoPlato,
        cantidadPorciones: churrascoActualizado.cantidadPorciones,
        precioBase: churrascoActualizado.precioBase,
        disponible: churrascoActualizado.disponible,
        guarniciones: churrascoActualizado.guarniciones?.map((gc) => 
          GuarnicionChurrascoRequest(
            guarnicionId: gc.guarnicionId,
            cantidadPorciones: gc.cantidadPorciones,
            esExtra: gc.esExtra,
          )
        ).toList(),
      );

      final success = await _apiService.updateChurrasco(churrasco.id, request);
      
      if (success) {
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(churrascoActualizado.disponible 
                ? 'Churrasco activado' 
                : 'Churrasco desactivado'),
            backgroundColor: churrascoActualizado.disponible ? Colors.green : Colors.orange,
          ),
        );
      } else {
        _showErrorSnackBar('Error al cambiar el estado');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _confirmarEliminar(Churrasco churrasco) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Churrasco'),
        content: Text('¿Estás seguro de que deseas eliminar "${churrasco.nombre}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); 
              
              try {
                final success = await _apiService.deleteChurrasco(churrasco.id);
                if (success) {
                  _loadData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Churrasco eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  _showErrorSnackBar('Error al eliminar el churrasco');
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