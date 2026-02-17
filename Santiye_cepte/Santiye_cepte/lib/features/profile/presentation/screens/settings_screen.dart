import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Ayarlar Ekranı
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _newJobAlerts = true;
  bool _bidUpdates = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bildirim Ayarları
          _buildSectionTitle('Bildirimler'),
          const SizedBox(height: 12),
          _buildCard([
            _buildSwitchTile(
              title: 'Push Bildirimleri',
              subtitle: 'Uygulama bildirimleri al',
              icon: Icons.notifications_active,
              value: _pushNotifications,
              onChanged: (value) => setState(() => _pushNotifications = value),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: 'E-posta Bildirimleri',
              subtitle: 'Önemli güncellemeler için e-posta al',
              icon: Icons.email,
              value: _emailNotifications,
              onChanged: (value) => setState(() => _emailNotifications = value),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: 'SMS Bildirimleri',
              subtitle: 'Acil durumlar için SMS al',
              icon: Icons.sms,
              value: _smsNotifications,
              onChanged: (value) => setState(() => _smsNotifications = value),
            ),
          ]),

          const SizedBox(height: 24),

          // Bildirim Tercihleri
          _buildSectionTitle('Bildirim Tercihleri'),
          const SizedBox(height: 12),
          _buildCard([
            _buildSwitchTile(
              title: 'Yeni İş İlanları',
              subtitle: 'Kriterlere uygun yeni işler',
              icon: Icons.work,
              value: _newJobAlerts,
              onChanged: (value) => setState(() => _newJobAlerts = value),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: 'Teklif Güncellemeleri',
              subtitle: 'Tekliflerinizle ilgili güncellemeler',
              icon: Icons.gavel,
              value: _bidUpdates,
              onChanged: (value) => setState(() => _bidUpdates = value),
            ),
          ]),

          const SizedBox(height: 24),

          // Görünüm
          _buildSectionTitle('Görünüm'),
          const SizedBox(height: 12),
          _buildCard([
            _buildSwitchTile(
              title: 'Karanlık Mod',
              subtitle: 'Göz yorgunluğunu azaltın',
              icon: Icons.dark_mode,
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Karanlık mod yakında eklenecek'),
                    backgroundColor: AppTheme.primaryOrange,
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 24),

          // Gizlilik ve Güvenlik
          _buildSectionTitle('Gizlilik ve Güvenlik'),
          const SizedBox(height: 12),
          _buildCard([
            _buildNavigationTile(
              title: 'Şifre Değiştir',
              subtitle: 'Hesap şifrenizi güncelleyin',
              icon: Icons.lock,
              onTap: () {
                // TODO: Open change password sheet
              },
            ),
            const Divider(height: 1),
            _buildNavigationTile(
              title: 'Gizlilik Ayarları',
              subtitle: 'Profil görünürlüğü ve veri paylaşımı',
              icon: Icons.privacy_tip,
              onTap: () {},
            ),
            const Divider(height: 1),
            _buildNavigationTile(
              title: 'İki Faktörlü Doğrulama',
              subtitle: 'Ekstra güvenlik katmanı',
              icon: Icons.security,
              onTap: () {},
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Yakında',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.warningYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Destek
          _buildSectionTitle('Yardım ve Destek'),
          const SizedBox(height: 12),
          _buildCard([
            _buildNavigationTile(
              title: 'Yardım Merkezi',
              subtitle: 'Sık sorulan sorular ve rehberler',
              icon: Icons.help,
              onTap: () {},
            ),
            const Divider(height: 1),
            _buildNavigationTile(
              title: 'Bize Ulaşın',
              subtitle: 'Destek ekibimize yazın',
              icon: Icons.support_agent,
              onTap: () {},
            ),
            const Divider(height: 1),
            _buildNavigationTile(
              title: 'Geri Bildirim',
              subtitle: 'Uygulama hakkında görüşleriniz',
              icon: Icons.feedback,
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 24),

          // Hakkında
          _buildSectionTitle('Uygulama'),
          const SizedBox(height: 12),
          _buildCard([
            _buildNavigationTile(
              title: 'Kullanım Koşulları',
              icon: Icons.article,
              onTap: () {},
            ),
            const Divider(height: 1),
            _buildNavigationTile(
              title: 'Gizlilik Politikası',
              icon: Icons.policy,
              onTap: () {},
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info, color: AppTheme.gray500),
              ),
              title: const Text('Versiyon'),
              trailing: const Text(
                '1.0.0',
                style: TextStyle(color: AppTheme.gray500),
              ),
            ),
          ]),

          const SizedBox(height: 32),

          // Delete Account
          _buildCard([
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_forever, color: AppTheme.errorRed),
              ),
              title: const Text(
                'Hesabı Sil',
                style: TextStyle(color: AppTheme.errorRed),
              ),
              subtitle: const Text(
                'Bu işlem geri alınamaz',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.gray500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value ? AppTheme.primaryOrange.withValues(alpha: 0.1) : AppTheme.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value ? AppTheme.primaryOrange : AppTheme.gray500,
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          HapticFeedback.lightImpact();
          onChanged(newValue);
        },
        activeThumbColor: AppTheme.primaryOrange,
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.gray500),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.gray400),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorRed),
            SizedBox(width: 12),
            Text('Hesabı Sil'),
          ],
        ),
        content: const Text(
          'Hesabınızı silmek istediğinizden emin misiniz?\n\n'
          'Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete account
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hesap silme işlemi başlatıldı'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
