import 'dart:async';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] == true,
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final ValueNotifier<List<AppNotification>> notificationsNotifier =
      ValueNotifier<List<AppNotification>>([]);
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  final StreamController<AppNotification> _notificationStreamController =
      StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get onNotificationReceived =>
      _notificationStreamController.stream;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final res = await ApiClient.instance.dio.get('/parent/notifications');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final rawList = res.data['data'] as List;
        final list = rawList
            .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
            .toList();
        notificationsNotifier.value = list;
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('[NotificationService] Fetch failed: $e');
    }
  }

  void addLocalNotification({
    required String title,
    required String message,
    String type = 'alert',
    Map<String, dynamic>? data,
  }) {
    final notif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      isRead: false,
      data: data,
    );

    notificationsNotifier.value = [notif, ...notificationsNotifier.value];
    _updateUnreadCount();
    _notificationStreamController.add(notif);
  }

  Future<void> markAsRead(String id) async {
    try {
      await ApiClient.instance.dio.patch('/parent/notifications/$id/read');
    } catch (_) {}

    notificationsNotifier.value = notificationsNotifier.value.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _updateUnreadCount();
  }

  Future<void> markAllAsRead() async {
    for (final n in notificationsNotifier.value.where((n) => !n.isRead)) {
      try {
        await ApiClient.instance.dio.patch('/parent/notifications/${n.id}/read');
      } catch (_) {}
    }

    notificationsNotifier.value = notificationsNotifier.value
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCountNotifier.value =
        notificationsNotifier.value.where((n) => !n.isRead).length;
  }

  /// Handles incoming FCM / remote push notification payloads
  void handleRemoteMessage(Map<String, dynamic> rawMessage) {
    final notification = rawMessage['notification'] as Map<String, dynamic>?;
    final data = rawMessage['data'] as Map<String, dynamic>? ?? {};

    final title = notification?['title']?.toString() ??
        data['title']?.toString() ??
        'नयी सूचना (New Notification)';
    final body = notification?['body']?.toString() ??
        data['message']?.toString() ??
        'आपके पास एक नया संदेश है';
    final type = data['type']?.toString() ?? 'alert';

    addLocalNotification(
      title: title,
      message: body,
      type: type,
      data: data,
    );
  }

  /// Register FCM device token with the backend
  Future<void> registerDeviceToken(String token) async {
    try {
      await ApiClient.instance.dio.post(
        '/auth/device-token',
        data: {'device_token': token, 'platform': defaultTargetPlatform.name},
      );
      debugPrint('[NotificationService] Device token registered successfully');
    } catch (e) {
      debugPrint('[NotificationService] Failed to register device token: $e');
    }
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
