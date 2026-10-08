import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/profile/providers/liked_profiles_provider.dart';
import '../../shared/models/profile_model.dart';

class ProfileCard extends ConsumerWidget {
  final ProfileModel profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employmentStr = profile.displayProfession;
    final locationStr = profile.displayLocation;
    final isLiked = ref.watch(isProfileLikedProvider(profile.id));

    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/candidate-profile-details', extra: profile);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Verified badge
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFF0056D2).withValues(alpha: 0.1),
                        backgroundImage: profile.fullPhotoUrl != null
                            ? NetworkImage(profile.fullPhotoUrl!)
                            : null,
                        onBackgroundImageError: profile.fullPhotoUrl != null
                            ? (_, _) {}
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
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                profile.fullName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0056D2),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: profile.isFemale
                                      ? const Color(0xFFC2185B)
                                      : const Color(0xFF1976D2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Quick Like Heart Button
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                  child: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    key: ValueKey<bool>(isLiked),
                                    color: isLiked ? Colors.redAccent : Colors.grey.shade400,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                'ID: ${profile.id}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0056D2)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${profile.age != null ? "${profile.age} Yrs • " : ""}${profile.maritalStatus}',
                                style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (profile.education.isNotEmpty && profile.education != 'Not Specified') ...[
                          _buildInfoRow(Icons.school, profile.education),
                          const SizedBox(height: 4),
                        ],
                        _buildInfoRow(
                          Icons.work, 
                          employmentStr.isEmpty 
                              ? 'Not Specified' 
                              : (profile.annualIncome != null ? '$employmentStr • ${profile.annualIncome}' : employmentStr),
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.location_on, 
                          locationStr.isEmpty ? 'Location Not Specified' : locationStr,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/candidate-profile-details', extra: profile);
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      label: const Text('View Profile (પ્રોફાઈલ જુઓ)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context);
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked ? Colors.redAccent : Colors.grey.shade700,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      side: BorderSide(
                        color: isLiked ? Colors.red.shade300 : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    label: Text(
                      isLiked ? 'પસંદ કરેલ' : 'પસંદ કરો',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isLiked ? Colors.redAccent : Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
