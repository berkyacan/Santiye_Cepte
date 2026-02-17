import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// İş Kartı Widget'ı
class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Bölüm - Başlık ve Meslek
            _buildHeader(context),
            
            // Açıklama
            _buildDescription(context),
            
            // Alt Bölüm - Bilgiler
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final tradeType = TradeType.fromString(job['trade_type'] ?? 'diger');
    final contractor = job['contractor'] as Map<String, dynamic>?;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meslek İkonu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.construction_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Başlık ve Müteahhit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'] ?? 'İş İlanı',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.gray900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 14,
                      color: AppTheme.gray400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        contractor?['company_name'] ?? 
                        contractor?['full_name'] ?? 
                        'Müteahhit',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.gray500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Meslek Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tradeType.turkishName,
              style: const TextStyle(
                color: AppTheme.primaryOrange,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        job['description'] ?? '',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.gray600,
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 0,
    );
    
    final budgetMin = job['budget_min'] as num?;
    final budgetMax = job['budget_max'] as num?;
    final district = job['district'] as String?;
    final durationDays = job['duration_days'] as int?;
    final createdAt = job['created_at'] != null 
        ? DateTime.parse(job['created_at']) 
        : null;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Konum ve Süre
          Row(
            children: [
              if (district != null) ...[
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppTheme.gray400,
                ),
                const SizedBox(width: 4),
                Text(
                  '$district, Antalya',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.gray500,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (durationDays != null) ...[
                Icon(
                  Icons.schedule_outlined,
                  size: 16,
                  color: AppTheme.gray400,
                ),
                const SizedBox(width: 4),
                Text(
                  '$durationDays gün',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.gray500,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bütçe ve Zaman
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bütçe
              if (budgetMin != null || budgetMax != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 16,
                        color: AppTheme.successGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatBudget(budgetMin, budgetMax, currencyFormat),
                        style: const TextStyle(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Zaman damgası
              if (createdAt != null)
                Text(
                  _formatTimeAgo(createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.gray400,
                  ),
                ),
            ],
          ),
        ],
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
    return 'Fiyat Teklif Alınıyor';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM', 'tr_TR').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dk önce';
    } else {
      return 'Az önce';
    }
  }
}
