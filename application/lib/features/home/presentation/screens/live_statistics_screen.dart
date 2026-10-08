import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/statistics_api.dart';
import '../providers/view_badge.dart';
import '../providers/views_provider.dart';

class LiveStatisticsScreen extends ConsumerStatefulWidget {
  const LiveStatisticsScreen({super.key});

  @override
  ConsumerState<LiveStatisticsScreen> createState() => _LiveStatisticsScreenState();
}

class _LiveStatisticsScreenState extends ConsumerState<LiveStatisticsScreen> {
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('HOME_PROGRESS');
    });

    // Auto-refresh live counter every 20 seconds while user is viewing
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) {
        ref.invalidate(dashboardStatisticsProvider);
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsyncValue = ref.watch(dashboardStatisticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 19),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'લાઇવ કાઉન્ટર અને આંકડા',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'Live Counter & Real-time Registry',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F172A)),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(dashboardStatisticsProvider),
          ),
          const Center(child: ViewBadge(sectionName: 'HOME_PROGRESS', isLight: true)),
          const SizedBox(width: 14),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0056D2),
        backgroundColor: Colors.white,
        onRefresh: () async {
          ref.invalidate(dashboardStatisticsProvider);
          // Wait for fresh data
          await ref.read(dashboardStatisticsProvider.future);
        },
        child: statsAsyncValue.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF0056D2)),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.analytics_outlined, color: Color(0xFFDC2626), size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Live Statistics\nલાઇવ આંકડા લોડ કરી શકાયા નથી',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(dashboardStatisticsProvider),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('ફરી પ્રયાસ કરો (Retry)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (stats) {
            final today = (stats['today'] as Map<String, dynamic>?) ?? {};
            final totalCandidates = (stats['totalCandidates'] as num?)?.toInt() ?? 0;
            final totalBoys = (stats['totalBoys'] as num?)?.toInt() ?? (today['boys'] as num?)?.toInt() ?? 0;
            final totalGirls = (stats['totalGirls'] as num?)?.toInt() ?? (today['girls'] as num?)?.toInt() ?? 0;
            final todayTotal = (today['total'] as num?)?.toInt() ?? ((today['boys'] as num?)?.toInt() ?? 0) + ((today['girls'] as num?)?.toInt() ?? 0);
            final todayBoys = (today['boys'] as num?)?.toInt() ?? 0;
            final todayGirls = (today['girls'] as num?)?.toInt() ?? 0;

            final departments = (stats['departments'] as Map<String, dynamic>?) ?? {};
            final governmentStats = (departments['government'] as List<dynamic>?) ?? [];
            final privateStats = (departments['private'] as List<dynamic>?) ?? [];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Total Registered Candidates
                      _buildTotalCounter(totalCandidates, todayTotal),
                      const SizedBox(height: 16),

                      // 2. Total Boys & Total Girls breakdown with today counts
                      _buildGenderCounters(totalBoys, todayBoys, totalGirls, todayGirls),
                      const SizedBox(height: 14),

                      // Live auto-refresh indicator chip
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.sync_rounded, size: 14, color: Color(0xFF059669)),
                              SizedBox(width: 6),
                              Text(
                                'લાઇવ ડેટા આપમેળે અપડેટ થાય છે (Auto-synced)',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 3. Department & Sector Breakdown Header
                      const Text(
                        'Department & Sector Breakdown',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'સરકારી અને ખાનગી ક્ષેત્રનું વિવરણ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // 4. Government Departments
                      _buildDepartmentCard(
                        'Government Departments (સરકારી વિભાગો)',
                        Icons.account_balance_rounded,
                        governmentStats,
                        const Color(0xFFEFF6FF),
                        const Color(0xFF1D4ED8),
                        onViewAll: () => context.push('/government-employees'),
                        viewAllText: 'View All Govt Employees (સરકારી કર્મચારીઓ જુઓ)',
                      ),
                      const SizedBox(height: 16),

                      // 5. Private & Professional
                      _buildDepartmentCard(
                        'Private & Professional (ખાનગી અને વ્યવસાય)',
                        Icons.business_center_rounded,
                        privateStats,
                        const Color(0xFFFEF3C7),
                        const Color(0xFFB45309),
                        onViewAll: () => context.push('/private-employees'),
                        viewAllText: 'View All Private & Business (ખાનગી ડિરેક્ટરી જુઓ)',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTotalCounter(int total, int todayCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Icon(Icons.people_alt_rounded, color: Color(0xFFD97706), size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live • આજે: +$todayCount',
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            total.toString(),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Total Registered Candidates',
            style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          const Text(
            'કુલ નોંધાયેલ ઉમેદવારો (લાઇવ રજિસ્ટ્રી)',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCounters(int totalBoys, int todayBoys, int totalGirls, int todayGirls) {
    return Row(
      children: [
        Expanded(
          child: _buildCounterBox(
            title: 'Boys (યુવકો)',
            subtitle: 'કુલ નોંધાયેલ યુવકો',
            totalCount: totalBoys,
            todayCount: todayBoys,
            bgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            borderColor: const Color(0xFFBFDBFE),
            icon: Icons.male_rounded,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildCounterBox(
            title: 'Girls (યુવતીઓ)',
            subtitle: 'કુલ નોંધાયેલ યુવતીઓ',
            totalCount: totalGirls,
            todayCount: todayGirls,
            bgColor: const Color(0xFFFDF2F8),
            iconColor: const Color(0xFFDB2777),
            borderColor: const Color(0xFFFBCFE8),
            icon: Icons.female_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildCounterBox({
    required String title,
    required String subtitle,
    required int totalCount,
    required int todayCount,
    required Color bgColor,
    required Color iconColor,
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  '+$todayCount આજે',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            totalCount.toString(),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 34,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(
    String title,
    IconData icon,
    List<dynamic> items,
    Color iconBg,
    Color iconColor, {
    VoidCallback? onViewAll,
    String? viewAllText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          iconColor: const Color(0xFF0F172A),
          collapsedIconColor: const Color(0xFF64748B),
          children: [
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text('No data available', style: TextStyle(color: Color(0xFF94A3B8))),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    ...items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEDF2F7)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name'].toString(),
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  )
                                ],
                              ),
                              child: Text(
                                item['count'].toString(),
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (onViewAll != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onViewAll,
                            icon: Icon(Icons.arrow_forward_rounded, size: 16, color: iconColor),
                            label: Text(
                              viewAllText ?? 'View Directory',
                              style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: iconColor.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: iconBg.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
