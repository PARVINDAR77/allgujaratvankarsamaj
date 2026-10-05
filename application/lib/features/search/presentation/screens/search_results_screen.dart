import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(profileNotifierProvider.notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final profiles = profileState.profiles;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041126),
        title: const Text('Search Results', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18)),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: profileState.isLoading && profiles.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : profiles.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_search_rounded, size: 64, color: const Color(0xFF0056D2).withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'કોઈ પ્રોફાઈલ મળી નથી\n(No Profiles Found)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'તમારા શોધ માપદંડ મુજબ હાલમાં કોઈ ઉમેદવાર ઉપલબ્ધ નથી. કૃપા કરીને ફિલ્ટર્સ બદલીને ફરી પ્રયાસ કરો.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/search');
                              }
                            },
                            icon: const Icon(Icons.tune, size: 18),
                            label: const Text('શોધ ફિલ્ટર બદલો (Adjust Filters)', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0056D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: profiles.length + (profileState.isLoadingNextPage ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == profiles.length) {
                        return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                      }

                      final profile = profiles[index];
                      return _buildProfileCard(context, profile);
                    },
                  ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, ProfileModel profile) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: profile.fullPhotoUrl != null ? NetworkImage(profile.fullPhotoUrl!) : null,
              onBackgroundImageError: profile.fullPhotoUrl != null ? (_, __) {} : null,
              child: profile.fullPhotoUrl == null ? const Icon(Icons.person, size: 50, color: Color(0xFF0056D2)) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.fullName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0056D2)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: profile.isFemale
                              ? const Color(0xFFFCE4EC)
                              : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: profile.isFemale
                                ? const Color(0xFFF06292)
                                : const Color(0xFF64B5F6),
                          ),
                        ),
                        child: Text(
                          profile.isFemale ? '👰 Bride' : '👨 Groom',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: profile.isFemale
                                ? const Color(0xFFC2185B)
                                : const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('DOB: ${profile.dateOfBirth} | જાતિ: ${profile.displayGender}', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                  Text('Location: ${profile.district ?? "Not specified"}', style: const TextStyle(color: Colors.black87)),
                  Text('Profession: ${profile.designation.isNotEmpty ? profile.designation : "Not specified"}', style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/family-details');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0056D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('View Profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatefulBuilder(
                        builder: (context, setState) {
                          bool isLiked = false;
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                isLiked = !isLiked;
                              });
                              if (isLiked) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('You liked this profile! (તમે આ પ્રોફાઇલ પસંદ કરી છે!)'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.grey,
                              size: 28,
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
