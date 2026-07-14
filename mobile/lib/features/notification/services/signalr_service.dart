import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/notification/services/local_notification_service.dart';
import 'dart:math';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _hubConnection;
  Function(Map<String, dynamic>)? onNotificationReceived;

  Future<void> initConnection() async {
    if (_hubConnection != null && _hubConnection!.state == HubConnectionState.Connected) {
      return;
    }

    String baseUrl = 'http://localhost:5063';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.33.87.130:5063';
    }
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final serverUrl = '$baseUrl/hubs/notifications?access_token=$token';

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl)
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on('ReceiveNotification', _handleNotification);

    try {
      await _hubConnection?.start();
      debugPrint('SignalR connected');
    } catch (e) {
      debugPrint('Error starting SignalR: $e');
    }
  }

  void _handleNotification(List<dynamic>? parameters) {
    if (parameters != null && parameters.isNotEmpty) {
      final data = parameters.first as Map<String, dynamic>;
      
      // Trigger local notification
      LocalNotificationService().showNotification(
        id: Random().nextInt(100000),
        title: data['title'] ?? 'Thông báo mới',
        body: data['message'] ?? '',
      );

      if (onNotificationReceived != null) {
        onNotificationReceived!(data);
      }
    }
  }

  Future<void> stopConnection() async {
    await _hubConnection?.stop();
  }
}
