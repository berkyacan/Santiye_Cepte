import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import 'contact_sheet.dart';

/// İşçi Detay Modal
/// Usta/çırak profil detaylarını gösteren tam ekran modal
class WorkerDetailSheet extends StatelessWidget {
  final Map<String, dynamic> worker;

  const WorkerDetailSheet({
    super.key,
    required this.worker,
  });

  @override
  Widget build(BuildContext context) {
    final name = worker['name'] ?? 'İsimsiz';
    final profession = worker['profession'] ?? 'Belirtilmemiş';
    final location = worker['location'] ?? 'Antalya';
    final rating = (worker['rating'] ?? 0.0) as double;
    final reviewCount = worker['reviewCount'] ?? 0;
    final experience = worker['experience'] ?? 0;
    final hourlyRate = worker['hourlyRate'] ?? 0;
    final isAvailable = worker['isAvailable'] ?? true;
    final bio = worker['bio'] ?? '';
    final skills = worker['skills'] as List<String>? ?? [];
    final completedJobs = worker['completedJobs'] ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profession,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.gray600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: AppTheme.gray500),
                                const SizedBox(width: 4),
                                Text(
                                  location,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.gray500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                                        : AppTheme.gray200,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAvailable ? 'Müsait' : 'Meşgul',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isAvailable ? AppTheme.successGreen : AppTheme.gray600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stats Row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.gray50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          icon: Icons.star,
                          iconColor: Colors.amber,
                          value: rating.toStringAsFixed(1),
                          label: '$reviewCount Değerlendirme',
                        ),
                        Container(width: 1, height: 40, color: AppTheme.gray300),
                        _buildStat(
                          icon: Icons.work_history,
                          iconColor: AppTheme.primaryOrange,
                          value: '$experience',
                          label: 'Yıl Deneyim',
                        ),
                        Container(width: 1, height: 40, color: AppTheme.gray300),
                        _buildStat(
                          icon: Icons.check_circle,
                          iconColor: AppTheme.successGreen,
                          value: '$completedJobs',
                          label: 'İş Tamamlandı',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hourly Rate
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saatlik Ücret',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Pazarlık yapılabilir',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₺$hourlyRate/saat',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bio
                  if (bio.isNotEmpty) ...[
                    const Text(
                      'Hakkında',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bio,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Skills
                  if (skills.isNotEmpty) ...[
                    const Text(
                      'Uzmanlık Alanları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skills.map((skill) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reviews Preview
                  const Text(
                    'Son Değerlendirmeler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildReviewCard(
                    name: 'Ahmet B.',
                    rating: 5,
                    comment: 'Çok profesyonel ve işini bilen bir usta. Kesinlikle tavsiye ederim.',
                    date: '2 hafta önce',
                  ),
                  _buildReviewCard(
                    name: 'Mehmet K.',
                    rating: 4,
                    comment: 'İşini zamanında ve kaliteli yaptı.',
                    date: '1 ay önce',
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showContactSheet(
                          context,
                          workerName: name,
                          phone: worker['phone'],
                          email: worker['email'],
                          isPremium: true, // TODO: Check actual premium status
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('İletişime Geç'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.primaryOrange),
                        foregroundColor: AppTheme.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // TODO: Send job invitation
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Davet gönderildi'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('İş Teklif Et'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String comment,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.gray300,
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppTheme.gray700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.gray900,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        )),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.gray600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// İşçi detay modalını göster
void showWorkerDetailSheet(BuildContext context, Map<String, dynamic> worker) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => WorkerDetailSheet(worker: worker),
    ),
  );
}
