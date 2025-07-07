import 'package:flutter/material.dart';
import '../services/ia_service.dart';

class IAChatDialog extends StatefulWidget {
  const IAChatDialog({super.key});

  @override
  State<IAChatDialog> createState() => _IAChatDialogState();
}

class _IAChatDialogState extends State<IAChatDialog> {
  final IAService _iaService = IAService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatMessage> messages = [];
  bool isLoading = false;
  String conversationId = '';

  @override
  void initState() {
    super.initState();
    conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    final mensaje = _messageController.text.trim();
    if (mensaje.isEmpty || isLoading) return;

    // Agregar mensaje del usuario
    setState(() {
      messages.add(ChatMessage(
        role: 'user',
        content: mensaje,
        timestamp: DateTime.now(),
      ));
      isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _iaService.enviarMensajeChat(
        mensaje,
        conversationId: conversationId,
      );

      if (response['success'] == true) {
        setState(() {
          messages.add(ChatMessage(
            role: 'assistant',
            content: response['response'],
            timestamp: DateTime.now(),
          ));
        });
      } else {
        setState(() {
          messages.add(ChatMessage(
            role: 'assistant',
            content: 'Lo siento, no pude procesar tu mensaje. Intenta de nuevo.',
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(
          role: 'assistant',
          content: 'Error de conexión: ${e.toString()}',
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _limpiarChat() {
    setState(() {
      messages.clear();
      conversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
    });
  }

  void _usarSugerencia(String sugerencia) {
    _messageController.text = sugerencia;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Asistente Virtual - Churrascos & Dulces',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Área de mensajes
            Expanded(
              child: Container(
                color: Colors.grey.shade50,
                child: messages.isEmpty
                    ? _buildWelcomeContent()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && isLoading) {
                            return _buildTypingIndicator();
                          }
                          return _buildMessageBubble(messages[index]);
                        },
                      ),
              ),
            ),

            // Área de input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                children: [
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _limpiarChat,
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Limpiar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Input de mensaje
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Escribe tu pregunta aquí...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _enviarMensaje(),
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: isLoading ? null : _enviarMensaje,
                        mini: true,
                        backgroundColor: Colors.purple,
                        child: isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 48,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Hola! Soy tu asistente virtual',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Puedo ayudarte con información sobre productos, ventas, inventario y más.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Preguntas sugeridas:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('¿Cuáles son mis productos más vendidos?'),
                _buildSuggestionChip('¿Qué combo me recomiendas?'),
                _buildSuggestionChip('¿Cómo está mi inventario?'),
                _buildSuggestionChip('Análisis de ventas del mes'),
                _buildSuggestionChip('¿Qué dulce es más popular?'),
                _buildSuggestionChip('Recetas de churrascos'),
                _buildSuggestionChip('Control de temperatura de carnes'),
                _buildSuggestionChip('Gestión de proveedores'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(
        suggestion,
        style: const TextStyle(fontSize: 12),
      ),
      onPressed: () => _usarSugerencia(suggestion),
      backgroundColor: Colors.purple.withOpacity(0.1),
      side: BorderSide(color: Colors.purple.withOpacity(0.3)),
      labelStyle: TextStyle(color: Colors.purple.shade700),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple.withOpacity(0.1),
              child: const Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.purple : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.purple.withOpacity(0.1),
            child: const Icon(
              Icons.smart_toy,
              size: 16,
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.3, end: 1.0),
        duration: Duration(milliseconds: 600 + (index * 200)),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

// Modelo para los mensajes del chat
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final String? metadata;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }
}