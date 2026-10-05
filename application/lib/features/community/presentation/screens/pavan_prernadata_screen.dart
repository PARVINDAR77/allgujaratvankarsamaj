import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pavan_prernadata_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';

class PavanPrernadataScreen extends ConsumerStatefulWidget {
  const PavanPrernadataScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PavanPrernadataScreen> createState() => _PavanPrernadataScreenState();
}

class _PavanPrernadataScreenState extends ConsumerState<PavanPrernadataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('PAVAN_PRERNADATA');
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(pavanPrernadataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pavan Prernadata', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF041126),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(pavanPrernadataProvider),
          ),
          const Center(child: ViewBadge(sectionName: 'PAVAN_PRERNADATA')),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: const Color(0xFF041126),
      body: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF041126),
        onRefresh: () async {
          ref.refresh(pavanPrernadataProvider);
        },
        child: asyncData.when(
          data: (items) {
            if (items.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 64, color: Color(0xFFD4AF37)),
                          const SizedBox(height: 16),
                          const Text(
                            'No Pavan Prernadata records found.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.refresh(pavanPrernadataProvider),
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
          error: (err, stack) => LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error loading Pavan Prernadata: $err', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(pavanPrernadataProvider),
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
