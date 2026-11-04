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

  void _openPhotoLightbox(BuildContext context, SamajSuperStar item) {
    if (item.photoUrl == null || item.photoUrl!.trim().isEmpty) return;

    final displayName = item.gujaratiName?.isNotEmpty == true
        ? item.gujaratiName!
        : item.name;

    showDialog(
      context: context,
      barrierColor: const Color(0xEB000000),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Hero(
                  tag: 'super-star-list-photo-${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item.photoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xE6041126),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                  ),
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(samajSuperStarsProvider),
          ),
          const Center(child: ViewBadge(sectionName: 'SAMAJ_SUPER_STARS')),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: const Color(0xFF041126),
      body: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF041126),
        onRefresh: () async {
          ref.refresh(samajSuperStarsProvider);
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
                          const Icon(Icons.star_outline, size: 64, color: Color(0xFFD4AF37)),
                          const SizedBox(height: 16),
                          const Text(
                            'No Samaj Super Stars records found.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref.refresh(samajSuperStarsProvider),
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
                        MouseRegion(
                          cursor: (item.photoUrl != null && item.photoUrl!.isNotEmpty)
                              ? SystemMouseCursors.click
                              : SystemMouseCursors.basic,
                          child: GestureDetector(
                            onTap: () {
                              if (item.photoUrl != null && item.photoUrl!.isNotEmpty) {
                                _openPhotoLightbox(context, item);
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
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
                                if (item.photoUrl != null && item.photoUrl!.isNotEmpty)
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xE6041126),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.zoom_in, color: Color(0xFFD4AF37), size: 10),
                                          SizedBox(width: 2),
                                          Text(
                                            'મોટું જુઓ',
                                            style: TextStyle(
                                              color: Color(0xFFFFF2C2),
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
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
                      Text('Error loading Samaj Super Stars: $err', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(samajSuperStarsProvider),
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
