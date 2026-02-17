import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../services/supabase_service.dart';
import 'edit_profile_screen.dart';
import 'security_settings_screen.dart';
import 'notification_settings_screen.dart';

/// Profil Ekranı
/// Kullanıcı profil bilgilerini görüntüleme ve düzenleme
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final profile = authProvider.userProfile;

        if (profile == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryOrange),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profil Kartı
              _buildProfileCard(profile, authProvider),

              const SizedBox(height: 24),

              // İstatistikler
              _buildStatsSection(profile),

              const SizedBox(height: 24),

              // Menü Seçenekleri
              _buildMenuSection(context, authProvider),

              const SizedBox(height: 24),

              // Çıkış Butonu
              _buildLogoutButton(context, authProvider),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(
    Map<String, dynamic> profile,
    AuthProvider authProvider,
  ) {
    final role = profile['role'] ?? 'worker';
    final roleName = AppConstants.userRoles[role] ?? role;
    final isVerified = profile['is_verified'] ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.orange,
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: profile['avatar_url'] != null
                    ? ClipOval(
                        child: Image.network(
                          profile['avatar_url'],
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // İsim ve Rol
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile['full_name'] ?? 'Kullanıcı',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 16,
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              roleName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // İletişim Bilgileri
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                profile['email'] ?? '',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),

          if (profile['phone'] != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  profile['phone'],
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],

          if (profile['district'] != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  '${profile['district']}, Antalya',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> profile) {
    final role = profile['role'] ?? 'worker';

    // Role göre farklı istatistikler - Gerçek veriler Supabase'den
    List<Map<String, dynamic>> stats;

    if (role == 'contractor') {
      stats = [
        {
          'icon': Icons.work,
          'value': '${profile['job_count'] ?? 0}',
          'label': 'İş İlanı',
        },
        {
          'icon': Icons.handshake,
          'value': '${profile['completed_jobs'] ?? 0}',
          'label': 'Tamamlanan',
        },
        {
          'icon': Icons.star,
          'value': '${(profile['rating'] ?? 0.0).toStringAsFixed(1)}',
          'label': 'Puan',
        },
      ];
    } else if (role == 'subcontractor') {
      stats = [
        {
          'icon': Icons.receipt_long,
          'value': '${profile['bid_count'] ?? 0}',
          'label': 'Teklif',
        },
        {
          'icon': Icons.check_circle,
          'value': '${profile['accepted_bids'] ?? 0}',
          'label': 'Kabul',
        },
        {
          'icon': Icons.star,
          'value': '${(profile['rating'] ?? 0.0).toStringAsFixed(1)}',
          'label': 'Puan',
        },
      ];
    } else {
      stats = [
        {
          'icon': Icons.work_history,
          'value': '${profile['experience_years'] ?? 0}',
          'label': 'Yıl Deneyim',
        },
        {
          'icon': Icons.handshake,
          'value': '${profile['completed_jobs'] ?? 0}',
          'label': 'İş',
        },
        {
          'icon': Icons.star,
          'value': '${(profile['rating'] ?? 0.0).toStringAsFixed(1)}',
          'label': 'Puan',
        },
      ];
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats
            .map(
              (stat) => _buildStatItem(
                icon: stat['icon'],
                value: stat['value'],
                label: stat['label'],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryOrange, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.gray900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthProvider authProvider) {
    final menuItems = [
      {
        'icon': Icons.person_outline,
        'title': 'Profili Düzenle',
        'subtitle': 'Kişisel bilgilerinizi güncelleyin',
        'onTap': () => _showEditProfile(context),
      },
      {
        'icon': Icons.security,
        'title': 'Güvenlik',
        'subtitle': 'Şifre ve güvenlik ayarları',
        'onTap': () => _showSecuritySettings(context),
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Bildirimler',
        'subtitle': 'Bildirim tercihlerinizi ayarlayın',
        'onTap': () => _showNotificationSettings(context),
      },
      {
        'icon': Icons.help_outline,
        'title': 'Yardım & Destek',
        'subtitle': 'SSS ve müşteri desteği',
        'onTap': () => _showHelp(context),
      },
      {
        'icon': Icons.info_outline,
        'title': 'Hakkında',
        'subtitle': 'Uygulama bilgileri ve sözleşmeler',
        'onTap': () => _showAbout(context),
      },
    ];

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
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Column(
            children: [
              _buildMenuItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                subtitle: item['subtitle'] as String,
                onTap: item['onTap'] as VoidCallback,
              ),
              if (index < menuItems.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.gray100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.gray600, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.gray400),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirmation(context, authProvider),
        icon: const Icon(Icons.logout),
        label: const Text('Çıkış Yap'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.errorRed,
          side: const BorderSide(color: AppTheme.errorRed),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const EditProfileScreen()));
  }

  void _showSecuritySettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.support_agent,
              size: 64,
              color: AppTheme.primaryOrange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Yardım & Destek',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sorularınız için bize ulaşın',
              style: TextStyle(fontSize: 14, color: AppTheme.gray500),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.email, color: AppTheme.primaryOrange),
              title: const Text('E-posta'),
              subtitle: const Text('destek@santiyecepte.com'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: AppTheme.primaryOrange),
              title: const Text('Telefon'),
              subtitle: const Text('0850 123 45 67'),
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.construction,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Şantiye Cepte',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versiyon 1.0.0',
              style: TextStyle(fontSize: 14, color: AppTheme.gray500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Antalya bölgesinin inşaat sektörü pazaryeri. '
              'Müteahhitler, taşeronlar ve ustalar için güvenilir platform.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.gray600),
            ),
            const SizedBox(height: 16),
            const Text(
              '© 2024 Şantiye Cepte',
              style: TextStyle(fontSize: 12, color: AppTheme.gray400),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Çıkış Yap'),
        content: const Text(
          'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}
