import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/profile_model.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final employmentStr = profile.displayProfession;
    final locationStr = profile.displayLocation;

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
                  // Avatar
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFF0056D2).withValues(alpha: 0.1),
                    backgroundImage: profile.fullPhotoUrl != null
                        ? NetworkImage(profile.fullPhotoUrl!)
                        : null,
                    onBackgroundImageError: profile.fullPhotoUrl != null
                        ? (_, __) {}
                        : null,
                    child: profile.fullPhotoUrl == null
                        ? const Icon(Icons.person, size: 40, color: Color(0xFF0056D2))
                        : null,
                  ),
                  const SizedBox(width: 16),
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0056D2),
                                ),
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
                                profile.isFemale ? '👰 Bride (કન્યા)' : '👨 Groom (વર)',
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
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.cake_outlined,
                          profile.displayDob,
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.work, 
                          employmentStr.isEmpty ? 'Not Specified' : employmentStr
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.location_on, 
                          locationStr.isEmpty ? 'Location Not Specified' : locationStr
                        ),
                        if (profile.education.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _buildInfoRow(Icons.school, profile.education),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/candidate-profile-details', extra: profile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('View Profile (પ્રોફાઈલ જુઓ)', style: TextStyle(fontSize: 13)),
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
