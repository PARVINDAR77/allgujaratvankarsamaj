import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_data.dart';
import '../../../../shared/providers/samaj_services_provider.dart';
import '../../../../shared/models/samaj_service.dart';

class SamajServicesScreen extends ConsumerStatefulWidget {
  const SamajServicesScreen({super.key});

  @override
  ConsumerState<SamajServicesScreen> createState() => _SamajServicesScreenState();
}

class _SamajServicesScreenState extends ConsumerState<SamajServicesScreen> {
  String? selectedDistrict;
  String? selectedTaluka;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();

  final List<Color> _categoryColors = [
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.teal,
    Colors.indigo,
    Colors.red,
    Colors.brown,
    Colors.blueGrey,
    Colors.pink,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  void _showServiceProviders(BuildContext context, String serviceName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildProvidersBottomSheet(ctx, serviceName),
    );
  }

  Widget _buildProvidersBottomSheet(BuildContext context, String serviceName) {
    // This could also be updated to an API call later. For now, empty state handling.
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$serviceName Professionals',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF041126)),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'No professionals registered for this service yet.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final districtsList = AppData.gujaratDistricts.keys.where((d) => d != 'Select District').toList();
    final talukasList = selectedDistrict != null && AppData.gujaratDistricts.containsKey(selectedDistrict) 
        ? AppData.gujaratDistricts[selectedDistrict]!.where((t) => t != 'Select Taluka').toList() 
        : <String>[];

    final servicesAsyncValue = ref.watch(samajServicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    // Custom Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16, vertical: 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF041126), Color(0xFF0A2A5E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (context.canPop()) context.pop();
                                  else context.go('/home');
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vankar Samaj Services',
                                      style: TextStyle(color: const Color(0xFFD4AF37), fontSize: isDesktop ? 28 : 22, fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      'સમાજ માટે - સમાજ દ્વારા',
                                      style: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.handshake, color: const Color(0xFFD4AF37).withValues(alpha: 0.8), size: isDesktop ? 48 : 36),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // --- SEARCH & FILTER SECTION ---
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search Bar
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Search services, professions...',
                              hintStyle: const TextStyle(color: Colors.black54),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Location Dropdowns Row
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 8,
                                  menuMaxHeight: 300,
                                  iconEnabledColor: const Color(0xFFD4AF37),
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: 'District',
                                    hintStyle: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                  value: selectedDistrict,
                                  items: districtsList.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))).toList(),
                                  onChanged: (val) => setState(() {
                                    selectedDistrict = val;
                                    selectedTaluka = null; 
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 8,
                                  menuMaxHeight: 300,
                                  iconEnabledColor: const Color(0xFFD4AF37),
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: 'Taluka',
                                    hintStyle: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                  value: selectedTaluka,
                                  items: talukasList.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))).toList(),
                                  onChanged: (val) => setState(() => selectedTaluka = val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _villageController,
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText: 'Village Name',
                                    hintStyle: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD4AF37))),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Search backend is temporarily disconnected.')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF041126),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    // --- END SEARCH & FILTER SECTION ---

                    // Services List
                    Expanded(
                      child: servicesAsyncValue.when(
                        data: (services) {
                          if (services.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.work_off, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No services available at the moment.',
                                    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Group services by category
                          final Map<String, List<SamajService>> groupedServices = {};
                          for (var service in services) {
                            if (!groupedServices.containsKey(service.category)) {
                              groupedServices[service.category] = [];
                            }
                            groupedServices[service.category]!.add(service);
                          }

                          final categories = groupedServices.keys.toList();

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            physics: const BouncingScrollPhysics(),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final categoryName = categories[index];
                              final categoryServices = groupedServices[categoryName]!;
                              final Color color = _categoryColors[index % _categoryColors.length];
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category Header
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: color.withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.category, color: color, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              categoryName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: color.withValues(alpha: 0.9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Items Grid
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 280,
                                        mainAxisExtent: 68,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: categoryServices.length,
                                      itemBuilder: (context, itemIndex) {
                                        final service = categoryServices[itemIndex];
                                        
                                        return InkWell(
                                          onTap: () {
                                            _showServiceProviders(context, service.title);
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey.shade200),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.03),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                if (service.icon.isNotEmpty) ...[
                                                  Text(
                                                    service.icon,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontFamily: 'Roboto',
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                Expanded(
                                                  child: Text(
                                                    service.title,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF041126),
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 14),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text('Error loading services: $err'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => ref.refresh(samajServicesProvider),
                                child: const Text('Retry'),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
