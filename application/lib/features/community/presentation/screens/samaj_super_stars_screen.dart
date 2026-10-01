import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/samaj_super_stars_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';

class SamajSuperStarsScreen extends ConsumerStatefulWidget {
  const SamajSuperStarsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SamajSuperStarsScreen> createState() => _SamajSuperStarsScreenState();
}

class _SamajSuperStarsScreenState extends ConsumerState<SamajSuperStarsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('SAMAJ_SUPER_STARS');
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(samajSuperStarsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samaj Super Stars', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF041126),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        actions: [
          const Center(child: ViewBadge(sectionName: 'SAMAJ_SUPER_STARS')),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: const Color(0xFF041126),
      body: asyncData.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No Samaj Super Stars records found.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                color: const Color(0xFF061224),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0x4DD4AF37)),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF041126),
                        backgroundImage: item.photoUrl != null && item.photoUrl!.isNotEmpty 
                          ? NetworkImage(item.photoUrl!) 
                          : null,
                        child: item.photoUrl == null || item.photoUrl!.isEmpty
                          ? const Icon(Icons.person, size: 40, color: Color(0xFFD4AF37))
                          : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.gujaratiName != null && item.gujaratiName!.isNotEmpty)
                              Text(
                                item.gujaratiName!,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            const SizedBox(height: 8),
                            if (item.designation != null && item.designation!.isNotEmpty)
                              Text(
                                '${item.designation} ${item.year != null ? '(${item.year})' : ''}',
                                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w600),
                              ),
                            const SizedBox(height: 4),
                            if (item.description != null && item.description!.isNotEmpty)
                              Text(
                                item.description!,
                                style: const TextStyle(color: Colors.white60, fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        error: (err, stack) => Center(
          child: Text('Error loading Samaj Super Stars: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
