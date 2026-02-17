import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';
import '../../../jobs/presentation/screens/create_job_screen.dart';
import '../../../jobs/presentation/screens/job_detail_screen.dart';

/// İş İlanlarım Ekranı
/// Müteahhitler için iş ilanları, Taşeronlar için usta arama ilanları
class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sadece ilk kez yükle
    if (_isFirstLoad) {
      _isFirstLoad = false;
      Future.microtask(() {
        if (mounted) {
          _loadJobs();
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    if (!mounted) return;
    final provider = context.read<JobsProvider>();
    await provider.loadMyJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryOrange,
              unselectedLabelColor: AppTheme.gray500,
              indicatorColor: AppTheme.primaryOrange,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Aktif'),
                Tab(text: 'Devam Eden'),
                Tab(text: 'Tamamlanan'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: Consumer<JobsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryOrange,
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildJobsList(
                      provider.myJobs
                          .where((j) => j['status'] == 'active')
                          .toList(),
                    ),
                    _buildJobsList(
                      provider.myJobs
                          .where((j) => j['status'] == 'in_progress')
                          .toList(),
                    ),
                    _buildJobsList(
                      provider.myJobs
                          .where((j) => j['status'] == 'completed')
                          .toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 8),
        child: FloatingActionButton.extended(
          onPressed: () => _createNewJob(),
          backgroundColor: AppTheme.primaryOrange,
          foregroundColor: Colors.white,
          elevation: 8,
          highlightElevation: 12,
          icon: const Icon(Icons.add_circle_outline, size: 24),
          label: const Text(
            'Yeni İlan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildJobsList(List<Map<String, dynamic>> jobs) {
    if (jobs.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppTheme.primaryOrange,
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          return _MyJobCard(
            job: jobs[index],
            onTap: () => _showJobDetail(jobs[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final authProvider = context.read<AuthProvider>();
    final isSubcontractor = authProvider.userRole == UserRole.subcontractor;

    final emptyTitle = isSubcontractor
        ? 'Henüz Usta Arama İlanı Yok'
        : 'Henüz İş İlanı Yok';
    final emptySubtitle = isSubcontractor
        ? 'İlk usta arama ilanınızı oluşturarak\nusta bulmaya başlayın'
        : 'İlk iş ilanınızı oluşturarak\ntaşeron aramaya başlayın';
    final buttonText = isSubcontractor
        ? 'Usta Arama İlanı Oluştur'
        : 'İlk İlanınızı Oluşturun';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasyonlu ikon
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
                      AppTheme.primaryOrange.withValues(alpha: 0.15),
                      AppTheme.primaryOrange.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isSubcontractor
                      ? Icons.person_search_rounded
                      : Icons.post_add_rounded,
                  size: 56,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              emptyTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              emptySubtitle,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.gray500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // CTA Butonu
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _createNewJob(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: AppTheme.primaryOrange.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 24),
                label: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewJob() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateJobScreen()));
  }

  void _showJobDetail(Map<String, dynamic> job) {
    final jobId = job['id'] as String?;
    if (jobId == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => JobDetailScreen(jobId: jobId)),
    );
  }
}

/// Benim İş İlanı Kartım
class _MyJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const _MyJobCard({required this.job, required this.onTap});

  Color _getStatusColor() {
    switch (job['status']) {
      case 'active':
        return AppTheme.successGreen;
      case 'in_progress':
        return AppTheme.primaryOrange;
      case 'completed':
        return AppTheme.gray500;
      default:
        return AppTheme.gray400;
    }
  }

  String _getStatusText() {
    switch (job['status']) {
      case 'active':
        return 'Aktif';
      case 'in_progress':
        return 'Devam Ediyor';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return job['status'] ?? '';
    }
  }

  String _getTradeName(String? trade) {
    if (trade == null) return 'Genel';
    return AppConstants.tradeTypes[trade] ?? trade;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final bidCount = job['bid_count'] ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Satır - Başlık ve Durum
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['title'] ?? 'İsimsiz İlan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTradeName(job['trade_type']),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.w500,
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
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Konum
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppTheme.gray400,
                ),
                const SizedBox(width: 4),
                Text(
                  '${job['district'] ?? 'Antalya'}, Antalya',
                  style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Alt Satır - Bütçe ve Teklif Sayısı
            Row(
              children: [
                // Bütçe
                if (job['budget_min'] != null || job['budget_max'] != null)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments,
                          size: 16,
                          color: AppTheme.gray500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatBudget(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Teklif Sayısı
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bidCount > 0
                        ? AppTheme.primaryOrange.withValues(alpha: 0.1)
                        : AppTheme.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 14,
                        color: bidCount > 0
                            ? AppTheme.primaryOrange
                            : AppTheme.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$bidCount Teklif',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: bidCount > 0
                              ? AppTheme.primaryOrange
                              : AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatBudget() {
    final min = job['budget_min'] as num?;
    final max = job['budget_max'] as num?;

    String formatNumber(num n) {
      return '₺${n.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
    }

    if (min != null && max != null) {
      return '${formatNumber(min)} - ${formatNumber(max)}';
    } else if (min != null) {
      return '${formatNumber(min)}+';
    } else if (max != null) {
      return 'Max ${formatNumber(max)}';
    }
    return 'Bütçe Belirtilmedi';
  }
}
