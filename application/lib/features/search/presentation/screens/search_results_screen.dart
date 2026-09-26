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
                ? const Center(
                    child: Text('No profiles match your search criteria.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))
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
              backgroundImage: profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
              child: profile.photoUrl == null ? const Icon(Icons.person, size: 50, color: Color(0xFF0056D2)) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0056D2)),
                  ),
                  const SizedBox(height: 8),
                  Text('DOB: ${profile.dateOfBirth} | Gender: ${profile.gender}', style: const TextStyle(color: Colors.black87)),
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
