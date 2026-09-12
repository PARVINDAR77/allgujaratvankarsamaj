import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';
import '../../providers/samaj_services_provider.dart';
import 'samaj_service_persons_screen.dart';

class SamajServicesScreen extends ConsumerWidget {
  const SamajServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(samajServicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Standard Vankar Header
            const VankarHeader(
              showBackButton: true,
              subtitle: '“સમાજ માટે – સમાજ દ્વારા”',
            ),

            // Scrollable Content
            Expanded(
              child: servicesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
                error: (err, stack) => _buildBody(context, ref, []),
                data: (services) => _buildBody(context, ref, services),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<SamajServiceModel> services) {
    final eventServices = services.where((s) => s.category != 'Business Directory').toList();
    final directoryContacts = services.where((s) => s.category == 'Business Directory').toList();

    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: () async {
        ref.invalidate(samajServicesProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          children: [
            // Header: VANKAR Samaj Services
            const Text(
              'VANKAR',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const Text(
              'Samaj Services',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 20, height: 1, color: AppColors.secondary),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'સમાજ માટે – સમાજ દ્વારા',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(width: 20, height: 1, color: AppColors.secondary),
              ],
            ),
            const SizedBox(height: 12),

            // Dynamic Live Event Service Cards Grid
            _buildServicesGrid(context, eventServices),
            const SizedBox(height: 16),

            // Directory Section Title
            if (directoryContacts.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 24, height: 1, color: AppColors.secondary),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'વ્યવસાય મુજબ સંપર્ક માહિતી',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(width: 24, height: 1, color: AppColors.secondary),
                ],
              ),
              const SizedBox(height: 10),

              // Directory Table
              _buildDirectoryTable(context, directoryContacts),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context, List<SamajServiceModel> services) {
    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Text(
          'No active Samaj Services created yet.\nAdmin can add new services from Admin Panel.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.05,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final item = services[index];
        return _buildServiceTile(
          context,
          service: item,
        );
      },
    );
  }

  Widget _buildServiceTile(
    BuildContext context, {
    required SamajServiceModel service,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SamajServicePersonsScreen(
              serviceId: service.id,
              serviceTitle: service.title,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF041026),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: 0.15),
                  ),
                  child: Text(service.icon.isNotEmpty ? service.icon : "🤝", style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        service.category,
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              service.description.isNotEmpty ? service.description : 'Tap to view registered service persons.',
              style: const TextStyle(color: Colors.white60, fontSize: 9, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '👤 ${service.personsCount} Persons',
                    style: const TextStyle(color: AppColors.goldLight, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'View Persons',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward, color: Colors.black87, size: 9),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectoryTable(BuildContext context, List<SamajServiceModel> contacts) {
    if (contacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.secondary.withValues(alpha: 0.25), width: 0.8),
            verticalInside: BorderSide(color: AppColors.secondary.withValues(alpha: 0.25), width: 0.8),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2.6),
            1: FlexColumnWidth(2.6),
            2: FlexColumnWidth(2.6),
            3: FlexColumnWidth(1.2),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFF0A1F3D)),
              children: [
                _HeaderCol('વ્યવસાય'),
                _HeaderCol('નામ'),
                _HeaderCol('ફોન નંબર'),
                _HeaderCol('કોલ'),
              ],
            ),
            ...contacts.map((SamajServiceModel c) {
              final idx = contacts.indexOf(c);
              return TableRow(
                decoration: BoxDecoration(
                  color: idx.isEven ? const Color(0xFF041026) : const Color(0xFF061633),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            c.title,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _DataCol(c.contactPerson, isGold: true),
                  _DataCol(c.contactPhone),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${c.contactPerson} (${c.contactPhone})...')),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Icon(Icons.call, color: Color(0xFF2EB85C), size: 14),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderCol extends StatelessWidget {
  final String title;
  const _HeaderCol(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.secondary, fontSize: 10, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DataCol extends StatelessWidget {
  final String text;
  final bool isGold;
  const _DataCol(this.text, {this.isGold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      child: Text(
        text,
        style: TextStyle(
          color: isGold ? AppColors.goldLight : Colors.white,
          fontSize: 10,
          fontWeight: isGold ? FontWeight.bold : FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
