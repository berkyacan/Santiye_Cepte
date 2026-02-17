import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Profil Düzenleme Ekranı
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _bioController;
  late TextEditingController _experienceController;
  
  String? _selectedDistrict;
  List<TradeType> _selectedTradeTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().currentProfile;
    
    _nameController = TextEditingController(text: profile?['full_name'] ?? '');
    _phoneController = TextEditingController(text: profile?['phone'] ?? '');
    _companyController = TextEditingController(text: profile?['company_name'] ?? '');
    _bioController = TextEditingController(text: profile?['bio'] ?? '');
    _experienceController = TextEditingController(
      text: profile?['experience_years']?.toString() ?? '',
    );
    _selectedDistrict = profile?['district'];
    
    // Load trade types if exists
    if (profile?['trade_types'] != null) {
      final trades = profile!['trade_types'] as List<dynamic>?;
      if (trades != null) {
        _selectedTradeTypes = trades
            .map((t) => TradeType.fromString(t.toString()))
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      district: _selectedDistrict,
      companyName: _companyController.text.trim().isNotEmpty 
          ? _companyController.text.trim() 
          : null,
      bio: _bioController.text.trim().isNotEmpty 
          ? _bioController.text.trim() 
          : null,
      experienceYears: _experienceController.text.isNotEmpty 
          ? int.tryParse(_experienceController.text) 
          : null,
      tradeTypes: _selectedTradeTypes.isNotEmpty ? _selectedTradeTypes : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Profil güncellenemedi'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userRole = authProvider.userRole;

    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
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
                    'Kaydet',
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
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Photo picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fotoğraf seçici yakında eklenecek'),
                            backgroundColor: AppTheme.primaryOrange,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Kişisel Bilgiler
            _buildSectionTitle('Kişisel Bilgiler'),
            const SizedBox(height: 12),
            _buildCard([
              _buildTextField(
                controller: _nameController,
                label: 'Ad Soyad',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ad soyad gereklidir';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'İlçe',
                icon: Icons.location_on_outlined,
                value: _selectedDistrict,
                hint: 'İlçe seçin',
                onTap: () => _showDistrictSelector(),
              ),
            ]),

            const SizedBox(height: 24),

            // İş Bilgileri (Rol'e göre)
            if (userRole == UserRole.contractor || userRole == UserRole.subcontractor) ...[
              _buildSectionTitle('İş Bilgileri'),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField(
                  controller: _companyController,
                  label: 'Şirket / Marka Adı',
                  icon: Icons.business,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bioController,
                  label: 'Hakkımda',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
              ]),
              const SizedBox(height: 24),
            ],

            // Uzmanlık Alanları (Worker/Subcontractor için)
            if (userRole == UserRole.worker || userRole == UserRole.subcontractor) ...[
              _buildSectionTitle('Uzmanlık Alanları'),
              const SizedBox(height: 12),
              _buildCard([
                _buildTextField(
                  controller: _experienceController,
                  label: 'Deneyim (Yıl)',
                  icon: Icons.work_history,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTradeTypesSelector(),
              ]),
              const SizedBox(height: 24),
            ],

            // Kaydet Butonu
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProfile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet'),
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
                    style: const TextStyle(fontSize: 12, color: AppTheme.gray500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? AppTheme.gray900 : AppTheme.gray400,
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

  Widget _buildTradeTypesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uzmanlık Alanlarınız',
          style: TextStyle(fontSize: 14, color: AppTheme.gray600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TradeType.values.map((trade) {
            final isSelected = _selectedTradeTypes.contains(trade);
            return FilterChip(
              label: Text(trade.turkishName),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.lightImpact();
                setState(() {
                  if (selected) {
                    _selectedTradeTypes.add(trade);
                  } else {
                    _selectedTradeTypes.remove(trade);
                  }
                });
              },
              selectedColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryOrange,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryOrange : AppTheme.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
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
                    leading: const Icon(Icons.location_on, color: AppTheme.gray500),
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
