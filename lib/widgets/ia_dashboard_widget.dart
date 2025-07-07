import 'package:flutter/material.dart';
import '../services/ia_service.dart';
import 'ia_chat_dialog.dart';

class IADashboardWidget extends StatefulWidget {
  const IADashboardWidget({super.key});

  @override
  State<IADashboardWidget> createState() => _IADashboardWidgetState();
}

class _IADashboardWidgetState extends State<IADashboardWidget> {
  final IAService _iaService = IAService();
  
  String? insights;
  bool isLoadingInsights = false;
  String? error;

  Future<void> _obtenerInsights() async {
    setState(() {
      isLoadingInsights = true;
      error = null;
    });

    try {
      final response = await _iaService.obtenerInsightsDashboard();
      
      if (response['success'] == true) {
        setState(() {
          insights = response['aiInsights'];
        });
      } else {
        setState(() {
          error = 'No se pudieron obtener insights';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al conectar con el servicio de IA: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingInsights = false;
      });
    }
  }

  void _abrirChat() {
    showDialog(
      context: context,
      builder: (context) => const IAChatDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.purple, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.purple,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Análisis y chatbot',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isLoadingInsights ? null : _obtenerInsights,
                        icon: isLoadingInsights
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.analytics),
                        label: Text(isLoadingInsights ? 'Analizando...' : 'Generar Insights'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _abrirChat,
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat IA'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: BorderSide(color: Colors.purple),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (insights != null) _buildInsightsContent(),
              if (error != null) _buildErrorContent(),
              if (insights == null && error == null) _buildWelcomeContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Recomendaciones',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insights!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Generado: ${DateTime.now().toString().substring(0, 16)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _obtenerInsights,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Actualizar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Error al obtener análisis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _obtenerInsights,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => _mostrarConfiguracion(),
                icon: const Icon(Icons.settings),
                label: const Text('Configuración'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.smart_toy,
            color: Colors.blue,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'IA',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haz clic en "Generar Insights" para obtener un análisis de negocio',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.blue.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }


  void _mostrarConfiguracion() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de IA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verificando configuración de OpenRouter...'),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _iaService.verificarConfiguracion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                final config = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          config['hasApiKey'] == true ? Icons.check_circle : Icons.error,
                          color: config['hasApiKey'] == true ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text('API Key: ${config['hasApiKey'] == true ? 'Configurada' : 'No configurada'}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Prefijo: ${config['apiKeyPrefix'] ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    Text('Timestamp: ${config['timestamp'] ?? 'N/A'}'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}