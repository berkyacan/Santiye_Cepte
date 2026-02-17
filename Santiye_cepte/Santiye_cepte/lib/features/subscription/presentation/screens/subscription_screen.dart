import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/subscription_provider.dart';

/// Abonelik Yönetimi Ekranı
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  void _loadSubscription() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryOrange),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mevcut Durum Kartı
              _buildCurrentStatusCard(provider),

              const SizedBox(height: 24),

              // Deneme Süresi veya Abonelik Detayları
              if (provider.isInTrial)
                _buildTrialCard(provider)
              else if (provider.isActive)
                _buildActiveSubscriptionCard(provider)
              else
                _buildExpiredCard(provider),

              const SizedBox(height: 24),

              // Plan Detayları
              _buildPlanCard(),

              const SizedBox(height: 24),

              // Özellikler
              _buildFeaturesSection(),

              const SizedBox(height: 24),

              // Abone Ol Butonu
              if (!provider.isActive) _buildSubscribeButton(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentStatusCard(SubscriptionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: provider.hasActiveSubscription
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              )
            : const LinearGradient(
                colors: [AppTheme.gray600, AppTheme.gray700],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: provider.hasActiveSubscription
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(provider.statusIcon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.status.turkishName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.statusDescription,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (provider.hasActiveSubscription) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 20),

            // Kalan Süre Göstergesi
            _buildRemainingTimeIndicator(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildRemainingTimeIndicator(SubscriptionProvider provider) {
    final remainingDays = provider.remainingDays;
    final totalDays = provider.isInTrial ? 30 : 30; // 30 günlük döngü
    final progress = remainingDays / totalDays;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kalan Süre',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
            Text(
              '$remainingDays gün',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
        if (provider.endDate != null) ...[
          const SizedBox(height: 8),
          Text(
            'Bitiş: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(provider.endDate!)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrialCard(SubscriptionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
        border: Border.all(
          color: AppTheme.infoBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppTheme.infoBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ücretsiz Deneme Süresi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '30 gün boyunca tüm özellikleri ücretsiz deneyin',
                      style: TextStyle(color: AppTheme.gray500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.warningYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.warningYellow,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Deneme süreniz bittiğinde teklif verme ve işçi iletişim bilgilerine erişim kısıtlanacaktır.',
                    style: TextStyle(color: AppTheme.gray700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(SubscriptionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium Üye',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Tüm özelliklere sınırsız erişim',
                      style: TextStyle(color: AppTheme.gray500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AKTİF',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubscriptionInfoItem(
                'Sonraki Ödeme',
                provider.endDate != null
                    ? DateFormat(
                        'dd MMM yyyy',
                        'tr_TR',
                      ).format(provider.endDate!)
                    : '-',
              ),
              _buildSubscriptionInfoItem(
                'Aylık Tutar',
                '${provider.monthlyPrice.toStringAsFixed(0)} TL',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppTheme.gray500, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildExpiredCard(SubscriptionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.small,
        border: Border.all(
          color: AppTheme.errorRed.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.errorRed,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Abonelik Süresi Doldu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Premium özelliklere erişiminiz kısıtlandı',
                      style: TextStyle(color: AppTheme.gray500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildRestrictedFeature('İş ilanlarına teklif verme'),
                const SizedBox(height: 8),
                _buildRestrictedFeature('İşçi iletişim bilgilerini görme'),
                const SizedBox(height: 8),
                _buildRestrictedFeature('Öncelikli destek'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedFeature(String feature) {
    return Row(
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          color: AppTheme.errorRed,
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            feature,
            style: TextStyle(
              color: AppTheme.gray600,
              fontSize: 13,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard() {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.orange,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Premium Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tüm özelliklere sınırsız erişim',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(
                      AppConstants.monthlySubscriptionPrice,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/aylık',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  '30 gün ücretsiz deneme ile başlayın!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.gavel_rounded,
        'title': 'Sınırsız Teklif',
        'description': 'Tüm iş ilanlarına teklif verin',
      },
      {
        'icon': Icons.contact_phone_rounded,
        'title': 'İşçi İletişim Bilgileri',
        'description': 'Usta ve çırakların iletişim bilgilerine erişin',
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Öncelikli Görünürlük',
        'description': 'Teklifleriniz öne çıksın',
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': 'Öncelikli Destek',
        'description': '7/24 müşteri desteği',
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'Detaylı İstatistikler',
        'description': 'Performansınızı takip edin',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Özellikler',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.small,
          ),
          child: Column(
            children: features.asMap().entries.map((entry) {
              final index = entry.key;
              final feature = entry.value;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: AppTheme.primaryOrange,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                feature['description'] as String,
                                style: TextStyle(
                                  color: AppTheme.gray500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.successGreen,
                        ),
                      ],
                    ),
                  ),
                  if (index < features.length - 1)
                    const Divider(height: 1, indent: 60),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(SubscriptionProvider provider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _showContactDialog(),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.diamond_rounded),
                SizedBox(width: 8),
                Text('Premium\'a Geç'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Abonelik için bizimle iletişime geçin',
          style: TextStyle(color: AppTheme.gray500, fontSize: 12),
        ),
      ],
    );
  }

  void _showContactDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      color: AppTheme.primaryOrange,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Premium Üyelik',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Premium üyelik için bizimle iletişime geçin.\nSize en kısa sürede dönüş yapacağız.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // WhatsApp butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openWhatsApp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'WhatsApp ile İletişime Geç',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Telefon butonu
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _makePhoneCall();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryOrange,
                        side: const BorderSide(
                          color: AppTheme.primaryOrange,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.phone_outlined),
                      label: const Text(
                        'Telefon ile Ara',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Daha sonra',
                      style: TextStyle(
                        color: AppTheme.gray500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openWhatsApp() {
    // TODO: url_launcher paketi ile gerçek WhatsApp açma
    // const phoneNumber = '905551234567';
    // const message = 'Merhaba, Şantiye Cepte Premium üyelik hakkında bilgi almak istiyorum.';
    // launchUrl(Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('WhatsApp: 0555 123 45 67'),
        backgroundColor: Color(0xFF25D366),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _makePhoneCall() {
    // Telefon açma - url_launcher ile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Destek Hattı: 0555 123 45 67'),
        backgroundColor: AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
