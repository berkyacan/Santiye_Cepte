import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/supabase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// İş İlanı Oluşturma Ekranı
/// Müteahhitler bütçe bazlı, Taşeronlar yevmiye bazlı ilan oluşturur
class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  final _durationController = TextEditingController();
  final _addressController = TextEditingController();
  final _dailyRateController = TextEditingController(); // Taşeron için yevmiye

  TradeType? _selectedTradeType;
  String? _selectedDistrict;
  bool _isLoading = false;
  bool _isUrgent = false;

  // Kullanıcı rolü - taşeron mu müteahhit mi?
  bool get _isSubcontractor =>
      context.read<AuthProvider>().userRole == UserRole.subcontractor;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    _durationController.dispose();
    _addressController.dispose();
    _dailyRateController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    // Meslek türü ve ilçe kontrolü
    if (_selectedTradeType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir meslek türü seçin'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir ilçe seçin'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isSubcontractor = _isSubcontractor;

      // Parse values based on role
      double? budgetMin;
      double? budgetMax;
      double? dailyRate;

      if (isSubcontractor) {
        // Taşeron: Yevmiye (günlük ücret) kullan
        dailyRate = double.tryParse(
          _dailyRateController.text.replaceAll(',', '').replaceAll('.', ''),
        );
        // Yevmiyeyi bütçe olarak kaydet (tek değer)
        budgetMin = dailyRate;
        budgetMax = dailyRate;
      } else {
        // Müteahhit: Bütçe aralığı kullan
        budgetMin = double.tryParse(
          _budgetMinController.text.replaceAll(',', '').replaceAll('.', ''),
        );
        budgetMax = double.tryParse(
          _budgetMaxController.text.replaceAll(',', '').replaceAll('.', ''),
        );

        // Bütçe kontrolü
        if (budgetMin != null && budgetMax != null && budgetMin > budgetMax) {
          throw Exception('Minimum bütçe, maksimum bütçeden büyük olamaz');
        }
      }

      final durationDays = int.tryParse(_durationController.text);

      // İş ilanı oluştur
      await SupabaseService.createJob(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tradeType: _selectedTradeType!.value,
        district: _selectedDistrict!,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        durationDays: durationDays,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        final successMessage = isSubcontractor
            ? 'Usta arama ilanınız yayınlandı! Ustalar artık bu ilanı görebilir.'
            : 'İş ilanınız yayınlandı! Taşeronlar artık bu ilanı görebilir ve teklif verebilir.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Yeni İş İlanı'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitJob,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Yayınla',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // İlan Başlığı
            _buildSectionTitle('İlan Bilgileri'),
            const SizedBox(height: 12),
            _buildCard([
              _buildTextField(
                controller: _titleController,
                label: 'İlan Başlığı',
                hint: 'Örn: 300m² Tabliye Soğuk Demir İşi',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'İlan başlığı gereklidir';
                  }
                  if (value.length < 10) {
                    return 'Başlık en az 10 karakter olmalıdır';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: 'Açıklama',
                hint:
                    '300 metrekare tabliye için soğuk demir işi yapılacak. İşin detaylarını buraya yazın...',
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama gereklidir';
                  }
                  if (value.length < 30) {
                    return 'Açıklama en az 30 karakter olmalıdır';
                  }
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Meslek ve Konum
            _buildSectionTitle('Meslek & Konum'),
            const SizedBox(height: 12),
            _buildCard([
              _buildDropdownField(
                label: 'Meslek Türü',
                icon: Icons.work,
                value: _selectedTradeType?.turkishName,
                hint: 'Meslek seçin (örn: Soğuk Demirci)',
                onTap: () => _showTradeTypeSelector(),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'İlçe',
                icon: Icons.location_on,
                value: _selectedDistrict,
                hint: 'İlçe seçin',
                onTap: () => _showDistrictSelector(),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Adres (Opsiyonel)',
                hint: 'Detaylı adres bilgisi',
                icon: Icons.home,
              ),
            ]),

            const SizedBox(height: 24),

            // Ücret ve Süre - Rol bazlı
            _buildSectionTitle(
              _isSubcontractor ? 'Yevmiye & Süre' : 'Bütçe & Süre',
            ),
            const SizedBox(height: 12),
            _buildCard([
              // Taşeron: Tek yevmiye alanı
              if (_isSubcontractor) ...[
                _buildTextField(
                  controller: _dailyRateController,
                  label: 'Günlük Yevmiye (₺)',
                  hint: '1500',
                  icon: Icons.payments,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Yevmiye gereklidir';
                    }
                    return null;
                  },
                ),
              ] else ...[
                // Müteahhit: Bütçe aralığı
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _budgetMinController,
                        label: 'Min Bütçe (₺)',
                        hint: '10000',
                        icon: Icons.payments,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gerekli';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _budgetMaxController,
                        label: 'Max Bütçe (₺)',
                        hint: '50000',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gerekli';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _buildTextField(
                controller: _durationController,
                label: 'Tahmini Süre (Gün)',
                hint: '30',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Süre gereklidir';
                  }
                  return null;
                },
              ),
            ]),

            const SizedBox(height: 24),

            // Acil İş
            _buildCard([
              SwitchListTile(
                title: const Text(
                  'Acil İş',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Acil işler listede öne çıkar',
                  style: TextStyle(fontSize: 12, color: AppTheme.gray500),
                ),
                value: _isUrgent,
                onChanged: (value) => setState(() => _isUrgent = value),
                activeColor: AppTheme.primaryOrange,
                secondary: Icon(
                  Icons.priority_high,
                  color: _isUrgent ? AppTheme.primaryOrange : AppTheme.gray400,
                ),
              ),
            ]),

            const SizedBox(height: 32),

            // Bilgilendirme
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'İlanınız yayınlandıktan sonra, seçtiğiniz meslek grubundaki taşeronlar bunu görebilir ve teklif verebilir.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Yayınla Butonu
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitJob,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.publish),
                label: Text(_isLoading ? 'Yayınlanıyor...' : 'İlanı Yayınla'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.gray700,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.gray500),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.errorRed),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required String hint,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.gray50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.gray500),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null
                          ? AppTheme.gray900
                          : AppTheme.gray400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppTheme.gray500),
          ],
        ),
      ),
    );
  }

  void _showTradeTypeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
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
            const SizedBox(height: 16),
            const Text(
              'Meslek Seçin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: TradeType.values.length,
                itemBuilder: (context, index) {
                  final trade = TradeType.values[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.work,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    title: Text(trade.turkishName),
                    trailing: _selectedTradeType == trade
                        ? const Icon(Icons.check, color: AppTheme.primaryOrange)
                        : null,
                    onTap: () {
                      setState(() => _selectedTradeType = trade);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistrictSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
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
            const SizedBox(height: 16),
            const Text(
              'İlçe Seçin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: AppConstants.antalyaDistricts.length,
                itemBuilder: (context, index) {
                  final district = AppConstants.antalyaDistricts[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: AppTheme.gray500,
                    ),
                    title: Text(district),
                    trailing: _selectedDistrict == district
                        ? const Icon(Icons.check, color: AppTheme.primaryOrange)
                        : null,
                    onTap: () {
                      setState(() => _selectedDistrict = district);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
