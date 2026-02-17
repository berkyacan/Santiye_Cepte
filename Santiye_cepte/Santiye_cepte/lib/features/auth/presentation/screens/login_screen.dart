import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../../../core/constants/app_constants.dart';

/// Giriş Ekranı
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
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
  
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Sıfırla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'E-posta adresinizi girin, şifre sıfırlama bağlantısı göndereceğiz.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                hintText: 'ornek@email.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) return;
              
              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.resetPassword(
                emailController.text.trim(),
              );
              
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Şifre sıfırlama bağlantısı gönderildi'
                          : authProvider.error ?? 'Bir hata oluştu',
                    ),
                    backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                );
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                _buildLogo(),
                
                const SizedBox(height: 48),
                
                // Başlık
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Form
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                
                const SizedBox(height: 16),
                
                // Beni Hatırla & Şifremi Unuttum
                _buildRememberForgot(),
                
                const SizedBox(height: 32),
                
                // Giriş Butonu
                _buildLoginButton(),
                
                const SizedBox(height: 32),
                
                // Kayıt Ol Linki
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
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
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Giriş Yap',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppTheme.gray900,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hesabınıza giriş yapın',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.gray500,
          ),
        ),
      ],
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
        return null;
      },
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Text(
                'Beni Hatırla',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray600,
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _showForgotPasswordDialog,
          child: const Text(
            'Şifremi Unuttum',
            style: TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : _handleLogin,
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Giriş Yap'),
          ),
        );
      },
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabınız yok mu?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.gray500,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(
                  selectedRole: UserRole.worker, // Varsayılan rol
                ),
              ),
            );
          },
          child: const Text(
            'Kayıt Olun',
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
