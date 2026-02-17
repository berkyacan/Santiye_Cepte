import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

/// Bildirim türleri
enum NotificationType {
  newJob('new_job', 'Yeni İş İlanı', Icons.work),
  bidReceived('bid_received', 'Teklif Alındı', Icons.gavel),
  bidAccepted('bid_accepted', 'Teklif Kabul Edildi', Icons.check_circle),
  bidRejected('bid_rejected', 'Teklif Reddedildi', Icons.cancel),
  message('message', 'Yeni Mesaj', Icons.chat_bubble),
  system('system', 'Sistem Bildirimi', Icons.info);

  final String value;
  final String turkishName;
  final IconData icon;

  const NotificationType(this.value, this.turkishName, this.icon);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

/// Bildirim modeli
class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.actionUrl,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: NotificationType.fromString(json['type'] ?? 'system'),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      actionUrl: json['action_url'],
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type.value,
    'title': title,
    'body': body,
    'action_url': actionUrl,
    'data': data,
    'is_read': isRead,
    'created_at': createdAt.toIso8601String(),
  };
}

/// Bildirim Provider
class NotificationsProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  /// Bildirimleri yükle
  Future<void> loadNotifications() async {
    if (SupabaseService.currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', SupabaseService.currentUser!.id)
          .order('created_at', ascending: false)
          .limit(50);

      _notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      _error = 'Bildirimler yüklenemedi: $e';
      // Eğer tablo yoksa boş liste göster
      _notifications = [];
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  /// Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      // Lokal güncelle
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = NotificationModel(
          id: notification.id,
          userId: notification.userId,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          actionUrl: notification.actionUrl,
          data: notification.data,
          isRead: true,
          createdAt: notification.createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  /// Tüm bildirimleri okundu olarak işaretle
  Future<void> markAllAsRead() async {
    if (SupabaseService.currentUser == null) return;

    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', SupabaseService.currentUser!.id)
          .eq('is_read', false);

      // Lokal güncelle
      _notifications = _notifications
          .map(
            (n) => NotificationModel(
              id: n.id,
              userId: n.userId,
              type: n.type,
              title: n.title,
              body: n.body,
              actionUrl: n.actionUrl,
              data: n.data,
              isRead: true,
              createdAt: n.createdAt,
            ),
          )
          .toList();
      notifyListeners();
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  /// Bildirimi sil
  Future<void> deleteNotification(String notificationId) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  /// Demo bildirimler oluştur (geliştirme için)
  void loadDemoNotifications() {
    _notifications = [
      NotificationModel(
        id: '1',
        userId: 'demo',
        type: NotificationType.newJob,
        title: 'Yeni İş İlanı',
        body: 'Muratpaşa bölgesinde yeni bir boya işi var.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2',
        userId: 'demo',
        type: NotificationType.bidReceived,
        title: 'Yeni Teklif',
        body: 'Ahmet Usta, ilanınıza 15.000₺ teklif verdi.',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3',
        userId: 'demo',
        type: NotificationType.bidAccepted,
        title: 'Teklifiniz Kabul Edildi',
        body: 'Elektrik işi teklifiniz kabul edildi!',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: '4',
        userId: 'demo',
        type: NotificationType.message,
        title: 'Yeni Mesaj',
        body: 'Mehmet Bey size bir mesaj gönderdi.',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '5',
        userId: 'demo',
        type: NotificationType.system,
        title: 'Hoş Geldiniz!',
        body: 'Şantiye Cepte\'ye hoş geldiniz. Profilinizi tamamlayın.',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    notifyListeners();
  }
}
