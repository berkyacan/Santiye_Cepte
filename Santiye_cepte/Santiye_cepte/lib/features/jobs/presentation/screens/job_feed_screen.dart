import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/jobs_provider.dart';
import '../../presentation/screens/job_detail_screen.dart';
import '../widgets/job_card.dart';
import '../widgets/filter_bottom_sheet.dart';

/// İş İlanları Ekranı (Job Feed)
/// Taşeronlar için müteahhit ilanlarını, ustalar için taşeron ilanlarını gösterir
class JobFeedScreen extends StatefulWidget {
  const JobFeedScreen({super.key});

  @override
  State<JobFeedScreen> createState() => _JobFeedScreenState();
}

class _JobFeedScreenState extends State<JobFeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadJobs();

    // Sonsuz kaydırma için listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadJobs() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final jobsProvider = context.read<JobsProvider>();

      // Kullanıcı rolüne göre hangi ilanları göstereceğini belirle
      // Taşeron: Müteahhitlerin ilanlarını gör
      // Usta: Taşeronların ilanlarını gör
      if (authProvider.userRole == UserRole.subcontractor) {
        jobsProvider.setPublisherRole('contractor');
      } else if (authProvider.userRole == UserRole.worker) {
        jobsProvider.setPublisherRole('subcontractor');
      } else {
        jobsProvider.setPublisherRole(null);
      }

      jobsProvider.loadJobs(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<JobsProvider>().loadJobs();
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arama ve Filtre Bar
        _buildSearchAndFilterBar(),
        // Body
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Arama
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: Arama ekranı
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: AppTheme.gray500),
                    const SizedBox(width: 8),
                    Text(
                      'İş ara...',
                      style: TextStyle(fontSize: 14, color: AppTheme.gray400),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filtre Butonu
          Consumer<JobsProvider>(
            builder: (context, provider, _) {
              final hasFilter =
                  provider.selectedTradeType != null ||
                  provider.selectedDistrict != null;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showFilterSheet();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasFilter
                        ? AppTheme.primaryOrange
                        : AppTheme.gray100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    size: 22,
                    color: hasFilter ? Colors.white : AppTheme.gray600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<JobsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.jobs.isEmpty) {
          return _buildLoadingState();
        }

        if (provider.error != null && provider.jobs.isEmpty) {
          return _buildErrorState(provider.error!);
        }

        if (provider.jobs.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadJobs(refresh: true);
          },
          color: AppTheme.primaryOrange,
          child: Column(
            children: [
              // Aktif filtreler
              if (provider.selectedTradeType != null ||
                  provider.selectedDistrict != null)
                _buildActiveFilters(provider),

              // İş listesi
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.jobs.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.jobs.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                      );
                    }

                    final job = provider.jobs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: JobCard(
                        job: job,
                        onTap: () => _navigateToJobDetail(job),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveFilters(JobsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.primaryOrange.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_rounded,
            size: 18,
            color: AppTheme.primaryOrange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                if (provider.selectedTradeType != null)
                  Chip(
                    label: Text(provider.selectedTradeType!.turkishName),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      provider.applyFilters(
                        tradeType: null,
                        district: provider.selectedDistrict,
                      );
                    },
                    backgroundColor: AppTheme.primaryOrange.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (provider.selectedDistrict != null)
                  Chip(
                    label: Text(provider.selectedDistrict!),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      provider.applyFilters(
                        tradeType: provider.selectedTradeType,
                        district: null,
                      );
                    },
                    backgroundColor: AppTheme.primaryOrange.withValues(
                      alpha: 0.2,
                    ),
                    labelStyle: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => provider.clearFilters(),
            child: const Text(
              'Temizle',
              style: TextStyle(color: AppTheme.primaryOrange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: JobCardSkeleton(),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return ErrorStateWidget(message: error, onRetry: _loadJobs);
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.work_off_outlined,
      title: 'Henüz İş İlanı Yok',
      subtitle:
          'Şu an için aktif iş ilanı bulunmuyor.\nDaha sonra tekrar kontrol edin.',
      actionLabel: 'Yenile',
      onAction: _loadJobs,
    );
  }

  void _navigateToJobDetail(Map<String, dynamic> job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(jobId: job['id']),
      ),
    );
  }
}

/// İş Kartı İskelet Yükleyici
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.gray200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.gray200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.gray200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.gray200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
