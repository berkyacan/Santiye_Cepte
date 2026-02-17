import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Taşeron Bul Ekranı
/// Müteahhitler ve ustalar için taşeron arama
class SubcontractorsScreen extends StatefulWidget {
  const SubcontractorsScreen({super.key});

  @override
  State<SubcontractorsScreen> createState() => _SubcontractorsScreenState();
}

class _SubcontractorsScreenState extends State<SubcontractorsScreen> {
  String? _selectedTrade;
  String? _selectedDistrict;
  bool _isLoading = true;
  List<Map<String, dynamic>> _subcontractors = [];

  @override
  void initState() {
    super.initState();
    _loadSubcontractors();
  }

  Future<void> _loadSubcontractors() async {
    setState(() => _isLoading = true);

    // TODO: Supabase'den taşeron verilerini çek
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _subcontractors = []; // Gerçek veriler Supabase'den gelecek
      _isLoading = false;
    });
  }

  String _getTradeName(String trade) {
    return AppConstants.tradeTypes[trade] ?? trade;
  }

  IconData _getTradeIcon(String trade) {
    switch (trade) {
      case 'electrician':
        return Icons.electrical_services;
      case 'plumber':
        return Icons.plumbing;
      case 'welder':
        return Icons.construction;
      case 'painter':
        return Icons.format_paint;
      case 'carpenter':
        return Icons.carpenter;
      case 'mason':
        return Icons.home_work;
      case 'tiler':
        return Icons.grid_on;
      case 'hvac':
        return Icons.ac_unit;
      case 'roofer':
        return Icons.roofing;
      case 'landscaper':
        return Icons.grass;
      default:
        return Icons.engineering;
    }
  }

  List<Map<String, dynamic>> get _filteredSubcontractors {
    return _subcontractors.where((sub) {
      if (_selectedTrade != null && sub['trade'] != _selectedTrade) {
        return false;
      }
      if (_selectedDistrict != null && sub['district'] != _selectedDistrict) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Arama ve Filtre
        _buildSearchAndFilter(),

        // Taşeron Listesi
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _filteredSubcontractors.isEmpty
              ? _buildEmptyState()
              : _buildSubcontractorsList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          // Arama Çubuğu
          TextField(
            decoration: InputDecoration(
              hintText: 'Taşeron veya firma ara...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppTheme.gray100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filtre Butonları
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: _selectedTrade != null
                      ? _getTradeName(_selectedTrade!)
                      : 'Uzmanlık Alanı',
                  icon: Icons.work_outline,
                  isSelected: _selectedTrade != null,
                  onTap: () => _showTradeFilter(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterChip(
                  label: _selectedDistrict ?? 'İlçe Seç',
                  icon: Icons.location_on_outlined,
                  isSelected: _selectedDistrict != null,
                  onTap: () => _showDistrictFilter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryOrange.withValues(alpha: 0.1)
              : AppTheme.gray100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.gray600,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppTheme.primaryOrange : AppTheme.gray700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (icon == Icons.work_outline) {
                      _selectedTrade = null;
                    } else {
                      _selectedDistrict = null;
                    }
                  });
                },
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryOrange),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(
              Icons.engineering,
              size: 40,
              color: AppTheme.gray400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Taşeron Bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Arama kriterlerinize uygun taşeron yok',
            style: TextStyle(fontSize: 14, color: AppTheme.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcontractorsList() {
    return RefreshIndicator(
      color: AppTheme.primaryOrange,
      onRefresh: _loadSubcontractors,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSubcontractors.length,
        itemBuilder: (context, index) {
          return _SubcontractorCard(
            subcontractor: _filteredSubcontractors[index],
            getTradeIcon: _getTradeIcon,
            getTradeName: _getTradeName,
            onTap: () =>
                _showSubcontractorDetail(_filteredSubcontractors[index]),
          );
        },
      ),
    );
  }

  void _showTradeFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        title: 'Uzmanlık Alanı Seç',
        options: AppConstants.tradeTypes.entries.toList(),
        selectedValue: _selectedTrade,
        onSelect: (value) {
          setState(() => _selectedTrade = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDistrictFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        title: 'İlçe Seç',
        options: AppConstants.antalyaDistricts
            .map((d) => MapEntry(d, d))
            .toList(),
        selectedValue: _selectedDistrict,
        onSelect: (value) {
          setState(() => _selectedDistrict = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSubcontractorDetail(Map<String, dynamic> subcontractor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubcontractorDetailSheet(
        subcontractor: subcontractor,
        getTradeIcon: _getTradeIcon,
        getTradeName: _getTradeName,
      ),
    );
  }
}

/// Taşeron Kartı
class _SubcontractorCard extends StatelessWidget {
  final Map<String, dynamic> subcontractor;
  final IconData Function(String) getTradeIcon;
  final String Function(String) getTradeName;
  final VoidCallback onTap;

  const _SubcontractorCard({
    required this.subcontractor,
    required this.getTradeIcon,
    required this.getTradeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = subcontractor['is_available'] as bool? ?? true;

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
            // Üst Kısım - Avatar ve Bilgiler
            Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    getTradeIcon(subcontractor['trade'] ?? 'diger'),
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subcontractor['company_name'] ??
                                  subcontractor['name'] ??
                                  'Taşeron',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                                  : AppTheme.gray200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAvailable ? 'Müsait' : 'Meşgul',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isAvailable
                                    ? AppTheme.successGreen
                                    : AppTheme.gray500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        getTradeName(subcontractor['trade'] ?? 'diger'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.gray400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${subcontractor['district'] ?? 'Antalya'}, Antalya',
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
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Alt Kısım - Puan, Deneyim, Tamamlanan İş
            Row(
              children: [
                // Puan
                _buildInfoChip(
                  icon: Icons.star,
                  iconColor: Colors.amber,
                  text:
                      '${subcontractor['rating'] ?? 0} (${subcontractor['total_reviews'] ?? 0})',
                ),

                const SizedBox(width: 16),

                // Deneyim
                _buildInfoChip(
                  icon: Icons.work_history,
                  iconColor: AppTheme.gray500,
                  text: '${subcontractor['experience_years'] ?? 0} Yıl',
                ),

                const Spacer(),

                // Tamamlanan İş
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${subcontractor['completed_jobs'] ?? 0} İş',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.gray600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Filtre Sheet
class _FilterSheet extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> options;
  final String? selectedValue;
  final Function(String) onSelect;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
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

          const SizedBox(height: 16),

          // Başlık
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray900,
            ),
          ),

          const SizedBox(height: 16),

          // Seçenekler
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option.key == selectedValue;

                return ListTile(
                  title: Text(
                    option.value,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.primaryOrange
                          : AppTheme.gray700,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppTheme.primaryOrange)
                      : null,
                  onTap: () => onSelect(option.key),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Taşeron Detay Sheet
class _SubcontractorDetailSheet extends StatelessWidget {
  final Map<String, dynamic> subcontractor;
  final IconData Function(String) getTradeIcon;
  final String Function(String) getTradeName;

  const _SubcontractorDetailSheet({
    required this.subcontractor,
    required this.getTradeIcon,
    required this.getTradeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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

          // Avatar ve İsim
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              getTradeIcon(subcontractor['trade'] ?? 'diger'),
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            subcontractor['company_name'] ?? subcontractor['name'] ?? 'Taşeron',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.gray900,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            getTradeName(subcontractor['trade'] ?? 'diger'),
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // İstatistikler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.star,
                iconColor: Colors.amber,
                value: '${subcontractor['rating'] ?? 0}',
                label: '${subcontractor['total_reviews'] ?? 0} Değerlendirme',
              ),
              _buildStatItem(
                icon: Icons.work_history,
                iconColor: AppTheme.gray500,
                value: '${subcontractor['experience_years'] ?? 0}',
                label: 'Yıl Deneyim',
              ),
              _buildStatItem(
                icon: Icons.check_circle,
                iconColor: AppTheme.successGreen,
                value: '${subcontractor['completed_jobs'] ?? 0}',
                label: 'Tamamlanan İş',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // İletişim Butonları
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Mesaj gönder
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Mesaj'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: İş teklifi gönder
                  },
                  icon: const Icon(Icons.work),
                  label: const Text('İş Teklif Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
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
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.gray500),
        ),
      ],
    );
  }
}
