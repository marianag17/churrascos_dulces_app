import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class IAService {
  static const String _baseUrl = AppConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  Future<Map<String, dynamic>> obtenerInsightsDashboard() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/ia/dashboard-insights'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener insights: $e');
    }
  }

  Future<Map<String, dynamic>> enviarMensajeChat(
    String mensaje, {
    String? conversationId,
    String? userId,
  }) async {
    try {
      final requestBody = {
        'message': mensaje,
        'conversationId': conversationId ?? 'conv_${DateTime.now().millisecondsSinceEpoch}',
        'userId': userId ?? 'user_default',
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl/ia/chat'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error en chat: $e');
    }
  }

  Future<Map<String, dynamic>> verificarConfiguracion() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/ia/test-config'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al verificar configuración: $e');
    }
  }
}

class IAInsight {
  final bool success;
  final String aiInsights;
  final Map<String, dynamic>? dashboardData;
  final DateTime timestamp;

  IAInsight({
    required this.success,
    required this.aiInsights,
    this.dashboardData,
    required this.timestamp,
  });

  factory IAInsight.fromJson(Map<String, dynamic> json) {
    return IAInsight(
      success: json['success'] ?? false,
      aiInsights: json['aiInsights'] ?? '',
      dashboardData: json['dashboardData'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ChatResponse {
  final bool success;
  final String response;
  final String conversationId;
  final DateTime timestamp;

  ChatResponse({
    required this.success,
    required this.response,
    required this.conversationId,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] ?? false,
      response: json['response'] ?? '',
      conversationId: json['conversationId'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ChatMessage {
  final String role; 
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}