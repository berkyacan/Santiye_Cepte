import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/supabase_service.dart';

/// Şifre Sıfırlama Ekranı
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await SupabaseService.resetPassword(_emailController.text.trim());
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.gray900),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.lock_reset,
              size: 40,
              color: AppTheme.primaryOrange,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          const Text(
            'Şifrenizi mi Unuttunuz?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.gray900,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim.',
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.gray600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-posta adresi gereklidir';
              }
              if (!value.contains('@')) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'E-posta Adresi',
              hintText: 'ornek@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: Colors.white,
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

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Sıfırlama Bağlantısı Gönder'),
            ),
          ),

          const SizedBox(height: 24),

          // Back to Login
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Giriş sayfasına dön',
                style: TextStyle(color: AppTheme.primaryOrange),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 50,
            color: AppTheme.successGreen,
          ),
        ),

        const SizedBox(height: 32),

        const Text(
          'E-posta Gönderildi!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.gray900,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          '${_emailController.text} adresine şifre sıfırlama bağlantısı gönderdik.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.gray600,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Lütfen gelen kutunuzu kontrol edin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.gray500,
          ),
        ),

        const SizedBox(height: 32),

        // Tips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.infoBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.infoBlue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'E-postayı bulamıyor musunuz? Spam klasörünü kontrol edin.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.gray700,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Back Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Giriş Sayfasına Dön'),
          ),
        ),

        const SizedBox(height: 16),

        // Resend Button
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text(
            'Tekrar gönder',
            style: TextStyle(color: AppTheme.primaryOrange),
          ),
        ),
      ],
    );
  }
}
