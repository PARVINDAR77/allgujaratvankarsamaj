import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:application/shared/models/directory_models.dart';
import 'package:application/shared/repositories/directory_repository.dart';

class ParganaOverviewScreen extends StatefulWidget {
  const ParganaOverviewScreen({super.key});

  @override
  State<ParganaOverviewScreen> createState() => _ParganaOverviewScreenState();
}

class _ParganaOverviewScreenState extends State<ParganaOverviewScreen> {
  final DirectoryRepository _repository = DirectoryRepository();
  List<DirectoryDistrict> _districts = [];
  Map<String, List<DirectoryPargana>> _parganasByDistrict = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final districts = await _repository.getDistricts();
      final Map<String, List<DirectoryPargana>> parganasMap = {};
      
      for (var district in districts) {
        final parganas = await _repository.getParganasByDistrict(district.id);
        parganasMap[district.id] = parganas;
      }

      if (mounted) {
        setState(() {
          _districts = districts;
          _parganasByDistrict = parganasMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B18), // Deep premium navy
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF041126),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 4)),
                ],
                border: const Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VANKAR SAMAJ', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        SizedBox(height: 2),
                        Text('Pargana Overview (પરગણાં)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_city, color: Color(0xFFD4AF37), size: 24),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
                : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Stats Banner
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF112236),
                            Color(0xFF0A1525),
                          ],
                        ),
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.05),
                            blurRadius: 20,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              border: Border(bottom: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.2))),
                            ),
                            child: const Text(
                              'ગુજરાત વણકર સમાજ (Gujarat Vankar Samaj)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatWidget('99', 'Total\nParganas'),
                                Container(height: 40, width: 1, color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
                                _buildStatWidget('100+', 'Villages\nCovered'),
                                Container(height: 40, width: 1, color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
                                _buildStatWidget('10K+', 'Families\nConnected'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'ગુજરાત વણકર સમાજ પરગણાં વિગતો',
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Dynamic Expandable Pargana Sections
                    ..._districts.map((district) {
                      final parganas = _parganasByDistrict[district.id] ?? [];
                      // Rotate colors for visual variety
                      final colors = [
                        const Color(0xFF4CAF50),
                        const Color(0xFF2196F3),
                        const Color(0xFF9C27B0),
                        const Color(0xFFF44336),
                        const Color(0xFFFF9800),
                      ];
                      final color = colors[district.sortOrder % colors.length];
                      
                      return _buildExpandableParganaCard(
                        district.nameGu, 
                        district.nameEn, 
                        '${parganas.length}', 
                        color, 
                        parganas
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatWidget(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildExpandableParganaCard(String title, String subtitle, String count, Color accentColor, List<DirectoryPargana> parganas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1828),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: const Color(0xFFD4AF37),
          iconColor: const Color(0xFFD4AF37),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.5)),
            ),
            child: Icon(Icons.location_on, color: accentColor, size: 24),
          ),
          title: Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                ),
                child: Text(count, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more, color: Color(0xFFD4AF37)),
            ],
          ),
          children: [
            if (parganas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('માહિતી ઉપલબ્ધ નથી (Data pending import)', style: TextStyle(color: Colors.white54)),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF041126),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: parganas.map((p) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFFD4AF37), size: 14),
                            const SizedBox(width: 6),
                            Flexible(child: Text(p.nameGu, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        if (p.areaDescriptionGu != null && p.areaDescriptionGu!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Text(p.areaDescriptionGu!, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ),
                        ]
                      ],
                    ),
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
