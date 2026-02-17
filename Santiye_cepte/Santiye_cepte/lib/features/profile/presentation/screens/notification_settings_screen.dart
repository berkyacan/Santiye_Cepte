import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Bildirim Ayarları Ekranı
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Bildirim ayarları
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  // Bildirim türleri
  bool _newJobNotifications = true;
  bool _bidNotifications = true;
  bool _messageNotifications = true;
  bool _marketingNotifications = false;
  bool _systemNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(title: const Text('Bildirim Ayarları')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bildirim Kanalları
            _buildSectionTitle('Bildirim Kanalları'),
            const SizedBox(height: 12),
            _buildNotificationChannelsCard(),

            const SizedBox(height: 24),

            // Bildirim Türleri
            _buildSectionTitle('Bildirim Türleri'),
            const SizedBox(height: 12),
            _buildNotificationTypesCard(),

            const SizedBox(height: 24),

            // Sessiz Saatler
            _buildSectionTitle('Sessiz Saatler'),
            const SizedBox(height: 12),
            _buildQuietHoursCard(),

            const SizedBox(height: 32),

            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Ayarları Kaydet'),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.gray700,
      ),
    );
  }

  Widget _buildNotificationChannelsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_active,
            iconColor: AppTheme.primaryOrange,
            title: 'Push Bildirimleri',
            subtitle: 'Anlık bildirimler alın',
            value: _pushNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _pushNotifications = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            iconColor: AppTheme.infoBlue,
            title: 'E-posta Bildirimleri',
            subtitle: 'Önemli güncellemeler e-posta ile gönderilsin',
            value: _emailNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _emailNotifications = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchTile(
            icon: Icons.sms_outlined,
            iconColor: AppTheme.successGreen,
            title: 'SMS Bildirimleri',
            subtitle: 'Kritik bildirimler SMS ile gönderilsin',
            value: _smsNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _smsNotifications = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.work_outline,
            iconColor: AppTheme.primaryOrange,
            title: 'Yeni İş İlanları',
            subtitle: 'Size uygun yeni iş ilanları',
            value: _newJobNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _newJobNotifications = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchTile(
            icon: Icons.gavel_outlined,
            iconColor: AppTheme.secondaryNavy,
            title: 'Teklif Güncellemeleri',
            subtitle: 'Tekliflerinizle ilgili güncellemeler',
            value: _bidNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _bidNotifications = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchTile(
            icon: Icons.chat_bubble_outline,
            iconColor: AppTheme.infoBlue,
            title: 'Mesajlar',
            subtitle: 'Yeni mesaj bildirimleri',
            value: _messageNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _messageNotifications = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchTile(
            icon: Icons.campaign_outlined,
            iconColor: AppTheme.warningYellow,
            title: 'Pazarlama',
            subtitle: 'Kampanya ve indirim bildirimleri',
            value: _marketingNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _marketingNotifications = value);
            },
          ),
          const Divider(height: 1, indent: 56),
          _buildSwitchTile(
            icon: Icons.settings_outlined,
            iconColor: AppTheme.gray500,
            title: 'Sistem Bildirimleri',
            subtitle: 'Güvenlik ve hesap güncellemeleri',
            value: _systemNotifications,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              setState(() => _systemNotifications = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bedtime_outlined,
                  color: AppTheme.secondaryNavy,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sessiz Saatler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '22:00 - 08:00 arası bildirim gelmez',
                      style: TextStyle(fontSize: 13, color: AppTheme.gray500),
                    ),
                  ],
                ),
              ),
              Switch(
                value: true,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  // TODO: Implement quiet hours toggle
                },
                activeColor: AppTheme.primaryOrange,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Saat Aralığı
          Row(
            children: [
              Expanded(child: _buildTimeButton('22:00', 'Başlangıç')),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward, color: AppTheme.gray400),
              ),
              Expanded(child: _buildTimeButton('08:00', 'Bitiş')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String time, String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: Show time picker
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.gray50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
            ),
          ],
        ),
      ),
    );
  }

  void _saveSettings() {
    // TODO: Save settings to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bildirim ayarları kaydedildi'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
    Navigator.pop(context);
  }
}
