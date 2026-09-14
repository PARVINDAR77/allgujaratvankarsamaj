import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/pargana_provider.dart';

class ParganaOverviewScreen extends ConsumerStatefulWidget {
  const ParganaOverviewScreen({super.key});

  @override
  ConsumerState<ParganaOverviewScreen> createState() => _ParganaOverviewScreenState();
}

class _ParganaOverviewScreenState extends ConsumerState<ParganaOverviewScreen> {
  String _searchFilter = '';

  void _showParganaModal(BuildContext context, ParganaModel p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF041126),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.account_balance, color: Color(0xFFD4AF37)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                p.gujaratiName ?? p.name,
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.name != p.gujaratiName)
              Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(
              p.description ?? 'વણકર સમાજ પરગણું વિસ્તાર માહિતી',
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2040),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF997D20).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.villageCount != null)
                    Text('• ગામ સંખ્યા: ${p.villageCount}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.bold)),
                  if (p.districtRegion != null)
                    Text('• વિસ્તાર/જીલ્લો: ${p.districtRegion}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  if (p.leaderName != null && p.leaderName!.isNotEmpty)
                    Text('• વડા / પ્રતિનિધિ: ${p.leaderName}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  if (p.contactPhone != null && p.contactPhone!.isNotEmpty)
                    Text('• સંપર્ક નંબર: ${p.contactPhone}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Text('• નોંધાયેલ સંબંધ પ્રોફાઈલ્સ: ${p.totalCount}+', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('બંધ કરો (Close)', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/search');
            },
            child: const Text('પ્રોફાઈલ જુઓ (View Profiles)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parganasAsync = ref.watch(parganasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D2952),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041026),
        elevation: 4,
        title: const Text('ગુજરાત વણકર સમાજ પરગણાં (All Parganas)', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Poster Image Banner (Exact 1535:1024 ratio matching original template_pargana.jpg dimensions)
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenW = constraints.maxWidth;
                  // Exact aspect ratio of template_pargana.jpg (width: 1024px, height: 1535px)
                  final posterH = screenW * (1535 / 1024);

                  return SizedBox(
                    width: screenW,
                    height: posterH,
                    child: Stack(
                      children: [
                        // Single Master Poster Artwork (High Resolution)
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/template_pargana.jpg',
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM.jpeg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),

                        // Interactive Hotspots on Medallions
                        // Medallion 1: 35 Pargana (Top Left)
                        Positioned(
                          left: screenW * 0.05,
                          top: posterH * 0.60,
                          width: screenW * 0.28,
                          height: posterH * 0.14,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => setState(() => _searchFilter = '35'),
                          ),
                        ),

                        // Medallion 2: 27 Pargana (Top Center)
                        Positioned(
                          left: screenW * 0.36,
                          top: posterH * 0.60,
                          width: screenW * 0.28,
                          height: posterH * 0.14,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => setState(() => _searchFilter = '27'),
                          ),
                        ),

                        // Medallion 3: 16 Pargana (Top Right)
                        Positioned(
                          left: screenW * 0.67,
                          top: posterH * 0.60,
                          width: screenW * 0.28,
                          height: posterH * 0.14,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => setState(() => _searchFilter = '16'),
                          ),
                        ),

                        // Medallion 4: 14 Pargana (Bottom Left)
                        Positioned(
                          left: screenW * 0.20,
                          top: posterH * 0.77,
                          width: screenW * 0.28,
                          height: posterH * 0.14,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => setState(() => _searchFilter = '14'),
                          ),
                        ),

                        // Medallion 5: Other Pargana (Bottom Right)
                        Positioned(
                          left: screenW * 0.52,
                          top: posterH * 0.77,
                          width: screenW * 0.28,
                          height: posterH * 0.14,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => setState(() => _searchFilter = ''),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 2. Search & Filter Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFFD4AF37), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (val) => setState(() => _searchFilter = val),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'શોધો: પરગણું, ગામ અથવા જીલ્લો (Search pargana...)...',
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_searchFilter.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                              onPressed: () => setState(() => _searchFilter = ''),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance, color: Color(0xFFD4AF37), size: 18),
                            SizedBox(width: 6),
                            Text(
                              'તમામ પરગણાં યાદી (All Admin Parganas)',
                              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        parganasAsync.maybeWhen(
                          data: (list) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              'કુલ: ${list.length}',
                              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. Dynamic Pargana Cards List (Fetched directly from PostgreSQL API)
              parganasAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading parganas: $err', style: const TextStyle(color: Colors.redAccent)),
                ),
                data: (allParganas) {
                  final filteredList = allParganas.where((p) {
                    final search = _searchFilter.toLowerCase().trim();
                    if (search.isEmpty) return true;
                    final name = (p.name + (p.gujaratiName ?? '') + (p.districtRegion ?? '') + (p.description ?? '')).toLowerCase();
                    return name.contains(search);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2040),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF997D20).withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Text('કોઈ પરગણું મળ્યું નથી. (No Pargana matching search)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final p = filteredList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2040),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF997D20).withValues(alpha: 0.4)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF041026),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.gujaratiName ?? p.name,
                                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              if (p.gujaratiName != null && p.name != p.gujaratiName)
                                Text(
                                  p.name,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (p.villageCount != null)
                                  Text('ગામ સંખ્યા: ${p.villageCount}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w600)),
                                if (p.districtRegion != null)
                                  Text('વિસ્તાર: ${p.districtRegion}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                if (p.description != null)
                                  Text(p.description!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 16),
                          onTap: () => _showParganaModal(context, p),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
