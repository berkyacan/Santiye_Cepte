import 'package:flutter/material.dart';
import '../../../../services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// Abonelik Provider'ı
/// Taşeronların abonelik durumunu ve işlemlerini yönetir
class SubscriptionProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _subscription;
  String? _error;
  bool _hasActiveSubscription = false;

  // Getters
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get subscription => _subscription;
  String? get error => _error;
  bool get hasActiveSubscription => true; // _hasActiveSubscription;

  /// Abonelik durumu
  SubscriptionStatus get status {
    // HERKES PREMIUM: Geçici olarak herkes premium üye
    return SubscriptionStatus.active;

    /*
    if (_subscription == null) return SubscriptionStatus.expired;
    return SubscriptionStatus.fromString(_subscription!['status'] ?? 'expired');
    */
  }

  /// Deneme süresinde mi?
  bool get isInTrial => false;

  /// Aktif abonelik mi?
  bool get isActive => true;

  /// Kalan gün sayısı
  int get remainingDays {
    // Her zaman 30 gün var gibi göster
    return 30;

    /*
    if (_subscription == null) return 0;
    
    DateTime? endDate;
    if (isInTrial) {
      final trialEndsAt = _subscription!['trial_ends_at'];
      if (trialEndsAt != null) {
        endDate = DateTime.parse(trialEndsAt);
      }
    } else if (isActive) {
      final subscriptionEndsAt = _subscription!['subscription_ends_at'];
      if (subscriptionEndsAt != null) {
        endDate = DateTime.parse(subscriptionEndsAt);
      }
    }

    if (endDate == null) return 0;
    
    final remaining = endDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
    */
  }

  /// Bitiş tarihi
  DateTime? get endDate {
    // 30 gün sonrası
    return DateTime.now().add(const Duration(days: 30));

    /*
    if (_subscription == null) return null;
    
    if (isInTrial) {
      final trialEndsAt = _subscription!['trial_ends_at'];
      if (trialEndsAt != null) {
        return DateTime.parse(trialEndsAt);
      }
    } else if (isActive) {
      final subscriptionEndsAt = _subscription!['subscription_ends_at'];
      if (subscriptionEndsAt != null) {
        return DateTime.parse(subscriptionEndsAt);
      }
    }
    return null;
    */
  }

  /// Deneme başlangıç tarihi
  DateTime? get trialStartDate {
    if (_subscription == null) return null;
    final trialStartedAt = _subscription!['trial_started_at'];
    if (trialStartedAt != null) {
      return DateTime.parse(trialStartedAt);
    }
    return null;
  }

  /// Aylık fiyat
  double get monthlyPrice {
    return _subscription?['monthly_price'] ??
        AppConstants.monthlySubscriptionPrice;
  }

  /// Abonelik bilgilerini yükle
  Future<void> loadSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscription = await SupabaseService.getCurrentSubscription();

      // AUTO-PREMIUM: Eğer abonelik yoksa veya aktif değilse, veritabanında DENEME başlat.
      if (_subscription == null || _subscription!['status'] != 'active') {
        try {
          // 'active' yapmak engelleniyor olabilir, 'trial' (deneme) yapmayı dene
          await SupabaseService.startTrial();
          _subscription = await SupabaseService.getCurrentSubscription();
        } catch (e) {
          print('Auto-trial aktivasyon hatası: $e');
        }
      }

      _hasActiveSubscription = true; // Her zaman true (client-side override)
    } catch (e) {
      _error = 'Abonelik bilgileri yüklenirken hata oluştu: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Deneme süresini başlat
  Future<bool> startTrial() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.startTrial();
      await loadSubscription();
      return true;
    } catch (e) {
      _error = 'Deneme süresi başlatılırken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Aboneliği aktifleştir (Ödeme sonrası)
  Future<bool> activateSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.activateSubscription();
      await loadSubscription();
      return true;
    } catch (e) {
      _error = 'Abonelik aktifleştirilirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Durum açıklaması
  String get statusDescription {
    switch (status) {
      case SubscriptionStatus.trial:
        return '$remainingDays gün ücretsiz deneme kaldı';
      case SubscriptionStatus.active:
        return 'Aktif abonelik - $remainingDays gün kaldı';
      case SubscriptionStatus.expired:
        return 'Aboneliğiniz sona erdi';
      case SubscriptionStatus.cancelled:
        return 'Abonelik iptal edildi';
    }
  }

  /// Durum rengi
  Color get statusColor {
    switch (status) {
      case SubscriptionStatus.trial:
        return const Color(0xFF3B82F6); // Mavi
      case SubscriptionStatus.active:
        return const Color(0xFF10B981); // Yeşil
      case SubscriptionStatus.expired:
        return const Color(0xFFEF4444); // Kırmızı
      case SubscriptionStatus.cancelled:
        return const Color(0xFF6B7280); // Gri
    }
  }

  /// Durum ikonu
  IconData get statusIcon {
    switch (status) {
      case SubscriptionStatus.trial:
        return Icons.hourglass_empty_rounded;
      case SubscriptionStatus.active:
        return Icons.verified_rounded;
      case SubscriptionStatus.expired:
        return Icons.warning_rounded;
      case SubscriptionStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  /// Hatayı temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
