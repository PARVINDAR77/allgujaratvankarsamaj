import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../../shared/models/profile_query_model.dart';
import '../../../../shared/widgets/profile_card.dart';
import '../../../../shared/widgets/vankar_header.dart';
import '../../providers/universal_listing_provider.dart';
import '../widgets/filter_bottom_sheet.dart';

class UniversalListingScreen extends ConsumerStatefulWidget {
  final String title;
  final ProfileQueryModel initialQuery;

  const UniversalListingScreen({
    super.key,
    required this.title,
    required this.initialQuery,
  });

  @override
  ConsumerState<UniversalListingScreen> createState() => _UniversalListingScreenState();
}

class _UniversalListingScreenState extends ConsumerState<UniversalListingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.initialQuery.search != null) {
      _searchController.text = widget.initialQuery.search!;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(universalListingProvider(widget.initialQuery).notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final currentQuery = ref.read(universalListingProvider(widget.initialQuery)).query;
      final newQuery = currentQuery.copyWith(search: value.isNotEmpty ? value : null);
      ref.read(universalListingProvider(widget.initialQuery).notifier).updateQuery(newQuery);
    });
  }

  void _showFilters() {
    final currentQuery = ref.read(universalListingProvider(widget.initialQuery)).query;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialQuery: currentQuery,
        onApply: (newQuery) {
          ref.read(universalListingProvider(widget.initialQuery).notifier).updateQuery(newQuery);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(universalListingProvider(widget.initialQuery));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      body: SafeArea(
        child: Column(
          children: [
            const VankarHeader(),
            
            // Header & Search
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0056D2),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list, color: Color(0xFF0056D2)),
                        onPressed: _showFilters,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search profiles...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF4F9FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(UniversalListingState state) {
    if (state.isLoading && state.profiles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0056D2)),
      );
    }

    if (state.error != null && state.profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(universalListingProvider(widget.initialQuery).notifier).updateQuery(state.query);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No profiles found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search term',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(universalListingProvider(widget.initialQuery).notifier).updateQuery(state.query);
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.profiles.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.profiles.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF0056D2)),
              ),
            );
          }
          return ProfileCard(profile: state.profiles[index]);
        },
      ),
    );
  }
}
