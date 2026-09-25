import 'package:flutter/material.dart';
import '../../shared/models/profile_model.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;

  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final employmentStr = [profile.employmentType, profile.designation, profile.department]
        .where((e) => e.isNotEmpty)
        .join(' - ');
        
    final locationStr = [profile.taluka, profile.district]
        .where((e) => e.isNotEmpty)
        .join(', ');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Future: Navigate to profile details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: const Color(0xFF0056D2).withValues(alpha: 0.1),
                backgroundImage: profile.photoUrl != null
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                child: profile.photoUrl == null
                    ? const Icon(Icons.person, size: 40, color: Color(0xFF0056D2))
                    : null,
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0056D2),
                      ),
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
              fontSize: 14,
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
