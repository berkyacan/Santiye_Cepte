import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

/// Kayıt Ekranı
class RegisterScreen extends StatefulWidget {
  final UserRole selectedRole;

  const RegisterScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanım şartlarını kabul etmelisiniz'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      role: widget.selectedRole,
      phone: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
    );

    if (success && mounted) {
      // Başarılı kayıt - Ana ekrana yönlendir
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted && authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.gray900),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Form Alanları
                _buildFullNameField(),
                const SizedBox(height: 16),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPhoneField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                
                const SizedBox(height: 24),
                
                // Kullanım Şartları
                _buildTermsCheckbox(),
                
                const SizedBox(height: 32),
                
                // Kayıt Ol Butonu
                _buildRegisterButton(),
                
                const SizedBox(height: 24),
                
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rol Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(),
                size: 18,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(width: 8),
              Text(
                widget.selectedRole.turkishName,
                style: const TextStyle(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Hesap Oluştur',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppTheme.gray900,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Şantiye Cepte\'ye hoş geldiniz',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.gray500,
          ),
        ),
      ],
    );
  }

  IconData _getRoleIcon() {
    switch (widget.selectedRole) {
      case UserRole.contractor:
        return Icons.business_rounded;
      case UserRole.subcontractor:
        return Icons.engineering_rounded;
      case UserRole.worker:
        return Icons.handyman_rounded;
    }
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Ad Soyad',
        hintText: 'Adınızı ve soyadınızı girin',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ad soyad gerekli';
        }
        if (value.trim().length < 3) {
          return 'Ad soyad en az 3 karakter olmalı';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'E-posta',
        hintText: 'ornek@email.com',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'E-posta gerekli';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Geçerli bir e-posta girin';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      decoration: const InputDecoration(
        labelText: 'Telefon (İsteğe Bağlı)',
        hintText: '05XX XXX XX XX',
        prefixIcon: Icon(Icons.phone_outlined),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 10) {
          return 'Geçerli bir telefon numarası girin';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Şifre',
        hintText: 'En az 6 karakter',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre gerekli';
        }
        if (value.length < 6) {
          return 'Şifre en az 6 karakter olmalı';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Şifre Tekrar',
        hintText: 'Şifrenizi tekrar girin',
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre tekrarı gerekli';
        }
        if (value != _passwordController.text) {
          return 'Şifreler eşleşmiyor';
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: AppTheme.primaryOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray600,
                ),
                children: [
                  const TextSpan(text: 'Kayıt olarak '),
                  TextSpan(
                    text: 'Kullanım Şartları',
                    style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' ve '),
                  TextSpan(
                    text: 'Gizlilik Politikası\'nı',
                    style: TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' kabul ediyorum.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleRegister,
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Kayıt Ol'),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Zaten hesabınız var mı?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.gray500,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
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
