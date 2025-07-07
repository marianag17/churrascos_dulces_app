import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/sucursal.dart';
import 'sucursal_form_screen.dart';

class SucursalDetailScreen extends StatefulWidget {
  final Sucursal sucursal;

  const SucursalDetailScreen({super.key, required this.sucursal});

  @override
  State<SucursalDetailScreen> createState() => _SucursalDetailScreenState();
}

class _SucursalDetailScreenState extends State<SucursalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  late Sucursal _sucursal;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); 
    _sucursal = widget.sucursal;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(_sucursal.nombre),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _editarSucursal,
        )
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Dirección', _sucursal.direccion, Icons.location_on),
          _buildInfoRow('Horario', '${_sucursal.horarioApertura} - ${_sucursal.horarioCierre}', Icons.access_time),
          _buildInfoRow('Estado', _sucursal.activa ? 'Activa' : 'Inactiva', Icons.check_circle),
          const SizedBox(height: 16),
          _buildActividadTab(),
        ],
      ),
    ),
  );
}




  Widget _buildActividadTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Actividad de Sucursal',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.add, color: Colors.blue),
                    ),
                    title: const Text('Sucursal Creada'),
                    subtitle: Text(_formatDateTime(_sucursal.fechaCreacion)),
                    trailing: const Icon(Icons.store),
                  ),
                  if (_sucursal.fechaModificacion != null)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        child: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      title: const Text('Última Modificación'),
                      subtitle: Text(_formatDateTime(_sucursal.fechaModificacion!)),
                      trailing: const Icon(Icons.update),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, 
      {bool isClickable = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: isClickable ? onTap : null,
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isClickable ? AppTheme.primaryColor : null,
                      decoration: isClickable ? TextDecoration.underline : null,
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

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _editarSucursal() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => SucursalFormScreen(sucursal: _sucursal),
      ),
    );

    if (result == true) {
      Navigator.of(context).pop('updated');
    }
  }



}
