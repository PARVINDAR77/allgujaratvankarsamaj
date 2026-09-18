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
      backgroundColor: const Color(0xFF020B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041126),
        title: const Text("Today's Birthdays", style: TextStyle(color: Color(0xFFFFD700), fontSize: 18)),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
      ),
      body: birthdaysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load birthdays\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(todaysBirthdaysProvider),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                child: const Text('Retry', style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
        data: (birthdays) {
          if (birthdays.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cake_outlined, size: 64, color: Colors.white54),
                  SizedBox(height: 16),
                  Text('No birthdays today!', style: TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: birthdays.length,
            itemBuilder: (context, index) {
              final bday = birthdays[index];
              return _buildBirthdayCard(bday);
            },
          );
        },
      ),
    );
  }

  Widget _buildBirthdayCard(dynamic bday) {
    final String firstName = bday['firstName'] ?? 'Unknown';
    final String lastName = bday['lastName'] ?? '';
    final String gender = bday['gender'] ?? '';
    final int age = bday['age'] ?? 0;
    final String? photoUrl = bday['photoUrl'];

    Widget imageWidget = const Icon(Icons.person, size: 40, color: Colors.white54);
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        try {
          final parts = photoUrl.split(',');
          if (parts.length > 1) {
            Uint8List bytes = base64Decode(parts[1]);
            imageWidget = Image.memory(bytes, fit: BoxFit.cover, width: 60, height: 60);
          }
        } catch (e) {
          // fallback to icon
        }
      } else {
        imageWidget = Image.network(photoUrl, fit: BoxFit.cover, width: 60, height: 60,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.white54),
        );
      }
    }

    return Card(
      color: const Color(0xFF041126),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 60,
                height: 60,
                color: Colors.grey[800],
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
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(gender == 'FEMALE' ? Icons.female : Icons.male, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        'Turning $age today!',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cake, color: Colors.pinkAccent),
              onPressed: () {
                // Future placeholder: Send happy birthday message
              },
            ),
          ],
        ),
      ),
    );
  }
}
