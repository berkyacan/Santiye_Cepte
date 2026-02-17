import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'notifications_provider.dart';

/// Bildirimler Ekranı
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final provider = context.read<NotificationsProvider>();
    // Zaten yüklendiyse tekrar yükleme
    if (provider.isInitialized && provider.notifications.isNotEmpty) return;

    await provider.loadNotifications();

    // Eğer gerçek bildirim yoksa demo yükle
    if (provider.notifications.isEmpty && provider.error != null) {
      provider.loadDemoNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.gray50,
          appBar: AppBar(
            title: const Text('Bildirimler'),
            actions: [
              if (provider.unreadCount > 0)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    provider.markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all, size: 20),
                  label: const Text('Tümünü Oku'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                ),
            ],
          ),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildBody(NotificationsProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }

    if (provider.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppTheme.primaryOrange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          return _NotificationCard(
            notification: provider.notifications[index],
            onTap: () => _handleNotificationTap(provider.notifications[index]),
            onDismiss: () {
              provider.deleteNotification(provider.notifications[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.infoBlue.withValues(alpha: 0.15),
                      AppTheme.infoBlue.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppTheme.infoBlue.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 56,
                  color: AppTheme.infoBlue,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Henüz Bildirim Yok',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Yeni iş ilanları, teklifler ve\nmesajlar burada görünecek',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.gray500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    final provider = context.read<NotificationsProvider>();

    // Okundu olarak işaretle
    if (!notification.isRead) {
      provider.markAsRead(notification.id);
    }

    // TODO: actionUrl'a göre yönlendir
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.title),
        backgroundColor: AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Bildirim Kartı
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.errorRed,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (_) => onDismiss(),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead
                  ? Colors.white
                  : AppTheme.primaryOrange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: notification.isRead
                  ? null
                  : Border.all(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                      width: 1,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // İkon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.type.icon,
                    color: _getTypeColor(),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                color: AppTheme.gray900,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.newJob:
        return AppTheme.primaryOrange;
      case NotificationType.bidReceived:
        return AppTheme.infoBlue;
      case NotificationType.bidAccepted:
        return AppTheme.successGreen;
      case NotificationType.bidRejected:
        return AppTheme.errorRed;
      case NotificationType.message:
        return AppTheme.secondaryNavy;
      case NotificationType.system:
        return AppTheme.gray500;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd MMM yyyy', 'tr').format(dateTime);
    }
  }
}
