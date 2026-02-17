import 'package:flutter/material.dart';
import '../../../../services/supabase_service.dart';
import '../../../../core/constants/app_constants.dart';

/// İş İlanları Provider'ı
/// İş ilanlarını ve teklif işlemlerini yönetir
class JobsProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _jobs = [];
  List<Map<String, dynamic>> _myJobs = [];
  List<Map<String, dynamic>> _myBids = [];
  Map<String, dynamic>? _selectedJob;
  List<Map<String, dynamic>> _selectedJobBids = [];
  String? _error;

  // Filtreler
  TradeType? _selectedTradeType;
  String? _selectedDistrict;
  String? _publisherRole; // İlan yayınlayanın rolü filtresi
  int _currentPage = 0;
  bool _hasMore = true;

  // Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get jobs => _jobs;
  List<Map<String, dynamic>> get myJobs => _myJobs;
  List<Map<String, dynamic>> get myBids => _myBids;
  Map<String, dynamic>? get selectedJob => _selectedJob;
  List<Map<String, dynamic>> get selectedJobBids => _selectedJobBids;
  String? get error => _error;
  TradeType? get selectedTradeType => _selectedTradeType;
  String? get selectedDistrict => _selectedDistrict;
  String? get publisherRole => _publisherRole;
  bool get hasMore => _hasMore;

  /// Yayınlayan rolünü ayarla (taşeron için 'contractor', usta için 'subcontractor')
  void setPublisherRole(String? role) {
    _publisherRole = role;
  }

  /// İş ilanlarını yükle
  Future<void> loadJobs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _jobs = [];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newJobs = await SupabaseService.getActiveJobs(
        limit: AppConstants.jobsPerPage,
        offset: _currentPage * AppConstants.jobsPerPage,
        tradeType: _selectedTradeType?.value,
        district: _selectedDistrict,
        publisherRole: _publisherRole,
      );

      if (newJobs.length < AppConstants.jobsPerPage) {
        _hasMore = false;
      }

      _jobs.addAll(newJobs);
      _currentPage++;
    } catch (e) {
      _error = 'İş ilanları yüklenirken hata oluştu: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Filtreleri uygula
  void applyFilters({TradeType? tradeType, String? district}) {
    _selectedTradeType = tradeType;
    _selectedDistrict = district;
    loadJobs(refresh: true);
  }

  /// Filtreleri temizle
  void clearFilters() {
    _selectedTradeType = null;
    _selectedDistrict = null;
    loadJobs(refresh: true);
  }

  /// İş detayını yükle
  Future<void> loadJobDetails(String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedJob = await SupabaseService.getJobDetails(jobId);

      // Görüntülenme sayısını artır
      SupabaseService.client.rpc(
        'increment_job_views',
        params: {'p_job_id': jobId},
      );
    } catch (e) {
      _error = 'İş detayı yüklenirken hata oluştu: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Müteahhitin kendi ilanlarını yükle
  Future<void> loadMyJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myJobs = await SupabaseService.getMyJobs();
    } catch (e) {
      _error = 'İlanlarınız yüklenirken hata oluştu: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Yeni iş ilanı oluştur
  Future<bool> createJob({
    required String title,
    required String description,
    required TradeType tradeType,
    required String district,
    String? address,
    int? durationDays,
    DateTime? startDate,
    double? budgetMin,
    double? budgetMax,
    int workersNeeded = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.createJob(
        title: title,
        description: description,
        tradeType: tradeType.value,
        district: district,
        address: address,
        durationDays: durationDays,
        startDate: startDate,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
        workersNeeded: workersNeeded,
      );

      await loadMyJobs();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'İş ilanı oluşturulurken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// İş ilanını güncelle
  Future<bool> updateJob({
    required String jobId,
    String? title,
    String? description,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (status != null) data['status'] = status;

      await SupabaseService.updateJob(jobId: jobId, data: data);
      await loadMyJobs();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'İş ilanı güncellenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ==================== TEKLİF İŞLEMLERİ ====================

  /// Teklif ver
  Future<bool> submitBid({
    required String jobId,
    required double amount,
    String? message,
    int? proposedDurationDays,
    DateTime? proposedStartDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.submitBid(
        jobId: jobId,
        amount: amount,
        message: message,
        proposedDurationDays: proposedDurationDays,
        proposedStartDate: proposedStartDate,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        _error = 'Bu ilana zaten teklif verdiniz';
      } else if (e.toString().contains('check_subscription_status')) {
        _error = 'Teklif vermek için aktif aboneliğiniz olmalı';
      } else if (e.toString().contains('42501') ||
          e.toString().contains('row-level security')) {
        _error =
            'Bu işlem için yetkiniz yok. Müteahhitler veya kendi ilan sahipleri teklif veremez.';
      } else {
        _error = 'Teklif verilirken hata oluştu: $e';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// İş ilanına gelen teklifleri yükle
  Future<void> loadJobBids(String jobId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedJobBids = await SupabaseService.getJobBids(jobId);
    } catch (e) {
      _error = 'Teklifler yüklenirken hata oluştu: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Taşeronun kendi tekliflerini yükle
  Future<void> loadMyBids() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myBids = await SupabaseService.getMyBids();
    } catch (e) {
      _error = 'Teklifleriniz yüklenirken hata oluştu: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Teklifi kabul et
  Future<bool> acceptBid(String bidId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.acceptBid(bidId);

      // İlgili işin tekliflerini yeniden yükle
      if (_selectedJob != null) {
        await loadJobBids(_selectedJob!['id']);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Teklif kabul edilirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Teklifi reddet
  Future<bool> rejectBid(String bidId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.rejectBid(bidId);

      if (_selectedJob != null) {
        await loadJobBids(_selectedJob!['id']);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Teklif reddedilirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Seçili işi temizle
  void clearSelectedJob() {
    _selectedJob = null;
    _selectedJobBids = [];
    notifyListeners();
  }

  /// Hatayı temizle
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
