import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Tekliflerim Ekranı
/// Taşeronların verdiği ve müteahhitlerin aldığı teklifleri gösterir
class BidsScreen extends StatefulWidget {
  const BidsScreen({super.key});

  @override
  State<BidsScreen> createState() => _BidsScreenState();
}

class _BidsScreenState extends State<BidsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _sentBids = [];
  List<Map<String, dynamic>> _receivedBids = [];

  @override
  void initState() {
    super.initState();
    _loadBids();
  }

  Future<void> _loadBids() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userRole = authProvider.userRole;

      if (userRole == UserRole.contractor) {
        // Müteahhit: Gelen teklifleri getir
        final receivedBids = await SupabaseService.getReceivedBids();
        setState(() {
          _receivedBids = receivedBids;
          _sentBids = [];
          _isLoading = false;
        });
      } else {
        // Taşeron/Usta: Verilen teklifleri getir
        final myBids = await SupabaseService.getMyBids();
        setState(() {
          _sentBids = myBids;
          _receivedBids = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Teklifler yüklenirken hata: $e');
      setState(() {
        _sentBids = [];
        _receivedBids = [];
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(int amount) {
    return '₺${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} dakika önce';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} saat önce';
    } else {
      return '${diff.inDays} gün önce';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningYellow;
      case 'accepted':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.gray500;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'accepted':
        return 'Kabul Edildi';
      case 'rejected':
        return 'Reddedildi';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;
    final isContractor = userRole == UserRole.contractor;

    // Tek liste göster - rollere göre farklı içerik
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryOrange),
          )
        : _buildBidsList(
            isContractor ? _receivedBids : _sentBids,
            !isContractor, // taşeron için isSent=true
          );
  }

  Widget _buildBidsList(List<Map<String, dynamic>> bids, bool isSent) {
    if (bids.isEmpty) {
      return _buildEmptyState(isSent);
    }

    return RefreshIndicator(
      color: AppTheme.primaryOrange,
      onRefresh: _loadBids,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bids.length,
        itemBuilder: (context, index) {
          return _BidCard(
            bid: bids[index],
            isSent: isSent,
            formatCurrency: _formatCurrency,
            formatTimeAgo: _formatTimeAgo,
            getStatusColor: _getStatusColor,
            getStatusText: _getStatusText,
            getStatusIcon: _getStatusIcon,
            onAccept: isSent ? null : () => _handleAccept(bids[index]),
            onReject: isSent ? null : () => _handleReject(bids[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isSent) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.gray200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSent ? Icons.send_outlined : Icons.inbox_outlined,
              size: 40,
              color: AppTheme.gray400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isSent ? 'Henüz Teklif Vermediniz' : 'Henüz Teklif Almadınız',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSent
                ? 'İş ilanlarına göz atın ve teklif verin'
                : 'İlan yayınladığınızda teklifler burada görünür',
            style: const TextStyle(fontSize: 14, color: AppTheme.gray500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleAccept(Map<String, dynamic> bid) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Teklifi Kabul Et'),
        content: Text(
          '${bid['subcontractor_name']} tarafından verilen ${_formatCurrency(bid['bid_amount'])} tutarındaki teklifi kabul etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Teklif kabul edildi'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
              _loadBids();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
            ),
            child: const Text('Kabul Et'),
          ),
        ],
      ),
    );
  }

  void _handleReject(Map<String, dynamic> bid) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Teklifi Reddet'),
        content: Text(
          '${bid['subcontractor_name']} tarafından verilen teklifi reddetmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Teklif reddedildi'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
              _loadBids();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
  }
}

/// Teklif Kartı
class _BidCard extends StatelessWidget {
  final Map<String, dynamic> bid;
  final bool isSent;
  final String Function(int) formatCurrency;
  final String Function(DateTime) formatTimeAgo;
  final Color Function(String) getStatusColor;
  final String Function(String) getStatusText;
  final IconData Function(String) getStatusIcon;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _BidCard({
    required this.bid,
    required this.isSent,
    required this.formatCurrency,
    required this.formatTimeAgo,
    required this.getStatusColor,
    required this.getStatusText,
    required this.getStatusIcon,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final status = (bid['status'] as String?) ?? 'pending';
    final statusColor = getStatusColor(status);

    // Supabase'den gelen nested veriler
    final job = bid['job'] as Map<String, dynamic>?;
    final subcontractor = bid['subcontractor'] as Map<String, dynamic>?;

    // İş başlığı
    final jobTitle = job?['title'] ?? 'İş İlanı';

    // Kişi adı: Taşeron için müteahhit, Müteahhit için taşeron
    final personName = isSent
        ? (job?['contractor']?['full_name'] ??
              job?['contractor']?['company_name'] ??
              'Müteahhit')
        : (subcontractor?['full_name'] ??
              subcontractor?['company_name'] ??
              'Taşeron');

    // Teklif tutarı
    final amount = (bid['amount'] as num?)?.toInt() ?? 0;

    // Süre
    final duration =
        bid['proposed_duration_days'] ?? job?['duration_days'] ?? 0;

    // Tarih
    final createdAtStr = bid['created_at'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
        : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Ana İçerik
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Üst Satır - İş Başlığı ve Durum
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            personName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getStatusIcon(status),
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getStatusText(status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Orta Satır - Tutar ve Süre
                Row(
                  children: [
                    // Teklif Tutarı
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Teklif Tutarı',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.gray500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(amount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Tahmini Süre
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.gray100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tahmini Süre',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.gray500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$duration Gün',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gray800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Rating (Alınan tekliflerde - taşeronun puanı)
                if (!isSent && subcontractor?['rating'] != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${subcontractor!['rating']} puan',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Zaman
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatTimeAgo(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Aksiyon Butonları (Alınan teklifler ve pending durumunda)
          if (!isSent && status == 'pending') ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(color: AppTheme.errorRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Reddet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Kabul Et'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
