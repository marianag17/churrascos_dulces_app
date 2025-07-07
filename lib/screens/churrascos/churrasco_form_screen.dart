import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_theme.dart';
import '../../models/churrasco.dart';
import '../../services/api_service.dart';

class ChurrascoFormScreen extends StatefulWidget {
  final Churrasco? churrasco;

  const ChurrascoFormScreen({super.key, this.churrasco});

  @override
  State<ChurrascoFormScreen> createState() => _ChurrascoFormScreenState();
}

class _ChurrascoFormScreenState extends State<ChurrascoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _precioBaseController = TextEditingController();
  final _cantidadPorcionesController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  
  List<Guarnicion> guarnicionesDisponibles = [];
  List<GuarnicionChurrascoRequest> guarnicionesSeleccionadas = [];
  
  int _tipoCarne = 0; // 0: Puyazo, 1: Culotte, 2: Costilla
  int _terminoCoccion = 0; // 0: Término medio, 1: Término tres cuartos, 2: Bien cocido
  int _tipoPlato = 0; // 0: Individual, 1: Familiar 3 porciones, 2: Familiar 5 porciones
  bool _disponible = true;
  bool _isLoading = false;
  bool _loadingGuarniciones = true;
  String? _error;
  bool get _isEditing => widget.churrasco != null;

  @override
  void initState() {
    super.initState();
    _loadGuarniciones();
    if (_isEditing) {
      _loadChurrascoData();
    } else {
      _cantidadPorcionesController.text = '1';
      _precioController.text = '0.00';
      _precioBaseController.text = '0.00';
    }
  }

  Future<void> _loadGuarniciones() async {
    setState(() {
      _loadingGuarniciones = true;
      _error = null;
    });

    try {
      final guarniciones = await _apiService.getGuarnicionesDisponibles();
      setState(() {
        guarnicionesDisponibles = guarniciones;
        _loadingGuarniciones = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingGuarniciones = false;
      });
    }
  }

  void _loadChurrascoData() {
    final churrasco = widget.churrasco!;
    _nombreController.text = churrasco.nombre;
    _descripcionController.text = churrasco.descripcion ?? '';
    _precioController.text = churrasco.precio.toString();
    _precioBaseController.text = churrasco.precioBase.toString();
    _cantidadPorcionesController.text = churrasco.cantidadPorciones.toString();
    
    _tipoCarne = churrasco.tipoCarne;
    _terminoCoccion = churrasco.terminoCoccion;
    _tipoPlato = churrasco.tipoPlato;
    _disponible = churrasco.disponible;
    
    
    if (churrasco.guarniciones != null) {
      guarnicionesSeleccionadas = churrasco.guarniciones!.map((gc) => 
        GuarnicionChurrascoRequest(
          guarnicionId: gc.guarnicionId,
          cantidadPorciones: gc.cantidadPorciones,
          esExtra: gc.esExtra,
        )
      ).toList();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _precioBaseController.dispose();
    _cantidadPorcionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Churrasco' : 'Nuevo Churrasco'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _mostrarAyuda,
          ),
        ],
      ),
      body: _loadingGuarniciones
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
                        _buildConfiguracionCarne(),
                        const SizedBox(height: 24),
                        _buildPrecios(),
                        const SizedBox(height: 24),
                        _buildGuarnicionesSection(),
                        const SizedBox(height: 32),
                        _buildBotonesGuardar(),
                      ],
                    ),
                  ),
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
            _error!,
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

  Widget _buildInformacionBasica() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppTheme.primaryColor),
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
                labelText: 'Nombre del Churrasco *',
                hintText: 'Ej: Churrasco Premium Puyazo',
                prefixIcon: Icon(Icons.restaurant_menu),
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
                hintText: 'Describe el churrasco...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Churrasco Disponible'),
              subtitle: Text(_disponible 
                  ? 'Disponible para pedidos' 
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

  Widget _buildConfiguracionCarne() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.set_meal, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Configuración de Carne',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _tipoCarne,
              decoration: const InputDecoration(
                labelText: 'Tipo de Carne *',
                prefixIcon: Icon(Icons.restaurant),
              ),
              items: AppConfig.tiposCarne.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoCarne = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _terminoCoccion,
              decoration: const InputDecoration(
                labelText: 'Término de Cocción *',
                prefixIcon: Icon(Icons.whatshot),
              ),
              items: AppConfig.terminosCoccion.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _terminoCoccion = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _tipoPlato,
              decoration: const InputDecoration(
                labelText: 'Tipo de Plato *',
                prefixIcon: Icon(Icons.dining),
              ),
              items: AppConfig.tiposPlato.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _tipoPlato = value!;
                  switch (value) {
                    case 0: 
                      _cantidadPorcionesController.text = '1';
                      break;
                    case 1: 
                      _cantidadPorcionesController.text = '3';
                      break;
                    case 2: 
                      _cantidadPorcionesController.text = '5';
                      break;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cantidadPorcionesController,
              decoration: const InputDecoration(
                labelText: 'Cantidad de Porciones *',
                hintText: '1',
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La cantidad es requerida';
                }
                final cantidad = int.tryParse(value);
                if (cantidad == null || cantidad < 1) {
                  return 'Debe ser un número mayor a 0';
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
                    controller: _precioBaseController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Base *',
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
                    controller: _precioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio Final *',
                      hintText: '0.00',
                      prefixText: 'Q',
                      prefixIcon: Icon(Icons.sell),
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
                      'El precio final incluye guarniciones base. Las extras se cobran aparte.',
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

  Widget _buildGuarnicionesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Guarniciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _agregarGuarnicion,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (guarnicionesSeleccionadas.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No hay guarniciones seleccionadas',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca "Agregar" para incluir guarniciones',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...guarnicionesSeleccionadas.asMap().entries.map((entry) {
                final index = entry.key;
                final guarnicion = entry.value;
                final guarnicionInfo = guarnicionesDisponibles
                    .firstWhere((g) => g.id == guarnicion.guarnicionId);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: guarnicion.esExtra 
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      child: Icon(
                        Icons.restaurant,
                        color: guarnicion.esExtra ? Colors.orange : Colors.green,
                      ),
                    ),
                    title: Text(guarnicionInfo.nombre),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${guarnicion.cantidadPorciones} porción${guarnicion.cantidadPorciones > 1 ? 'es' : ''}'),
                        Text(
                          guarnicion.esExtra ? 'Extra' : 'Incluida',
                          style: TextStyle(
                            color: guarnicion.esExtra ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (guarnicion.esExtra)
                          Text(
                            AppConfig.formatCurrency(guarnicionInfo.precioExtra * guarnicion.cantidadPorciones),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editarGuarnicion(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _quitarGuarnicion(index),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
            onPressed: _isLoading ? null : _guardarChurrasco,
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
                : Text(_isEditing ? 'Actualizar Churrasco' : 'Crear Churrasco'),
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

  void _agregarGuarnicion() {
    if (guarnicionesDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay guarniciones disponibles'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _mostrarDialogoGuarnicion();
  }

  void _editarGuarnicion(int index) {
    _mostrarDialogoGuarnicion(guarnicionExistente: guarnicionesSeleccionadas[index], index: index);
  }

  void _quitarGuarnicion(int index) {
    setState(() {
      guarnicionesSeleccionadas.removeAt(index);
    });
  }

  void _mostrarDialogoGuarnicion({GuarnicionChurrascoRequest? guarnicionExistente, int? index}) {
    int? guarnicionSeleccionada = guarnicionExistente?.guarnicionId;
    int cantidadPorciones = guarnicionExistente?.cantidadPorciones ?? 1;
    bool esExtra = guarnicionExistente?.esExtra ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(guarnicionExistente == null ? 'Agregar Guarnición' : 'Editar Guarnición'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: guarnicionSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Guarnición',
                ),
                items: guarnicionesDisponibles.map((guarnicion) {
                  return DropdownMenuItem(
                    value: guarnicion.id,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(guarnicion.nombre),
                        if (guarnicion.precioExtra > 0)
                          Text(
                            'Extra: ${AppConfig.formatCurrency(guarnicion.precioExtra)}',
                            style: const TextStyle(fontSize: 12, color: Colors.orange),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    guarnicionSeleccionada = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: cantidadPorciones.toString(),
                decoration: const InputDecoration(
                  labelText: 'Cantidad de Porciones',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  cantidadPorciones = int.tryParse(value) ?? 1;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Es Guarnición Extra'),
                subtitle: const Text('Se cobra adicional'),
                value: esExtra,
                onChanged: (value) {
                  setDialogState(() {
                    esExtra = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (guarnicionSeleccionada != null) {
                  final nuevaGuarnicion = GuarnicionChurrascoRequest(
                    guarnicionId: guarnicionSeleccionada!,
                    cantidadPorciones: cantidadPorciones,
                    esExtra: esExtra,
                  );

                  setState(() {
                    if (index != null) {
                      guarnicionesSeleccionadas[index] = nuevaGuarnicion;
                    } else {
                      guarnicionesSeleccionadas.add(nuevaGuarnicion);
                    }
                  });

                  Navigator.of(context).pop();
                }
              },
              child: Text(guarnicionExistente == null ? 'Agregar' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }


  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Crear Churrasco'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Tipo de Carne: Puyazo, Culotte o Costilla'),
              SizedBox(height: 8),
              Text('• Término: Nivel de cocción de la carne'),
              SizedBox(height: 8),
              Text('• Tipo de Plato: Individual o Familiar'),
              SizedBox(height: 8),
              Text('• Guarniciones: Incluidas vs Extras (costo adicional)'),
              SizedBox(height: 8),
              Text('• Precio Base: Costo sin guarniciones extras'),
              SizedBox(height: 8),
              Text('• Precio Final: Precio de venta al cliente'),
              SizedBox(height: 16),
              Text('Tip: Las guarniciones Incluidas no tienen costo extra, las Extra si'),
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

  void _guardarChurrasco() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = ChurrascoCreateRequest(
          nombre: _nombreController.text.trim(),
          precio: double.parse(_precioController.text),
          descripcion: _descripcionController.text.trim().isEmpty 
              ? null : _descripcionController.text.trim(),
          tipoCarne: _tipoCarne,
          terminoCoccion: _terminoCoccion,
          tipoPlato: _tipoPlato,
          cantidadPorciones: int.parse(_cantidadPorcionesController.text),
          precioBase: double.parse(_precioBaseController.text),
          disponible: _disponible,
          guarniciones: guarnicionesSeleccionadas,
        );

        bool success;
        if (_isEditing) {
          success = await _apiService.updateChurrasco(widget.churrasco!.id, request);
        } else {
          final result = await _apiService.createChurrasco(request);
          success = result.containsKey('id') || result.containsKey('success');
        }

        if (success) {
          Navigator.of(context).pop(true);
        } else {
          _showErrorSnackBar('Error al guardar el churrasco');
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
}