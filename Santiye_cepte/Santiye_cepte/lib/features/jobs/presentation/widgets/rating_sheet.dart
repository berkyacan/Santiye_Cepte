import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Değerlendirme Modal
/// Kullanıcının iş tamamlandıktan sonra puan ve yorum vermesi için
class RatingSheet extends StatefulWidget {
  final String workerName;
  final String jobTitle;
  final String? workerId;
  final String? jobId;

  const RatingSheet({
    super.key,
    required this.workerName,
    required this.jobTitle,
    this.workerId,
    this.jobId,
  });

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  // Değerlendirme kriterleri
  final Map<String, int> _criteriaRatings = {
    'quality': 0,      // İş kalitesi
    'timing': 0,       // Zamanında teslim
    'communication': 0, // İletişim
    'professionalism': 0, // Profesyonellik
  };

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen genel bir puan verin'),
          backgroundColor: AppTheme.warningYellow,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Submit to Supabase
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context, true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Değerlendirmeniz için teşekkürler!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.star_rate,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Değerlendirme',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.workerName,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'İş: ${widget.jobTitle}',
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.gray500,
              ),
            ),

            const SizedBox(height: 32),

            // Overall Rating
            const Text(
              'Genel Puan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _rating = index + 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 48,
                      color: Colors.amber,
                    ),
                  ),
                );
              }),
            ),
            Center(
              child: Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontSize: 14,
                  color: _rating > 0 ? AppTheme.primaryOrange : AppTheme.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Detailed Ratings
            const Text(
              'Detaylı Değerlendirme (Opsiyonel)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 16),
            _buildCriteriaRow('İş Kalitesi', 'quality', Icons.verified),
            _buildCriteriaRow('Zamanında Teslim', 'timing', Icons.schedule),
            _buildCriteriaRow('İletişim', 'communication', Icons.chat),
            _buildCriteriaRow('Profesyonellik', 'professionalism', Icons.workspace_premium),

            const SizedBox(height: 24),

            // Comment
            const Text(
              'Yorum (Opsiyonel)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deneyiminizi paylaşın...',
                filled: true,
                fillColor: AppTheme.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitRating,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Gönderiliyor...' : 'Değerlendirmeyi Gönder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaRow(String label, String key, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.gray500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _criteriaRatings[key] = index + 1);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    index < (_criteriaRatings[key] ?? 0)
                        ? Icons.star
                        : Icons.star_border,
                    size: 24,
                    color: Colors.amber,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Çok Kötü 😞';
      case 2:
        return 'Kötü 😕';
      case 3:
        return 'Orta 😐';
      case 4:
        return 'İyi 😊';
      case 5:
        return 'Mükemmel 🤩';
      default:
        return 'Puan seçin';
    }
  }
}

/// Değerlendirme sheet'ini göster
void showRatingSheet(
  BuildContext context, {
  required String workerName,
  required String jobTitle,
  String? workerId,
  String? jobId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RatingSheet(
      workerName: workerName,
      jobTitle: jobTitle,
      workerId: workerId,
      jobId: jobId,
    ),
  );
}
