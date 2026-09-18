import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/statistics_api.dart';

class LiveStatisticsScreen extends ConsumerWidget {
  const LiveStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsyncValue = ref.watch(dashboardStatisticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041126),
        title: const Text('Live Counter & Statistics', style: TextStyle(color: Color(0xFFFFD700), fontSize: 18)),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
      ),
      body: statsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load statistics\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(dashboardStatisticsProvider),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                child: const Text('Retry', style: TextStyle(color: Colors.black)),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTotalCounter(totalCandidates),
                const SizedBox(height: 20),
                _buildTodayCounter(today['boys'] ?? 0, today['girls'] ?? 0),
                const SizedBox(height: 24),
                const Text(
                  'Department Breakdown',
                  style: TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildDepartmentCard('Government Departments', Icons.account_balance, governmentStats),
                const SizedBox(height: 16),
                _buildDepartmentCard('Private & Professional', Icons.business_center, privateStats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalCounter(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF041126),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1),
      ),
      child: Column(
        children: [
          const Text('Total Registered Candidates', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            total.toString(),
            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 42, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCounter(int boys, int girls) {
    return Row(
      children: [
        Expanded(
          child: _buildCounterBox('Boys Today', boys, Colors.blueAccent),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCounterBox('Girls Today', girls, Colors.pinkAccent),
        ),
      ],
    );
  }

  Widget _buildCounterBox(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF041126),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(String title, IconData icon, List<dynamic> items) {
    return Card(
      color: const Color(0xFF041126),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Icon(icon, color: const Color(0xFFFFD700)),
        title: Text(title, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        iconColor: const Color(0xFFFFD700),
        collapsedIconColor: Colors.white70,
        children: items.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No data available', style: TextStyle(color: Colors.white54)),
                )
              ]
            : items.map((item) {
                return ListTile(
                  title: Text(item['name'].toString(), style: const TextStyle(color: Colors.white)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['count'].toString(),
                      style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
      ),
    );
  }
}
