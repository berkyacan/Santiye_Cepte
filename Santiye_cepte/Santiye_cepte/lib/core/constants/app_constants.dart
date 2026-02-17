/// Şantiye Cepte - Uygulama Sabitleri
library;

class AppConstants {
  AppConstants._();

  // Uygulama Bilgileri
  static const String appName = 'Şantiye Cepte';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'İnşaat Sektörü Pazaryeri';

  // Supabase Yapılandırması
  static const String supabaseUrl = 'https://uichdzaektklrehyduct.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpY2hkemFla3RrbHJlaHlkdWN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5MDA2MjAsImV4cCI6MjA4MzQ3NjYyMH0.9mFPgzgZGJ3_i-NEuwGsxA-TOKAFKv9TdD5j8rjoWP8';

  // Abonelik Fiyatları
  static const double monthlySubscriptionPrice = 1000.0;
  static const int trialDays = 30;
  static const String currency = 'TL';

  // Varsayılan Konum (Antalya)
  static const String defaultCity = 'Antalya';
  static const double defaultLatitude = 36.8969;
  static const double defaultLongitude = 30.7133;

  // API Limitleri
  static const int jobsPerPage = 20;
  static const int workersPerPage = 20;
  static const int maxBidAmount = 10000000; // 10 milyon TL

  // Animasyon Süreleri
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Cache Süreleri
  static const Duration cacheExpiry = Duration(minutes: 5);

  // Kullanıcı Rolleri (Map)
  static const Map<String, String> userRoles = {
    'contractor': 'Müteahhit',
    'subcontractor': 'Taşeron',
    'worker': 'Usta/Çırak',
  };

  // Meslek Türleri (Map)
  static const Map<String, String> tradeTypes = {
    'electrician': 'Elektrikçi',
    'plumber': 'Tesisatçı',
    'welder': 'Kaynakçı',
    'painter': 'Boyacı',
    'carpenter': 'Marangoz',
    'mason': 'Duvarcı',
    'tiler': 'Seramikçi',
    'hvac': 'İzolasyoncu',
    'roofer': 'Çatıcı',
    'landscaper': 'Peyzajcı',
    'soguk_demir': 'Soğuk Demir',
    'kalipci': 'Kalıpçı',
    'diger': 'Diğer',
  };

  // Antalya İlçeleri (List)
  static const List<String> antalyaDistricts = [
    'Aksu',
    'Akseki',
    'Alanya',
    'Demre',
    'Döşemealtı',
    'Elmalı',
    'Finike',
    'Gazipaşa',
    'Gündoğmuş',
    'İbradı',
    'Kaş',
    'Kemer',
    'Kepez',
    'Konyaaltı',
    'Korkuteli',
    'Kumluca',
    'Lara',
    'Manavgat',
    'Muratpaşa',
    'Serik',
  ];
}

/// Kullanıcı Rolleri
enum UserRole {
  contractor('contractor', 'Müteahhit', 'Proje sahibi olarak iş ilanı verin'),
  subcontractor('subcontractor', 'Taşeron', 'İşlere teklif verin, usta bulun'),
  worker('worker', 'Usta/Çırak', 'İş fırsatlarını keşfedin');

  const UserRole(this.value, this.turkishName, this.description);
  
  final String value;
  final String turkishName;
  final String description;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.worker,
    );
  }
}

/// Meslek/Uzmanlık Alanları
enum TradeType {
  sogukDemir('soguk_demir', 'Soğuk Demir', 'construction'),
  kalipci('kalipci', 'Kalıpçı', 'view_in_ar'),
  duvarci('duvarci', 'Duvarcı', 'fence'),
  sivaci('sivaci', 'Sıvacı', 'format_paint'),
  elektrikci('elektrikci', 'Elektrikçi', 'electrical_services'),
  tesisatci('tesisatci', 'Tesisatçı', 'plumbing'),
  boyaci('boyaci', 'Boyacı', 'brush'),
  seramikci('seramikci', 'Seramikçi', 'grid_view'),
  marangoz('marangoz', 'Marangoz', 'carpenter'),
  kaynak('kaynak', 'Kaynakçı', 'local_fire_department'),
  izolasyon('izolasyon', 'İzolasyoncu', 'layers'),
  alcipan('alcipan', 'Alçıpancı', 'dashboard'),
  betoncu('betoncu', 'Betoncu', 'foundation'),
  hafriyat('hafriyat', 'Hafriyatçı', 'landscape'),
  diger('diger', 'Diğer', 'handyman');

  const TradeType(this.value, this.turkishName, this.iconName);
  
  final String value;
  final String turkishName;
  final String iconName;

  static TradeType fromString(String value) {
    return TradeType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TradeType.diger,
    );
  }
}

/// İş Durumları
enum JobStatus {
  active('active', 'Aktif', 'Teklif kabul ediliyor'),
  inProgress('in_progress', 'Devam Ediyor', 'İş başladı'),
  completed('completed', 'Tamamlandı', 'İş bitti'),
  cancelled('cancelled', 'İptal Edildi', 'İş iptal edildi');

  const JobStatus(this.value, this.turkishName, this.description);
  
  final String value;
  final String turkishName;
  final String description;

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => JobStatus.active,
    );
  }
}

/// Teklif Durumları
enum BidStatus {
  pending('pending', 'Beklemede', 'Teklif inceleniyor'),
  accepted('accepted', 'Kabul Edildi', 'Teklif kabul edildi'),
  rejected('rejected', 'Reddedildi', 'Teklif reddedildi'),
  withdrawn('withdrawn', 'Geri Çekildi', 'Teklif geri çekildi');

  const BidStatus(this.value, this.turkishName, this.description);
  
  final String value;
  final String turkishName;
  final String description;

  static BidStatus fromString(String value) {
    return BidStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BidStatus.pending,
    );
  }
}

/// Abonelik Durumları
enum SubscriptionStatus {
  trial('trial', 'Deneme', 'Ücretsiz deneme süresi'),
  active('active', 'Aktif', 'Aktif abonelik'),
  expired('expired', 'Süresi Doldu', 'Abonelik süresi doldu'),
  cancelled('cancelled', 'İptal Edildi', 'Abonelik iptal edildi');

  const SubscriptionStatus(this.value, this.turkishName, this.description);
  
  final String value;
  final String turkishName;
  final String description;

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => SubscriptionStatus.expired,
    );
  }
}

/// Antalya İlçeleri
class AntalyaDistricts {
  AntalyaDistricts._();

  static const List<String> all = [
    'Aksu',
    'Akseki',
    'Alanya',
    'Demre',
    'Döşemealtı',
    'Elmalı',
    'Finike',
    'Gazipaşa',
    'Gündoğmuş',
    'İbradı',
    'Kaş',
    'Kemer',
    'Kepez',
    'Konyaaltı',
    'Korkuteli',
    'Kumluca',
    'Manavgat',
    'Muratpaşa',
    'Serik',
  ];
}
