import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/jobs_provider.dart';

/// Filtre Alt Sayfası
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  TradeType? _selectedTradeType;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    final provider = context.read<JobsProvider>();
    _selectedTradeType = provider.selectedTradeType;
    _selectedDistrict = provider.selectedDistrict;
  }

  void _applyFilters() {
    context.read<JobsProvider>().applyFilters(
      tradeType: _selectedTradeType,
      district: _selectedDistrict,
    );
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedTradeType = null;
      _selectedDistrict = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          
          // Başlık
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrele',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Temizle'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Filtre İçeriği
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meslek/Uzmanlık Alanı
                  _buildSectionTitle('Meslek / Uzmanlık Alanı'),
                  const SizedBox(height: 12),
                  _buildTradeTypeGrid(),
                  
                  const SizedBox(height: 24),
                  
                  // İlçe
                  _buildSectionTitle('İlçe'),
                  const SizedBox(height: 12),
                  _buildDistrictDropdown(),
                ],
              ),
            ),
          ),
          
          // Uygula Butonu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Filtreleri Uygula'),
                ),
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
        fontWeight: FontWeight.w600,
        color: AppTheme.gray700,
      ),
    );
  }

  Widget _buildTradeTypeGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TradeType.values.map((tradeType) {
        final isSelected = _selectedTradeType == tradeType;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTradeType = isSelected ? null : tradeType;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryOrange 
                  : AppTheme.gray100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryOrange 
                    : AppTheme.gray200,
              ),
            ),
            child: Text(
              tradeType.turkishName,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.gray700,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDistrictDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDistrict,
          isExpanded: true,
          hint: const Text('İlçe Seçin'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Tümü'),
            ),
            ...AntalyaDistricts.all.map((district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(district),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedDistrict = value;
            });
          },
        ),
      ),
    );
  }
}
