import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/jobs_provider.dart';
import '../../presentation/widgets/submit_bid_sheet.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';

/// İş Detay Ekranı
class JobDetailScreen extends StatefulWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  void _loadJobDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().loadJobDetails(widget.jobId);
    });
  }

  void _showBidSheet() {
    // Önce abonelik durumunu kontrol et
    final subscriptionProvider = context.read<SubscriptionProvider>();

    if (!subscriptionProvider.hasActiveSubscription) {
      _showSubscriptionRequiredDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubmitBidSheet(jobId: widget.jobId),
    );
  }

  void _showSubscriptionRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.warningYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppTheme.warningYellow,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Abonelik Gerekli')),
          ],
        ),
        content: const Text(
          'Teklif vermek için aktif bir aboneliğiniz olmalı. '
          '30 günlük ücretsiz deneme ile başlayabilirsiniz!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Abonelik ekranına git
            },
            child: const Text('Abonelik Al'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: Consumer<JobsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.selectedJob == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryOrange),
            );
          }

          final job = provider.selectedJob;
          if (job == null) {
            return const Center(child: Text('İş ilanı bulunamadı'));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(job),
              SliverToBoxAdapter(child: _buildContent(job)),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar(Map<String, dynamic> job) {
    final tradeType = TradeType.fromString(job['trade_type'] ?? 'diger');

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.secondaryNavy,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppTheme.darkGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meslek Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tradeType.turkishName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Başlık
                  Text(
                    job['title'] ?? 'İş İlanı',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined, color: Colors.white),
          ),
          onPressed: () {
            // TODO: Paylaşım
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(Map<String, dynamic> job) {
    final contractor = job['contractor'] as Map<String, dynamic>?;
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Müteahhit Bilgileri
          _buildContractorCard(contractor),

          const SizedBox(height: 24),

          // İş Detayları
          _buildSectionTitle('İş Detayları'),
          const SizedBox(height: 12),
          _buildInfoGrid(job, currencyFormat),

          const SizedBox(height: 24),

          // Açıklama
          _buildSectionTitle('Açıklama'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.small,
            ),
            child: Text(
              job['description'] ?? 'Açıklama eklenmemiş.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.gray700,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Konum
          if (job['district'] != null) ...[
            _buildSectionTitle('Konum'),
            const SizedBox(height: 12),
            _buildLocationCard(job),
          ],

          const SizedBox(height: 100), // Bottom bar için boşluk
        ],
      ),
    );
  }

  Widget _buildContractorCard(Map<String, dynamic>? contractor) {
    if (contractor == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                (contractor['full_name'] ?? 'M')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contractor['full_name'] ?? 'Müteahhit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (contractor['company_name'] != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    contractor['company_name'],
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.gray500),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${contractor['rating'] ?? '0.0'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // İletişim Butonu
          IconButton(
            onPressed: () {
              // TODO: İletişim
            },
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.phone_outlined,
                color: AppTheme.successGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.gray800,
      ),
    );
  }

  Widget _buildInfoGrid(Map<String, dynamic> job, NumberFormat currencyFormat) {
    final budgetMin = job['budget_min'] as num?;
    final budgetMax = job['budget_max'] as num?;
    final durationDays = job['duration_days'] as int?;
    final workersNeeded = job['workers_needed'] as int? ?? 1;
    final startDate = job['start_date'] != null
        ? DateTime.parse(job['start_date'])
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.payments_outlined,
                  iconColor: AppTheme.successGreen,
                  label: 'Bütçe',
                  value: _formatBudget(budgetMin, budgetMax, currencyFormat),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.schedule_outlined,
                  iconColor: AppTheme.infoBlue,
                  label: 'Süre',
                  value: durationDays != null
                      ? '$durationDays gün'
                      : 'Belirtilmedi',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.people_outline,
                  iconColor: AppTheme.primaryOrange,
                  label: 'Çalışan İhtiyacı',
                  value: '$workersNeeded kişi',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppTheme.warningYellow,
                  label: 'Başlangıç',
                  value: startDate != null
                      ? DateFormat('dd MMM yyyy', 'tr_TR').format(startDate)
                      : 'Esnek',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: AppTheme.gray500, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppTheme.errorRed,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${job['district']}, ${job['city'] ?? 'Antalya'}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (job['address'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    job['address'],
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.gray500),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Haritada göster
            },
            icon: const Icon(Icons.map_outlined, color: AppTheme.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;

    // Usta için: Kabul/Ret butonları
    if (userRole == UserRole.worker) {
      return _buildWorkerBottomBar();
    }

    // Taşeron için: Teklif Ver butonu
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _showBidSheet,
            icon: const Icon(Icons.gavel_rounded),
            label: const Text('Teklif Ver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Usta için Kabul/Ret butonları
  Widget _buildWorkerBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Reddet butonu
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => _rejectJob(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.errorRed,
                  ),
                  label: const Text('Reddet'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Kabul Et butonu
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _acceptJob(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Kabul Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Usta işi kabul etti
  Future<void> _acceptJob() async {
    final provider = context.read<JobsProvider>();
    final job = provider.selectedJob;
    if (job == null) return;

    // Kabul işlemi - teklif olarak kaydet
    final success = await provider.submitBid(
      jobId: widget.jobId,
      amount: (job['budget_min'] as num?)?.toDouble() ?? 0, // Yevmiye
      message: 'Teklifi kabul ediyorum',
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Talebi kabul ettiniz! Taşerona bildirim gönderildi.',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  /// Usta işi reddetti
  void _rejectJob() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İş talebi reddedildi'),
        backgroundColor: AppTheme.gray600,
      ),
    );
  }

  String _formatBudget(num? min, num? max, NumberFormat format) {
    if (min != null && max != null) {
      return '${format.format(min)} - ${format.format(max)}';
    } else if (min != null) {
      return '${format.format(min)}+';
    } else if (max != null) {
      return 'Max ${format.format(max)}';
    }
    return 'Teklif Alınıyor';
  }
}
