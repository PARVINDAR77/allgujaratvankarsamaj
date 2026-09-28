import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FamilyDetailsScreen extends StatefulWidget {
  const FamilyDetailsScreen({super.key});

  @override
  State<FamilyDetailsScreen> createState() => _FamilyDetailsScreenState();
}

class _FamilyDetailsScreenState extends State<FamilyDetailsScreen> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _families = [
    {
      'nameGuj': 'કપડીયા પરિવાર',
      'nameEng': 'Kapadiya Family',
      'cityGuj': 'હિંમતનગર',
      'cityEng': 'Himatnagar',
      'details': 'મોસાળ: ઈડર | Masal: Idar',
      'icon': Icons.home,
    },
    {
      'nameGuj': 'વાંકર પરિવાર',
      'nameEng': 'Vankar Family',
      'cityGuj': 'અમદાવાદ',
      'cityEng': 'Ahmedabad',
      'details': 'મોસાળ: મહેસાણા | Masal: Mehsana',
      'icon': Icons.location_city,
    },
    {
      'nameGuj': 'સોલંકી પરિવાર',
      'nameEng': 'Solanki Family',
      'cityGuj': 'પાટણ',
      'cityEng': 'Patan',
      'details': 'મોસાળ: ઊંઝા | Masal: Unjha',
      'icon': Icons.people,
    },
    {
      'nameGuj': 'ચૌહાણ પરિવાર',
      'nameEng': 'Chauhan Family',
      'cityGuj': 'સુરત',
      'cityEng': 'Surat',
      'details': 'મોસાળ: નવસારી | Masal: Navsari',
      'icon': Icons.group,
    },
    {
      'nameGuj': 'પટેલ પરિવાર',
      'nameEng': 'Patel Family',
      'cityGuj': 'રાજકોટ',
      'cityEng': 'Rajkot',
      'details': 'મોસાળ: ભાવનગર | Masal: Bhavnagar',
      'icon': Icons.person,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFamilies = _families.where((f) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return f['nameGuj'].toLowerCase().contains(query) ||
             f['nameEng'].toLowerCase().contains(query) ||
             f['cityGuj'].toLowerCase().contains(query) ||
             f['cityEng'].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
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
                      Text('Family Details (પરિવાર વિગત)', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
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
                      style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4AF37)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFFD4AF37)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                              decoration: const InputDecoration(
                                hintText: 'પરિવાર શોધો... (Search Family)',
                                hintStyle: TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.bold),
                                border: InputBorder.none,
                              ),
                              onChanged: (v) => setState(() => _searchQuery = v),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (filteredFamilies.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('કોઈ પરિવાર મળ્યો નથી (No family found)', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        ),
                      )
                    else
                      ...filteredFamilies.map((f) => _buildFamilyCard(
                            f['nameGuj'],
                            f['nameEng'],
                            f['cityGuj'],
                            f['cityEng'],
                            f['details'],
                            f['icon'],
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyCard(String nameGuj, String nameEng, String cityGuj, String cityEng, String details, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
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
                Text('$nameGuj ($nameEng)', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$cityGuj ($cityEng)', style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(details, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFD4AF37)),
        ],
      ),
    );
  }
}
