import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../models/sucursal.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class SucursalFormScreen extends StatefulWidget {
  final Sucursal? sucursal;

  const SucursalFormScreen({super.key, this.sucursal});

  @override
  State<SucursalFormScreen> createState() => _SucursalFormScreenState();
}

class _SucursalFormScreenState extends State<SucursalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _gerenteController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  
  bool _activa = true;
  bool _isLoading = false;
  TimeOfDay? _horarioApertura;
  TimeOfDay? _horarioCierre;
  final List<String> _diasSeleccionados = [];
  
  final List<String> _todosDias = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  bool get _isEditing => widget.sucursal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadSucursalData();
    } else {
      _diasSeleccionados.addAll(['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']);
    }
  }

  void _loadSucursalData() {
    final sucursal = widget.sucursal!;
    _nombreController.text = sucursal.nombre;
    _direccionController.text = sucursal.direccion;
    _telefonoController.text = sucursal.telefono;
    _emailController.text = sucursal.email ?? '';
    _gerenteController.text = sucursal.gerente ?? '';
    _latitudController.text = sucursal.latitud?.toString() ?? '';
    _longitudController.text = sucursal.longitud?.toString() ?? '';
    _activa = sucursal.activa;
    
    if (sucursal.horarioApertura != null) {
      final parts = sucursal.horarioApertura!.split(':');
      _horarioApertura = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    
    if (sucursal.horarioCierre != null) {
      final parts = sucursal.horarioCierre!.split(':');
      _horarioCierre = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    
    if (sucursal.diasLaborales != null) {
      _diasSeleccionados.addAll(sucursal.diasLaborales!);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _gerenteController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Sucursal' : 'Nueva Sucursal'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmarEliminar,
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
              _buildContacto(),
              const SizedBox(height: 24),
              _buildHorarios(),
              const SizedBox(height: 24),
              _buildEstado(),
              const SizedBox(height: 32),
              _buildBotones(),
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
                labelText: 'Nombre de la Sucursal *',
                hintText: 'Ej: Sucursal Centro',
                prefixIcon: Icon(Icons.store),
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
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección *',
                hintText: 'Ej: Zona 1, Guatemala City',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La dirección es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gerenteController,
              decoration: const InputDecoration(
                labelText: 'Gerente',
                hintText: 'Nombre del gerente',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContacto() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.contact_phone, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Contacto',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                hintText: 'Ej: 2222-1111',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El teléfono es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'sucursal@churrascos.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Email inválido';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

 

  Widget _buildHorarios() {
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
                  'Horarios de Atención',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Horario de Apertura'),
                    subtitle: Text(_horarioApertura?.format(context) ?? 'No seleccionado'),
                    leading: const Icon(Icons.access_time),
                    onTap: () => _seleccionarHorario(true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Horario de Cierre'),
                    subtitle: Text(_horarioCierre?.format(context) ?? 'No seleccionado'),
                    leading: const Icon(Icons.access_time_filled),
                    onTap: () => _seleccionarHorario(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Días Laborales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _todosDias.map((dia) {
                final isSelected = _diasSeleccionados.contains(dia);
                return FilterChip(
                  label: Text(dia),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _diasSeleccionados.add(dia);
                      } else {
                        _diasSeleccionados.remove(dia);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstado() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.toggle_on, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Estado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sucursal Activa'),
              subtitle: Text(_activa 
                  ? 'La sucursal está operando' 
                  : 'La sucursal está temporalmente cerrada'
              ),
              value: _activa,
              onChanged: (value) {
                setState(() {
                  _activa = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotones() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _guardarSucursal,
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
                : Text(_isEditing ? 'Actualizar Sucursal' : 'Crear Sucursal'),
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

  Future<void> _seleccionarHorario(bool esApertura) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: esApertura 
          ? (_horarioApertura ?? const TimeOfDay(hour: 8, minute: 0))
          : (_horarioCierre ?? const TimeOfDay(hour: 20, minute: 0)),
    );

    if (picked != null) {
      setState(() {
        if (esApertura) {
          _horarioApertura = picked;
        } else {
          _horarioCierre = picked;
        }
      });
    }
  }


  void _guardarSucursal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final sucursalRequest = SucursalCreateRequest(
          nombre: _nombreController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono: _telefonoController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          gerente: _gerenteController.text.trim().isEmpty ? null : _gerenteController.text.trim(),
          activa: _activa,
          latitud: _latitudController.text.isEmpty ? null : double.tryParse(_latitudController.text),
          longitud: _longitudController.text.isEmpty ? null : double.tryParse(_longitudController.text),
          horarioApertura: _horarioApertura != null 
              ? '${_horarioApertura!.hour.toString().padLeft(2, '0')}:${_horarioApertura!.minute.toString().padLeft(2, '0')}'
              : null,
          horarioCierre: _horarioCierre != null
              ? '${_horarioCierre!.hour.toString().padLeft(2, '0')}:${_horarioCierre!.minute.toString().padLeft(2, '0')}'
              : null,
          diasLaborales: _diasSeleccionados.isEmpty ? null : List.from(_diasSeleccionados),
        );

        bool success;
        if (_isEditing) {
          success = await _apiService.updateSucursal(widget.sucursal!.id, sucursalRequest);
        } else {
          final result = await _apiService.createSucursal(sucursalRequest);
          success = result.containsKey('id') || result.containsKey('success');
        }

        if (success) {
          if (_isEditing) {
            NotificationService().notificarSucursalActualizada(_nombreController.text.trim());
          } else {
            NotificationService().notificarSucursalCreada(_nombreController.text.trim());
          }
          
          Navigator.of(context).pop(true);
        } else {
          _showErrorSnackBar('Error al guardar la sucursal');
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

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Sucursal'),
        content: Text('¿Estás seguro de que deseas eliminar la sucursal "${widget.sucursal!.nombre}"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // cerrar
              
              setState(() {
                _isLoading = true;
              });

              try {
                final success = await _apiService.deleteSucursal(widget.sucursal!.id);
                if (success) {
                  Navigator.of(context).pop('deleted');
                } else {
                  _showErrorSnackBar('Error al eliminar la sucursal');
                }
              } catch (e) {
                _showErrorSnackBar('Error: ${e.toString()}');
              } finally {
                setState(() {
                  _isLoading = false;
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