import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/samaj_ratna_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';

class SamajRatnaScreen extends ConsumerStatefulWidget {
  const SamajRatnaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SamajRatnaScreen> createState() => _SamajRatnaScreenState();
}

class _SamajRatnaScreenState extends ConsumerState<SamajRatnaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('SAMAJ_RATNA');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ratnasAsync = ref.watch(samajRatnaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Samaj Ratna', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF041126),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(samajRatnaProvider),
          ),
          const Center(child: ViewBadge(sectionName: 'SAMAJ_RATNA')),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: const Color(0xFF041126),
      body: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF041126),
        onRefresh: () async {
          ref.refresh(samajRatnaProvider);
        },
        child: ratnasAsync.when(
          data: (ratnas) {
            if (ratnas.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.workspace_premium_outlined, size: 64, color: Color(0xFFD4AF37)),
                          const SizedBox(height: 16),
                          const Text(
                            'No Samaj Ratna records found.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.refresh(samajRatnaProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: ratnas.length,
              itemBuilder: (context, index) {
                final ratna = ratnas[index];
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
                          backgroundImage: ratna.photoUrl != null && ratna.photoUrl!.isNotEmpty 
                            ? NetworkImage(ratna.photoUrl!) 
                            : null,
                          child: ratna.photoUrl == null || ratna.photoUrl!.isEmpty
                            ? const Icon(Icons.person, size: 40, color: Color(0xFFD4AF37))
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ratna.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (ratna.gujaratiName != null && ratna.gujaratiName!.isNotEmpty)
                                Text(
                                  ratna.gujaratiName!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                              const SizedBox(height: 8),
                              if (ratna.designation != null && ratna.designation!.isNotEmpty)
                                Text(
                                  '${ratna.designation} ${ratna.year != null ? '(${ratna.year})' : ''}',
                                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w600),
                                ),
                              const SizedBox(height: 4),
                              if (ratna.description != null && ratna.description!.isNotEmpty)
                                Text(
                                  ratna.description!,
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
          error: (err, stack) => LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading Samaj Ratnas: $err', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(samajRatnaProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
