import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Kimlik Doğrulama Provider'ı
/// Kullanıcı oturum durumunu ve işlemlerini yönetir
class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _currentProfile;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get currentProfile => _currentProfile;
  Map<String, dynamic>? get userProfile =>
      _currentProfile; // Alias for currentProfile
  String? get error => _error;

  UserRole? get userRole {
    if (_currentProfile == null) return null;
    return UserRole.fromString(_currentProfile!['role'] ?? 'worker');
  }

  String get userName => _currentProfile?['full_name'] ?? 'Kullanıcı';
  String get userEmail => _currentProfile?['email'] ?? '';
  String? get userPhone => _currentProfile?['phone'];
  String? get userAvatar => _currentProfile?['avatar_url'];
  String get userCity => _currentProfile?['city'] ?? 'Antalya';
  String? get userDistrict => _currentProfile?['district'];

  /// Mevcut kullanıcıyı kontrol et
  Future<void> checkCurrentUser() async {
    try {
      if (SupabaseService.isAuthenticated) {
        _isAuthenticated = true;
        await _loadProfile();
      }
    } catch (e) {
      _error = 'Oturum kontrolü yapılırken hata oluştu: $e';
    }
    notifyListeners();
  }

  /// Profil bilgilerini yükle
  Future<void> _loadProfile() async {
    try {
      _currentProfile = await SupabaseService.getCurrentProfile();
    } catch (e) {
      _error = 'Profil yüklenirken hata oluştu: $e';
    }
  }

  /// Kayıt ol
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role.value,
        phone: phone,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        await _loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Kayıt başarısız oldu';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('===== KAYIT HATASI =====');
      print(e.toString());
      print('========================');
      _error = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Giriş yap
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        await _loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Giriş başarısız oldu';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.signOut();
      _isAuthenticated = false;
      _currentProfile = null;
    } catch (e) {
      _error = 'Çıkış yapılırken hata oluştu: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Şifre sıfırlama
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Profil güncelle
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? district,
    String? address,
    String? companyName,
    String? bio,
    int? experienceYears,
    List<TradeType>? tradeTypes,
  }) async {
    if (_currentProfile == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};

      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (district != null) data['district'] = district;
      if (address != null) data['address'] = address;
      if (companyName != null) data['company_name'] = companyName;
      if (bio != null) data['bio'] = bio;
      if (experienceYears != null) data['experience_years'] = experienceYears;
      if (tradeTypes != null) {
        data['trade_types'] = tradeTypes.map((t) => t.value).toList();
      }

      await SupabaseService.updateProfile(
        userId: SupabaseService.currentUser!.id,
        data: data,
      );

      await _loadProfile();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Profil güncellenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hata mesajlarını Türkçe'ye çevir
  String _parseError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'E-posta veya şifre hatalı';
    } else if (error.contains('User already registered')) {
      return 'Bu e-posta adresi zaten kayıtlı';
    } else if (error.contains('Password should be at least')) {
      return 'Şifre en az 6 karakter olmalıdır';
    } else if (error.contains('Invalid email')) {
      return 'Geçersiz e-posta adresi';
    } else if (error.contains('Email not confirmed')) {
      return 'E-posta adresinizi doğrulamanız gerekiyor';
    } else if (error.contains('network')) {
      return 'İnternet bağlantınızı kontrol edin';
    }
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  /// Şifre değiştir
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Supabase şifre değiştirme
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hatayı temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
