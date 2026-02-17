import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

/// Arama Ekranı
/// İş ilanları ve ustalar için arama
class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final SearchType searchType;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.searchType = SearchType.all,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

enum SearchType { all, jobs, workers }

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  SearchType _activeTab = SearchType.all;
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  List<String> _recentSearches =
      []; // Kullanıcının son aramaları burada saklanacak

  @override
  void initState() {
    super.initState();
    _activeTab = widget.searchType;
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }

    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Supabase'den arama sonuçlarını çek
    // Şimdilik boş liste döndür - Supabase entegrasyonu yapılacak
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isLoading = false;
      _results = []; // Gerçek veriler Supabase'den gelecek
    });

    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        backgroundColor: AppTheme.gray50,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (_) => _performSearch(),
            onSubmitted: (_) => _performSearch(),
            decoration: InputDecoration(
              hintText: 'İş veya usta ara...',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _results = []);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),

          // Content
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildRecentSearches()
                : _isLoading
                ? _buildLoadingState()
                : _results.isEmpty
                ? _buildEmptyState()
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildTabChip('Tümü', SearchType.all),
          const SizedBox(width: 8),
          _buildTabChip('İş İlanları', SearchType.jobs),
          const SizedBox(width: 8),
          _buildTabChip('Ustalar', SearchType.workers),
        ],
      ),
    );
  }

  Widget _buildTabChip(String label, SearchType type) {
    final isSelected = _activeTab == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _activeTab = type);
        _performSearch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.gray300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.gray700,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Son Aramalar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray900,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _recentSearches.clear());
              },
              child: const Text(
                'Temizle',
                style: TextStyle(color: AppTheme.gray500, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.map(
          (search) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, color: AppTheme.gray400),
            title: Text(search),
            trailing: const Icon(
              Icons.north_west,
              color: AppTheme.gray400,
              size: 18,
            ),
            onTap: () {
              _searchController.text = search;
              _performSearch();
            },
          ),
        ),

        const SizedBox(height: 32),

        // Popular Suggestions
        const Text(
          'Popüler Aramalar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Elektrikçi',
            'Tesisatçı',
            'Boyacı',
            'Kaynakçı',
            'Seramikçi',
            'Marangoz',
          ].map((s) => _buildSuggestionChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.primaryOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primaryOrange),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.gray200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off,
              size: 40,
              color: AppTheme.gray400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sonuç Bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"${_searchController.text}" için sonuç yok',
            style: const TextStyle(fontSize: 14, color: AppTheme.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final filteredResults = _results.where((r) {
      if (_activeTab == SearchType.all) return true;
      if (_activeTab == SearchType.jobs) return r['type'] == 'job';
      if (_activeTab == SearchType.workers) return r['type'] == 'worker';
      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final result = filteredResults[index];
        return _buildResultCard(result);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final isJob = result['type'] == 'job';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isJob ? AppTheme.primaryGradient : null,
              color: isJob ? null : AppTheme.gray200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              result['icon'],
              color: isJob ? Colors.white : AppTheme.gray600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result['subtitle'],
                  style: const TextStyle(fontSize: 13, color: AppTheme.gray500),
                ),
                if (isJob) ...[
                  const SizedBox(height: 6),
                  Text(
                    result['budget'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ] else if (result['rating'] != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        result['rating'].toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.gray700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.gray400),
        ],
      ),
    );
  }
}
