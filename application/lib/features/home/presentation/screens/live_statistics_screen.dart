import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/statistics_api.dart';

class LiveStatisticsScreen extends ConsumerWidget {
  const LiveStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsyncValue = ref.watch(dashboardStatisticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Live Counter & Statistics',
          style: TextStyle(color: Color(0xFF041126), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF041126)),
        centerTitle: true,
      ),
      body: statsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load statistics\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dashboardStatisticsProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF041126),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
        data: (stats) {
          final today = stats['today'] ?? {};
          final totalCandidates = stats['totalCandidates'] ?? 0;
          final departments = stats['departments'] ?? {};
          final governmentStats = (departments['government'] as List<dynamic>?) ?? [];
          final privateStats = (departments['private'] as List<dynamic>?) ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTotalCounter(totalCandidates),
                const SizedBox(height: 20),
                _buildTodayCounter(today['boys'] ?? 0, today['girls'] ?? 0),
                const SizedBox(height: 32),
                const Text(
                  'Department Breakdown',
                  style: TextStyle(color: Color(0xFF041126), fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildDepartmentCard('Government Departments', Icons.account_balance, governmentStats, const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                const SizedBox(height: 16),
                _buildDepartmentCard('Private & Professional', Icons.business_center, privateStats, const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalCounter(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_alt, color: Color(0xFFD4AF37), size: 32),
          ),
          const SizedBox(height: 16),
          const Text('Total Registered Candidates', style: TextStyle(color: Color(0xFF718096), fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            total.toString(),
            style: const TextStyle(color: Color(0xFF041126), fontSize: 48, fontWeight: FontWeight.w900, height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCounter(int boys, int girls) {
    return Row(
      children: [
        Expanded(
          child: _buildCounterBox('Boys Today', boys, const Color(0xFFEBF8FF), const Color(0xFF3182CE), Icons.male),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCounterBox('Girls Today', girls, const Color(0xFFFFF5F7), const Color(0xFFD53F8C), Icons.female),
        ),
      ],
    );
  }

  Widget _buildCounterBox(String title, int count, Color bgColor, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            count.toString(),
            style: const TextStyle(color: Color(0xFF041126), fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Color(0xFF718096), fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(String title, IconData icon, List<dynamic> items, Color iconBg, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(title, style: const TextStyle(color: Color(0xFF041126), fontWeight: FontWeight.w700, fontSize: 16)),
          iconColor: const Color(0xFF041126),
          collapsedIconColor: Colors.black54,
          children: [
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text('No data available', style: TextStyle(color: Colors.black38)),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  children: items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDF2F7)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'].toString(),
                              style: const TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.w600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            ),
                            child: Text(
                              item['count'].toString(),
                              style: const TextStyle(color: Color(0xFF041126), fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
          ],
        ),
      ),
    );
  }
}
