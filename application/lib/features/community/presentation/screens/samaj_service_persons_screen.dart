import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';
import '../../providers/samaj_services_provider.dart';

class SamajServicePersonsScreen extends ConsumerWidget {
  final String serviceId;
  final String serviceTitle;

  const SamajServicePersonsScreen({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(samajServicePersonsProvider(serviceId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            VankarHeader(
              showBackButton: true,
              subtitle: serviceTitle,
            ),
            Expanded(
              child: personsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
                error: (err, stack) => _buildErrorState(context, ref),
                data: (persons) => _buildPersonsList(context, ref, persons),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Unable to load service persons',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () => ref.invalidate(samajServicePersonsProvider(serviceId)),
            child: const Text('Retry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonsList(BuildContext context, WidgetRef ref, List<SamajServicePersonModel> persons) {
    return RefreshIndicator(
      color: AppColors.secondary,
      onRefresh: () async {
        ref.invalidate(samajServicePersonsProvider(serviceId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Count Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.engineering, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceTitle,
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${persons.length} Available Service Persons',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (persons.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF041026),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.person_search, color: AppColors.secondary, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No Service Persons Added Yet for $serviceTitle',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Admin can add service persons under this service category from the Admin Panel.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: persons.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final person = persons[index];
                  return _buildPersonCard(context, person);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonCard(BuildContext context, SamajServicePersonModel person) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.goldGradient,
                ),
                child: person.photoUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          person.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.black, size: 28),
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.black, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (person.gujaratiName.isNotEmpty)
                      Text(
                        person.gujaratiName,
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.secondary, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          person.city.isNotEmpty ? person.city : 'Gujarat',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        if (person.experience.isNotEmpty) ...[
                          const Text(' • ', style: TextStyle(color: Colors.white54)),
                          Text(
                            person.experience,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary, width: 0.8),
                ),
                child: Text(
                  person.serviceTitle.isNotEmpty ? person.serviceTitle : serviceTitle,
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (person.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              person.description,
              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          // Contact Actions Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone, color: AppColors.secondary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    person.phone,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () {
                  _showContactDialog(context, person);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.call, color: Colors.black, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'સંપર્ક કરો',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context, SamajServicePersonModel person) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF061224),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.contact_phone, color: AppColors.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                person.name,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (person.gujaratiName.isNotEmpty)
              Text(
                person.gujaratiName,
                style: const TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone, color: AppColors.secondary, size: 16),
                const SizedBox(width: 8),
                SelectableText(
                  person.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (person.city.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.secondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    person.city,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
            if (person.address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.home, color: AppColors.secondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      person.address,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            if (person.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF041026),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  person.description,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Close', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.cardNavy,
                  content: Text('Calling ${person.name} at ${person.phone}...'),
                ),
              );
            },
            icon: const Icon(Icons.call, color: Colors.black, size: 16),
            label: const Text('Call Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
