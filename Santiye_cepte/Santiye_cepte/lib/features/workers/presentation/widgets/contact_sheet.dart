import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// İşçi İletişim Modalı
/// Usta/işçi ile iletişim kurma seçenekleri
class ContactSheet extends StatelessWidget {
  final String workerName;
  final String? phone;
  final String? email;
  final bool isPremium;

  const ContactSheet({
    super.key,
    required this.workerName,
    this.phone,
    this.email,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'İletişim Bilgileri',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Options
            if (isPremium || phone != null || email != null) ...[
              if (phone != null)
                _buildContactOption(
                  context,
                  icon: Icons.phone,
                  iconColor: AppTheme.successGreen,
                  title: 'Telefon ile Ara',
                  subtitle: phone!,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Launch phone dialer
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$phone aranıyor...'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                ),

              if (phone != null)
                _buildContactOption(
                  context,
                  icon: Icons.message,
                  iconColor: AppTheme.successGreen,
                  title: 'WhatsApp ile Mesaj',
                  subtitle: 'Hızlı mesajlaşma',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Open WhatsApp
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('WhatsApp açılıyor...'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  },
                ),

              if (email != null)
                _buildContactOption(
                  context,
                  icon: Icons.email,
                  iconColor: AppTheme.infoBlue,
                  title: 'E-posta Gönder',
                  subtitle: email!,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // TODO: Open email client
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('E-posta uygulaması açılıyor...'),
                        backgroundColor: AppTheme.infoBlue,
                      ),
                    );
                  },
                ),

              _buildContactOption(
                context,
                icon: Icons.chat_bubble,
                iconColor: AppTheme.primaryOrange,
                title: 'Uygulama İçi Mesaj',
                subtitle: 'Güvenli mesajlaşma',
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: Open in-app chat
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mesajlaşma yakında eklenecek'),
                      backgroundColor: AppTheme.primaryOrange,
                    ),
                  );
                },
              ),
            ] else ...[
              // Not Premium - Show upgrade prompt
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.warningYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.warningYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: AppTheme.warningYellow,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Premium Üyelik Gerekli',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'İşçilerin iletişim bilgilerini görmek için Premium üye olmanız gerekiyor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Navigate to subscription
                        },
                        icon: const Icon(Icons.diamond),
                        label: const Text('Premium\'a Geç'),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'İptal',
                  style: TextStyle(color: AppTheme.gray600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.gray400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// İletişim modalını göster
void showContactSheet(
  BuildContext context, {
  required String workerName,
  String? phone,
  String? email,
  bool isPremium = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ContactSheet(
      workerName: workerName,
      phone: phone,
      email: email,
      isPremium: isPremium,
    ),
  );
}
