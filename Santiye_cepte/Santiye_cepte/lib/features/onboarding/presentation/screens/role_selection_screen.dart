import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/screens/register_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/// Rol Seçimi Ekranı
/// Kullanıcıların Müteahhit, Taşeron veya Usta/Çırak olarak kayıt olmasını sağlar
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserRole? _selectedRole;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedRole = role;
    });
  }

  void _continueToRegister() {
    if (_selectedRole == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterScreen(selectedRole: _selectedRole!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryNavy,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Logo ve Başlık
                _buildHeader(),

                const SizedBox(height: 40),

                // Rol Kartları
                Expanded(child: _buildRoleCards()),

                const SizedBox(height: 24),

                // Devam Et Butonu
                _buildContinueButton(),

                const SizedBox(height: 16),

                // Giriş Yap Linki
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.orange,
          ),
          child: const Icon(
            Icons.construction_rounded,
            size: 56,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Başlık
        Text(
          'Şantiye Cepte',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Nasıl devam etmek istersiniz?',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.gray400),
        ),
      ],
    );
  }

  Widget _buildRoleCards() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: UserRole.values.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final role = UserRole.values[index];
        return _RoleCard(
          role: role,
          isSelected: _selectedRole == role,
          onTap: () => _selectRole(role),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = _selectedRole != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isEnabled ? 1.0 : 0.5,
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: isEnabled ? _continueToRegister : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.gray600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isEnabled ? 4 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Devam Et',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaten hesabınız var mı?',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray400),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: const Text(
            'Giriş Yapın',
            style: TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rol Kartı Widget'ı
class _RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getRoleIcon() {
    switch (role) {
      case UserRole.contractor:
        return Icons.business_rounded;
      case UserRole.subcontractor:
        return Icons.engineering_rounded;
      case UserRole.worker:
        return Icons.handyman_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryOrange.withValues(alpha: 0.15)
              : AppTheme.gray800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.gray700,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? AppShadows.orange : null,
        ),
        child: Row(
          children: [
            // İkon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryOrange : AppTheme.gray700,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_getRoleIcon(), size: 32, color: Colors.white),
            ),

            const SizedBox(width: 16),

            // Metin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.turkishName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.gray400),
                  ),
                ],
              ),
            ),

            // Seçim İndikatörü
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryOrange : AppTheme.gray500,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
