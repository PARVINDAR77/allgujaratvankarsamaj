import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FamilyDetailsScreen extends StatelessWidget {
  const FamilyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060C1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF041126),
                border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VANKAR SAMAJ', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text('Family Details (પરિવાર વિગત)', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.family_restroom, color: Color(0xFFD4AF37), size: 28),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'સમાજનાં પરિવારોની માહિતી',
                      style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Family Database | Vankar Samaj Gujarat',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    _buildFamilyCard(
                      'કપડીયા પરિવાર',
                      'Kapadiya Family',
                      'હિંમતનગર',
                      'Himatnagar',
                      'મોસાળ: ઈડર | Masal: Idar',
                      Icons.home,
                      const Color(0xFF1A3A2A),
                    ),
                    _buildFamilyCard(
                      'વાંકર પરિવાર',
                      'Vankar Family',
                      'અમદાવાદ',
                      'Ahmedabad',
                      'મોસાળ: મહેસાણા | Masal: Mehsana',
                      Icons.location_city,
                      const Color(0xFF1A2A3A),
                    ),
                    _buildFamilyCard(
                      'સોલંકી પરિવાર',
                      'Solanki Family',
                      'પાટણ',
                      'Patan',
                      'મોસાળ: ઊંઝા | Masal: Unjha',
                      Icons.people,
                      const Color(0xFF2A1A3A),
                    ),
                    _buildFamilyCard(
                      'ચૌહાણ પરિવાર',
                      'Chauhan Family',
                      'સુરત',
                      'Surat',
                      'મોસાળ: નવસારી | Masal: Navsari',
                      Icons.group,
                      const Color(0xFF3A1A1A),
                    ),
                    _buildFamilyCard(
                      'પટેલ પરિવાર',
                      'Patel Family',
                      'રાજકોટ',
                      'Rajkot',
                      'મોસાળ: ભાવનગર | Masal: Bhavnagar',
                      Icons.person,
                      const Color(0xFF1A3A3A),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyCard(String nameGuj, String nameEng, String cityGuj, String cityEng, String details, IconData icon, Color bgColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$nameGuj ($nameEng)', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('$cityGuj ($cityEng)', style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 2),
                Text(details, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFD4AF37)),
        ],
      ),
    );
  }
}

