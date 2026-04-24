import 'dart:async';
import 'package:flutter/material.dart' hide FilterChip;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../config/constants.dart';
import '../../../providers/search_provider.dart';
import '../../../widgets/search_bar.dart';
import '../../../widgets/filter_chip.dart';
import '../../../widgets/course_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final provider = context.read<SearchProvider>();
      provider.search(query: _searchController.text);
    });
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
  }

  void _applyFilters({
    String? category,
    String? level,
    String? sortBy,
  }) {
    final provider = context.read<SearchProvider>();
    provider.search(
      category: category,
      level: level,
      sortBy: sortBy,
    );
    setState(() => _showFilters = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'البحث',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppTheme.primaryBlue,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: (_) {},
              onClear: () {
                context.read<SearchProvider>().clearSearch();
              },
              onFilter: _toggleFilters,
            ),
          ),
          if (_showFilters) _buildFilterPanel(searchProvider),
          Expanded(
            child: _buildResults(searchProvider),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildFilterPanel(SearchProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تصنيف الدورة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Constants.categories.map((cat) {
              return FilterChip(
                label: cat,
                selected: provider.selectedCategory == cat,
                onSelected: (_) {
                  _applyFilters(
                    category: provider.selectedCategory == cat ? null : cat,
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'المستوى',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Constants.levels.map((level) {
              return FilterChip(
                label: level,
                selected: provider.selectedLevel == level,
                onSelected: (_) {
                  _applyFilters(
                    level: provider.selectedLevel == level ? null : level,
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'ترتيب حسب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sortChip('الأحدث', 'newest', provider),
              _sortChip('الأعلى تقييماً', 'rating', provider),
              _sortChip('الأكثر شعبية', 'popular', provider),
              _sortChip('السعر: الأقل', 'price_low', provider),
              _sortChip('السعر: الأعلى', 'price_high', provider),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                context.read<SearchProvider>().clearFilters();
                setState(() => _showFilters = false);
              },
              child: const Text(
                'مسح الفلاتر',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: AppTheme.dangerRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String value, SearchProvider provider) {
    return FilterChip(
      label: label,
      selected: provider.sortBy == value,
      onSelected: (_) => _applyFilters(sortBy: value),
    );
  }

  Widget _buildResults(SearchProvider provider) {
    if (provider.isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => const ShimmerCourseCard(),
      );
    }

    if (provider.query.isEmpty) {
      return const EmptyState(
        icon: Icons.search,
        title: 'ابحث عن دورات',
        subtitle: 'اكتب كلمة البحث أو استخدم الفلاتر للعثور على الدورات',
      );
    }

    if (provider.results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'لا توجد نتائج',
        subtitle: 'جرب كلمات بحث مختلفة أو عدّل الفلاتر',
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryBlue,
      onRefresh: () => provider.search(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.results.length,
        itemBuilder: (context, index) {
          return CourseCard(course: provider.results[index]);
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                break;
              case 2:
                context.go('/my-courses');
                break;
              case 3:
                context.go('/notifications');
                break;
              case 4:
                context.go('/profile');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.greyText,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'البحث'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined), label: 'دوراتي'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined), label: 'الإشعارات'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'حسابي'),
          ],
        ),
      ),
    );
  }
}
