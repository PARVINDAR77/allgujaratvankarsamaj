import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/widgets/vankar_header.dart';
import '../../providers/liked_profiles_provider.dart';

class LikedProfilesScreen extends ConsumerStatefulWidget {
  const LikedProfilesScreen({super.key});

  @override
  ConsumerState<LikedProfilesScreen> createState() => _LikedProfilesScreenState();
}

class _LikedProfilesScreenState extends ConsumerState<LikedProfilesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likedProfilesProvider.notifier).loadLikedProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(likedProfilesProvider);
    final count = state.profiles.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            const Text(
              'પસંદ કરેલ પ્રોફાઈલ',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
        actions: [
          IconButton(
            tooltip: 'રિફ્રેશ કરો (Refresh)',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(likedProfilesProvider.notifier).loadLikedProfiles(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const VankarHeader(),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFD4AF37),
                onRefresh: () => ref.read(likedProfilesProvider.notifier).loadLikedProfiles(),
                child: state.isLoading && state.profiles.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      )
                    : state.profiles.isEmpty
                        ? _buildEmptyState(context)
                        : _buildProfilesList(context, state.profiles),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.redAccent,
                      size: 52,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'તમે હજુ સુધી કોઈ પ્રોફાઈલ પસંદ કરી નથી',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'કોઈપણ ઉમેદવારની પ્રોફાઈલ પર હાર્ટ (❤️) બટન દબાવીને તમે અહીં તમારી પસંદ કરેલ યાદી બનાવી શકો છો.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/search-results');
                  },
                  icon: const Icon(Icons.search, size: 20),
                  label: const Text(
                    'પ્રોફાઈલ શોધો (Browse Profiles)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilesList(BuildContext context, List<ProfileModel> profiles) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return _buildLikedCard(context, profile);
      },
    );
  }

  Widget _buildLikedCard(BuildContext context, ProfileModel profile) {
    final employmentStr = profile.displayProfession;
    final locationStr = profile.displayLocation;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Candidate Avatar
                GestureDetector(
                  onTap: () => context.push('/candidate-profile-details', extra: profile),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF0056D2).withValues(alpha: 0.1),
                        backgroundImage: profile.fullPhotoUrl != null
                            ? NetworkImage(profile.fullPhotoUrl!)
                            : null,
                        child: profile.fullPhotoUrl == null
                            ? const Icon(Icons.person, size: 40, color: Color(0xFF0056D2))
                            : null,
                      ),
                      if (profile.isVerified == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Color(0xFF0056D2),
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Candidate Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              profile.fullName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Unlike Button
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'લિસ્ટમાંથી દૂર કરો (Remove from liked)',
                            icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
                            onPressed: () {
                              ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Gender tag + Age / Marital status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: profile.isFemale ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              profile.isFemale ? '👰 Bride' : '👨 Groom',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: profile.isFemale ? const Color(0xFFC2185B) : const Color(0xFF1976D2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${profile.age != null ? "${profile.age} વર્ષ • " : ""}${profile.maritalStatus}',
                            style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Education
                      if (profile.education.isNotEmpty && profile.education != 'Not Specified') ...[
                        Row(
                          children: [
                            Icon(Icons.school, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                profile.education,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                      ],

                      // Profession
                      Row(
                        children: [
                          Icon(Icons.work_outline, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              employmentStr.isEmpty ? 'Not Specified' : employmentStr,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              locationStr.isEmpty ? 'Location Not Specified' : locationStr,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                    label: const Text(
                      'દૂર કરો',
                      style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/candidate-profile-details', extra: profile);
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text(
                      'સંપૂર્ણ પ્રોફાઈલ જુઓ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
