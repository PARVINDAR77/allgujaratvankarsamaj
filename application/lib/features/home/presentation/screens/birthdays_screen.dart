import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/statistics_api.dart';
import 'dart:convert';
import 'dart:typed_data';

class BirthdaysScreen extends ConsumerWidget {
  const BirthdaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final birthdaysAsync = ref.watch(todaysBirthdaysProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Today's Birthdays", 
          style: TextStyle(color: Color(0xFF041126), fontSize: 20, fontWeight: FontWeight.bold)
        ),
        iconTheme: const IconThemeData(color: Color(0xFF041126)),
        centerTitle: true,
      ),
      body: birthdaysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load birthdays\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(todaysBirthdaysProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF041126),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
        data: (birthdays) {
          if (birthdays.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: const Icon(Icons.cake_outlined, size: 64, color: Color(0xFFD4AF37)),
                  ),
                  const SizedBox(height: 24),
                  const Text('No birthdays today!', style: TextStyle(color: Color(0xFF718096), fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: birthdays.length,
            itemBuilder: (context, index) {
              final bday = birthdays[index];
              return _buildBirthdayCard(context, bday);
            },
          );
        },
      ),
    );
  }

  Widget _buildBirthdayCard(BuildContext context, dynamic bday) {
    final String firstName = bday['firstName'] ?? 'Unknown';
    final String lastName = bday['lastName'] ?? '';
    final String gender = bday['gender'] ?? 'MALE';
    final String? photoUrl = bday['photoUrl'];
    
    // Calculate Age
    final String dateOfBirthStr = bday['dateOfBirth'] ?? '';
    int age = 0;
    if (dateOfBirthStr.isNotEmpty) {
      try {
        final dob = DateTime.parse(dateOfBirthStr);
        final today = DateTime.now();
        age = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
      } catch (e) {
        age = bday['age'] ?? 0;
      }
    } else {
      age = bday['age'] ?? 0;
    }

    Widget imageWidget = const Icon(Icons.person, size: 40, color: Color(0xFF718096));
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        try {
          final parts = photoUrl.split(',');
          if (parts.length > 1) {
            Uint8List bytes = base64Decode(parts[1]);
            imageWidget = Image.memory(bytes, fit: BoxFit.cover, width: 70, height: 70);
          }
        } catch (e) {
          // fallback
        }
      } else {
        imageWidget = Image.network(photoUrl, fit: BoxFit.cover, width: 70, height: 70,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Color(0xFF718096)),
        );
      }
    }

    final isFemale = gender == 'FEMALE';
    final accentColor = isFemale ? const Color(0xFFD53F8C) : const Color(0xFF3182CE);
    final accentBg = isFemale ? const Color(0xFFFFF5F7) : const Color(0xFFEBF8FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showProfileDialog(context, bday, age, imageWidget),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: imageWidget,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: const TextStyle(color: Color(0xFF041126), fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isFemale ? Icons.female : Icons.male, size: 14, color: accentColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Turning $age',
                                  style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('today! 🎂', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, dynamic bday, int age, Widget imageWidget) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: imageWidget,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${bday['firstName'] ?? ''} ${bday['lastName'] ?? ''}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF041126)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '🎂 Celebrating $age Years!',
                  style: const TextStyle(fontSize: 16, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (bday['occupation'] != null && bday['occupation'].toString().isNotEmpty) ...[
                  _buildDialogRow(Icons.work, bday['occupation']),
                  const SizedBox(height: 12),
                ],
                if (bday['education'] != null && bday['education'].toString().isNotEmpty) ...[
                  _buildDialogRow(Icons.school, bday['education']),
                  const SizedBox(height: 12),
                ],
                if (bday['city'] != null && bday['city'].toString().isNotEmpty) ...[
                  _buildDialogRow(Icons.location_on, bday['city']),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF041126),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close View', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDialogRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF718096)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Color(0xFF4A5568)),
          ),
        ),
      ],
    );
  }
}
