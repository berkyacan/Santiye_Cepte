import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/app_constants.dart';

/// Supabase Servis Sınıfı
/// Tüm Supabase işlemlerini merkezi olarak yönetir
class SupabaseService {
  static SupabaseClient? _client;

  /// Singleton instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase henüz başlatılmadı! Önce initialize() çağırın.',
      );
    }
    return _client!;
  }

  /// Supabase'i başlat
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
    _client = Supabase.instance.client;
  }

  /// Mevcut oturum
  static Session? get currentSession => client.auth.currentSession;

  /// Mevcut kullanıcı
  static User? get currentUser => client.auth.currentUser;

  /// Oturum açık mı?
  static bool get isAuthenticated => currentUser != null;

  // =====================================================
  // KİMLİK DOĞRULAMA (AUTH) İŞLEMLERİ
  // =====================================================

  /// E-posta ve şifre ile kayıt ol
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role, 'phone': phone},
    );
  }

  /// E-posta ve şifre ile giriş yap
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Çıkış yap
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Şifre sıfırlama e-postası gönder
  static Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Oturum durumu değişikliklerini dinle
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // =====================================================
  // PROFİL İŞLEMLERİ
  // =====================================================

  /// Kullanıcı profilini getir
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  /// Mevcut kullanıcının profilini getir
  static Future<Map<String, dynamic>?> getCurrentProfile() async {
    if (currentUser == null) return null;
    return await getProfile(currentUser!.id);
  }

  /// Profili güncelle
  static Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await client.from('profiles').update(data).eq('id', userId);
  }

  // =====================================================
  // İŞ İLANI İŞLEMLERİ
  // =====================================================

  /// Aktif iş ilanlarını getir
  /// publisherRole: Sadece belirli bir röldeki kullanıcıların ilanlarını getir
  static Future<List<Map<String, dynamic>>> getActiveJobs({
    int limit = 20,
    int offset = 0,
    String? tradeType,
    String? district,
    String? publisherRole, // 'contractor' veya 'subcontractor'
  }) async {
    var query = client
        .from('jobs')
        .select('''
          *,
          contractor:profiles!contractor_id (
            id,
            full_name,
            company_name,
            phone,
            rating,
            avatar_url,
            role
          )
        ''')
        .eq('status', 'active');

    if (tradeType != null) {
      query = query.eq('trade_type', tradeType);
    }
    if (district != null) {
      query = query.eq('district', district);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    // publisherRole filtresi varsa, sonuçları filtrele
    if (publisherRole != null) {
      final filtered = List<Map<String, dynamic>>.from(response).where((job) {
        final contractor = job['contractor'] as Map<String, dynamic>?;
        return contractor?['role'] == publisherRole;
      }).toList();
      return filtered;
    }

    return List<Map<String, dynamic>>.from(response);
  }

  /// İş ilanı detayını getir
  static Future<Map<String, dynamic>?> getJobDetails(String jobId) async {
    final response = await client
        .from('jobs')
        .select('''
          *,
          contractor:profiles!contractor_id (
            id,
            full_name,
            company_name,
            phone,
            rating,
            avatar_url,
            email
          )
        ''')
        .eq('id', jobId)
        .maybeSingle();
    return response;
  }

  /// Yeni iş ilanı oluştur
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String tradeType,
    required String district,
    String? address,
    int? durationDays,
    DateTime? startDate,
    double? budgetMin,
    double? budgetMax,
    int workersNeeded = 1,
  }) async {
    final response = await client
        .from('jobs')
        .insert({
          'contractor_id': currentUser!.id,
          'title': title,
          'description': description,
          'trade_type': tradeType,
          'district': district,
          'address': address,
          'duration_days': durationDays,
          'start_date': startDate?.toIso8601String(),
          'budget_min': budgetMin,
          'budget_max': budgetMax,
          'workers_needed': workersNeeded,
        })
        .select()
        .single();
    return response;
  }

  /// İş ilanını güncelle
  static Future<void> updateJob({
    required String jobId,
    required Map<String, dynamic> data,
  }) async {
    await client.from('jobs').update(data).eq('id', jobId);
  }

  /// Müteahhitin kendi ilanlarını getir
  static Future<List<Map<String, dynamic>>> getMyJobs() async {
    if (currentUser == null) return [];

    final response = await client
        .from('jobs')
        .select('*, bids:bids(count)')
        .eq('contractor_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // =====================================================
  // TEKLİF İŞLEMLERİ
  // =====================================================

  /// Teklif ver
  static Future<Map<String, dynamic>> submitBid({
    required String jobId,
    required double amount,
    String? message,
    int? proposedDurationDays,
    DateTime? proposedStartDate,
  }) async {
    final response = await client
        .from('bids')
        .insert({
          'job_id': jobId,
          'subcontractor_id': currentUser!.id,
          'amount': amount,
          'message': message,
          'proposed_duration_days': proposedDurationDays,
          'proposed_start_date': proposedStartDate?.toIso8601String(),
        })
        .select()
        .single();
    return response;
  }

  /// İş ilanına gelen teklifleri getir (Müteahhit için)
  static Future<List<Map<String, dynamic>>> getJobBids(String jobId) async {
    final response = await client
        .from('bids')
        .select('''
          *,
          subcontractor:profiles!subcontractor_id (
            id,
            full_name,
            company_name,
            phone,
            rating,
            avatar_url,
            experience_years,
            trade_types
          )
        ''')
        .eq('job_id', jobId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Müteahhitin tüm iş ilanlarına gelen teklifleri getir
  static Future<List<Map<String, dynamic>>> getReceivedBids() async {
    if (currentUser == null) return [];

    final response = await client
        .from('bids')
        .select('''
          *,
          job:jobs!inner (
            id,
            title,
            trade_type,
            district,
            status,
            contractor_id
          ),
          subcontractor:profiles!subcontractor_id (
            id,
            full_name,
            company_name,
            phone,
            rating,
            avatar_url
          )
        ''')
        .eq('job.contractor_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Taşeronun kendi tekliflerini getir
  static Future<List<Map<String, dynamic>>> getMyBids() async {
    if (currentUser == null) return [];

    final response = await client
        .from('bids')
        .select('''
          *,
          job:jobs (
            id,
            title,
            trade_type,
            district,
            status,
            contractor:profiles!contractor_id (
              full_name,
              company_name
            )
          )
        ''')
        .eq('subcontractor_id', currentUser!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Teklifi kabul et
  static Future<void> acceptBid(String bidId) async {
    await client.from('bids').update({'status': 'accepted'}).eq('id', bidId);
  }

  /// Teklifi reddet
  static Future<void> rejectBid(String bidId) async {
    await client.from('bids').update({'status': 'rejected'}).eq('id', bidId);
  }

  // =====================================================
  // ABONELİK İŞLEMLERİ
  // =====================================================

  /// Kullanıcının abonelik durumunu getir
  static Future<Map<String, dynamic>?> getSubscription(String userId) async {
    final response = await client
        .from('subscriptions')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  /// Mevcut kullanıcının aboneliğini getir
  static Future<Map<String, dynamic>?> getCurrentSubscription() async {
    if (currentUser == null) return null;
    return await getSubscription(currentUser!.id);
  }

  /// Abonelik durumunu kontrol et
  static Future<bool> checkSubscriptionStatus() async {
    if (currentUser == null) return false;

    final response = await client.rpc(
      'check_subscription_status',
      params: {'p_user_id': currentUser!.id},
    );

    return response == true;
  }

  /// Deneme süresini başlat
  static Future<void> startTrial() async {
    if (currentUser == null) return;

    final now = DateTime.now();
    final trialEnd = now.add(const Duration(days: 30));

    await client.from('subscriptions').upsert({
      'user_id': currentUser!.id,
      'status': 'trial',
      'trial_started_at': now.toIso8601String(),
      'trial_ends_at': trialEnd.toIso8601String(),
    });
  }

  /// Aboneliği aktifleştir
  static Future<void> activateSubscription() async {
    if (currentUser == null) return;

    final now = DateTime.now();
    final subscriptionEnd = now.add(const Duration(days: 30));

    await client.from('subscriptions').upsert({
      'user_id': currentUser!.id,
      'status': 'active',
      'subscription_started_at': now.toIso8601String(),
      'subscription_ends_at': subscriptionEnd.toIso8601String(),
      'last_payment_at': now.toIso8601String(),
      'next_payment_at': subscriptionEnd.toIso8601String(),
    });
  }

  // =====================================================
  // İŞÇİ PAZARYERİ İŞLEMLERİ
  // =====================================================

  /// Müsait işçileri getir (Sadece aktif abonelikli taşeronlar için)
  static Future<List<Map<String, dynamic>>> getAvailableWorkers({
    int limit = 20,
    int offset = 0,
    List<String>? tradeTypes,
    String? district,
  }) async {
    var query = client
        .from('worker_listings')
        .select('''
          *,
          worker:profiles!worker_id (
            id,
            full_name,
            phone,
            rating,
            avatar_url,
            experience_years,
            trade_types,
            district
          )
        ''')
        .eq('is_available', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  /// İşçi listesi oluştur/güncelle
  static Future<void> updateWorkerListing({
    required String title,
    String? description,
    required List<String> tradeTypes,
    double? dailyRate,
    double? hourlyRate,
    bool isAvailable = true,
    DateTime? availableFrom,
    List<String>? preferredDistricts,
  }) async {
    if (currentUser == null) return;

    await client.from('worker_listings').upsert({
      'worker_id': currentUser!.id,
      'title': title,
      'description': description,
      'trade_types': tradeTypes,
      'daily_rate': dailyRate,
      'hourly_rate': hourlyRate,
      'is_available': isAvailable,
      'available_from': availableFrom?.toIso8601String(),
      'preferred_districts': preferredDistricts,
    });
  }

  // =====================================================
  // BİLDİRİM İŞLEMLERİ
  // =====================================================

  /// Kullanıcının bildirimlerini getir
  static Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 50,
    bool unreadOnly = false,
  }) async {
    if (currentUser == null) return [];

    var query = client
        .from('notifications')
        .select()
        .eq('user_id', currentUser!.id);

    if (unreadOnly) {
      query = query.eq('is_read', false);
    }

    final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Bildirimi okundu olarak işaretle
  static Future<void> markNotificationAsRead(String notificationId) async {
    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Tüm bildirimleri okundu olarak işaretle
  static Future<void> markAllNotificationsAsRead() async {
    if (currentUser == null) return;

    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', currentUser!.id);
  }

  // =====================================================
  // GERÇEK ZAMANLI (REALTIME) DİNLEYİCİLER
  // =====================================================

  /// Yeni iş ilanlarını dinle
  static RealtimeChannel subscribeToNewJobs(
    void Function(Map<String, dynamic>) onNewJob,
  ) {
    return client
        .channel('public:jobs')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'jobs',
          callback: (payload) {
            onNewJob(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Kullanıcının bildirimlerini dinle
  static RealtimeChannel subscribeToNotifications(
    String userId,
    void Function(Map<String, dynamic>) onNotification,
  ) {
    return client
        .channel('public:notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onNotification(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Kanal aboneliğini iptal et
  static Future<void> unsubscribe(RealtimeChannel channel) async {
    await channel.unsubscribe();
  }
}
