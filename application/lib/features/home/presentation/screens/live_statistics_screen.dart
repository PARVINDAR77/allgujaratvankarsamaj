import 'dart:async';
import 'dart:math';
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
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFFDF8),
        surfaceTintColor: Colors.transparent,
        leadingWidth: 62,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFEA88),
                      Color(0xFFD4AF37),
                      Color(0xFF8B5A10),
                      Color(0xFFFFD700),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1.5)),
                  ],
                ),
                padding: const EdgeInsets.all(2.4),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF004D40), Color(0xFF00251A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFFFFD700),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'લાઇવ કાઉન્ટર અને આંકડા',
              style: TextStyle(
                color: Color(0xFF0A192F),
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
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => ref.invalidate(dashboardStatisticsProvider),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFEA88),
                    Color(0xFFD4AF37),
                    Color(0xFF8B5A10),
                    Color(0xFFFFD700),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
              ),
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFFDF8),
                ),
                child: const Icon(Icons.refresh_rounded, color: Color(0xFF5D3800), size: 19),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Center(child: ViewBadge(sectionName: 'HOME_PROGRESS', isLight: true)),
          const SizedBox(width: 14),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.8),
          child: Container(
            height: 1.8,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFEA88),
                  Color(0xFFD4AF37),
                  Color(0xFF8B5A10),
                  Color(0xFFFFD700),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF006D77),
        backgroundColor: const Color(0xFFFFFDF8),
        onRefresh: () async {
          ref.invalidate(dashboardStatisticsProvider);
          await ref.read(dashboardStatisticsProvider.future);
        },
        child: statsAsyncValue.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF006D77)),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
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
                        backgroundColor: const Color(0xFF006D77),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Total Registered Candidates (Royal Hero Plaque)
                      _buildTotalCounter(totalCandidates, todayTotal),
                      const SizedBox(height: 16),

                      // 2. Total Boys & Total Girls breakdown with today counts
                      _buildGenderCounters(totalBoys, todayBoys, totalGirls, todayGirls),
                      const SizedBox(height: 16),

                      // Live auto-refresh indicator chip
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1.5)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.sync_rounded, size: 16, color: Color(0xFF059669)),
                              SizedBox(width: 8),
                              Text(
                                'લાઇવ ડેટા આપમેળે અપડેટ થાય છે (Auto-synced)',
                                style: TextStyle(
                                  color: Color(0xFF065F46),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
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
                          color: Color(0xFF0A192F),
                          fontSize: 19.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Center(
                        child: SizedBox(
                          width: 100,
                          height: 16,
                          child: CustomPaint(painter: GoldenLotusDividerPainter()),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'સરકારી અને ખાનગી ક્ષેત્રનું વિવરણ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),

                      // 4. Government Departments Card
                      _buildDepartmentCard(
                        'Government Departments\n(સરકારી વિભાગો)',
                        Icons.account_balance_rounded,
                        governmentStats,
                        isGovt: true,
                        onViewAll: () => context.push('/government-employees'),
                        viewAllText: 'View All Govt Employees (સરકારી કર્મચારીઓ જુઓ)',
                      ),
                      const SizedBox(height: 16),

                      // 5. Private & Professional Card
                      _buildDepartmentCard(
                        'Private & Professional\n(ખાનગી અને વ્યવસાય)',
                        Icons.business_center_rounded,
                        privateStats,
                        isGovt: false,
                        onViewAll: () => context.push('/private-employees'),
                        viewAllText: 'View All Private & Business (ખાનગી ડિરેક્ટરી જુઓ)',
                      ),
                      const SizedBox(height: 28),
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

  // --- 1. HERO TOTAL CANDIDATES PLAQUE ---
  Widget _buildTotalCounter(int total, int todayCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        // Aspect ratio of live_hero_card_pristine.png: 434 / 257 = 1.6887
        final cardHeight = cardWidth / 1.6887;

        return Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // 1. Pristine Full Royal Card Graphic
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/live_hero_card_pristine.png',
                    fit: BoxFit.fill,
                  ),
                ),

                // 2. Dynamic Live Count Number inside the 3D Gold Medallion
                // Medallion center is exactly at 50% X, and 37.7% Y
                Positioned(
                  left: 0,
                  right: 0,
                  top: cardHeight * 0.20,
                  height: cardHeight * 0.35,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        total.toString(),
                        style: const TextStyle(
                          color: Color(0xFF00382E), // Deep emerald green
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Dynamic todayCount badge if todayCount > 0
                if (todayCount > 0)
                  Positioned(
                    right: cardWidth * 0.035,
                    top: cardHeight * 0.035,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8FDF3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Live • આજે: +$todayCount',
                            style: const TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 2. BOYS & GIRLS SIDE-BY-SIDE STAT CARDS ---
  Widget _buildGenderCounters(int totalBoys, int todayBoys, int totalGirls, int todayGirls) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderCard(
            title: 'Boys (યુવકો)',
            subtitle: 'કુલ નોંધાયેલ યુવકો',
            totalCount: totalBoys,
            todayCount: todayBoys,
            isBoys: true,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildGenderCard(
            title: 'Girls (યુવતીઓ)',
            subtitle: 'કુલ નોંધાયેલ યુવતીઓ',
            totalCount: totalGirls,
            todayCount: todayGirls,
            isBoys: false,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderCard({
    required String title,
    required String subtitle,
    required int totalCount,
    required int todayCount,
    required bool isBoys,
  }) {
    final mainColor = isBoys ? const Color(0xFF00388C) : const Color(0xFF9C104D);
    final accentColor = isBoys ? const Color(0xFF0056D2) : const Color(0xFFC2185B);
    final badgeBg = isBoys ? const Color(0xFFE3F2FD) : const Color(0xFFFCE4EC);
    final badgeBorder = isBoys ? const Color(0xFF90CAF9) : const Color(0xFFF48FB1);

    return Container(
      decoration: BoxDecoration(
        // Outer 3D Metallic Gold Beveled Rim
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5B8),
            Color(0xFFD4AF37),
            Color(0xFF8B5A10),
            Color(0xFFFFD700),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.2),
      child: Container(
        height: 198,
        decoration: BoxDecoration(
          // Soft Silk Gradient
          gradient: LinearGradient(
            colors: isBoys
                ? [const Color(0xFFF4F9FF), const Color(0xFFDBEDFE)]
                : [const Color(0xFFFFF2F6), const Color(0xFFFDE0EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(19.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19.8),
          child: CustomPaint(
            painter: GenderCardWavePainter(isBoys: isBoys),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Row: Circular Gold Coin Medallion with Mars/Venus + Today Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Circular 3D Gold Medallion
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFEA88),
                              Color(0xFFD4AF37),
                              Color(0xFF8B5A10),
                              Color(0xFFFFD700),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBoys ? const Color(0xFFF8FBFF) : const Color(0xFFFFF8FB),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CustomPaint(
                                painter: GenderSymbolPainter(
                                  gender: isBoys ? 'MALE' : 'FEMALE',
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Today Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: badgeBorder, width: 1.0),
                        ),
                        child: Text(
                          '+$todayCount આજે',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Giant Counter Number
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      totalCount.toString(),
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. DEPARTMENT ACCORDION CARD ---
  Widget _buildDepartmentCard(
    String title,
    IconData icon,
    List<dynamic> items, {
    required bool isGovt,
    VoidCallback? onViewAll,
    String? viewAllText,
  }) {
    return Container(
      decoration: BoxDecoration(
        // Outer 3D Metallic Beveled Gold Frame
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5B8),
            Color(0xFFD4AF37),
            Color(0xFF8B5A10),
            Color(0xFFFFD700),
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.2),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFDF8),
              Color(0xFFFBF4E4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(19.8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19.8),
          child: Stack(
            children: [
              // Top-Right Corner Peacock Feather Plume
              Positioned(
                top: 0,
                right: 0,
                width: 90,
                height: 100,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/live_dept_peacock_corner.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                  ),
                ),
              ),

              Theme(
                data: ThemeData().copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isGovt
                            ? [
                                const Color(0xFF00897B),
                                const Color(0xFF004D40),
                                const Color(0xFF00251A),
                              ]
                            : [
                                const Color(0xFF1E88E5),
                                const Color(0xFF0D47A1),
                                const Color(0xFF0A2472),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2.0),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Center(
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0A192F),
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      height: 1.25,
                    ),
                  ),
                  iconColor: const Color(0xFF004D40),
                  collapsedIconColor: const Color(0xFF64748B),
                  children: [
                    if (items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Text('No data available', style: TextStyle(color: Color(0xFF94A3B8))),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 14, right: 14, bottom: 16),
                        child: Column(
                          children: [
                            ...items.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFDF8),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2C981), width: 1.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['name'].toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFDF8),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                                      ),
                                      child: Text(
                                        item['count'].toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF00382E),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            if (onViewAll != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: onViewAll,
                                    icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF004D40)),
                                    label: Text(
                                      viewAllText ?? 'View Directory',
                                      style: const TextStyle(
                                        color: Color(0xFF004D40),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      backgroundColor: const Color(0xFFFFFDF8),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- GENDER CARD BOTTOM WAVE PAINTER (METALLIC GOLD TRIM & CORNER WATERMARK) ---
class GenderCardWavePainter extends CustomPainter {
  final bool isBoys;
  const GenderCardWavePainter({required this.isBoys});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw smooth sweeping wave path at bottom-right
    final wavePath = Path();
    wavePath.moveTo(w * 0.15, h);
    wavePath.cubicTo(w * 0.50, h, w * 0.65, h - 38, w, h - 48);
    wavePath.lineTo(w, h);
    wavePath.close();

    final waveShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isBoys
          ? [
              const Color(0xFF1565C0),
              const Color(0xFF0D47A1),
              const Color(0xFF0A2472),
            ]
          : [
              const Color(0xFFD81B60),
              const Color(0xFFAD1457),
              const Color(0xFF6A0D37),
            ],
    ).createShader(Rect.fromLTWH(0, h - 55, w, 55));

    final wavePaint = Paint()
      ..shader = waveShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(wavePath, wavePaint);

    // 2. Gleaming metallic gold ribbon along the wave boundary
    final goldRibbon = Path();
    goldRibbon.moveTo(w * 0.15, h);
    goldRibbon.cubicTo(w * 0.50, h, w * 0.65, h - 38, w, h - 48);

    final goldShader = const LinearGradient(
      colors: [
        Color(0xFFFFEA88),
        Color(0xFFD4AF37),
        Color(0xFF8B5A10),
        Color(0xFFFFD700),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(Rect.fromLTWH(w * 0.2, h - 50, w * 0.8, 50));

    final goldPaint = Paint()
      ..shader = goldShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(goldRibbon, goldPaint);

    // Secondary subtle gold accent hairline below the main ribbon
    final goldRibbon2 = Path();
    goldRibbon2.moveTo(w * 0.25, h);
    goldRibbon2.cubicTo(w * 0.55, h, w * 0.70, h - 32, w, h - 42);
    final goldPaint2 = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(goldRibbon2, goldPaint2);

    // 3. Delicate Indian lotus mandala watermark in corner
    final lotusColor = isBoys ? const Color(0xFF2196F3) : const Color(0xFFE91E63);
    final cx = isBoys ? 0.0 : w;
    final cy = h * 0.65;

    final petalFill = Paint()
      ..color = lotusColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    final petalStroke = Paint()
      ..color = lotusColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const petalCount = 8;
    for (int i = 0; i < petalCount; i++) {
      final angle = (isBoys ? -0.5 : 0.5) * pi + (i * pi / (petalCount * 1.5));
      final petalPath = Path();
      petalPath.moveTo(cx, cy);
      final tipX = cx + 55 * cos(angle);
      final tipY = cy + 55 * sin(angle);
      final ctrl1X = cx + 30 * cos(angle - 0.25);
      final ctrl1Y = cy + 30 * sin(angle - 0.25);
      final ctrl2X = cx + 30 * cos(angle + 0.25);
      final ctrl2Y = cy + 30 * sin(angle + 0.25);
      petalPath.cubicTo(ctrl1X, ctrl1Y, tipX, tipY, tipX, tipY);
      petalPath.cubicTo(ctrl2X, ctrl2Y, cx, cy, cx, cy);
      canvas.drawPath(petalPath, petalFill);
      canvas.drawPath(petalPath, petalStroke);
    }
  }

  @override
  bool shouldRepaint(covariant GenderCardWavePainter oldDelegate) =>
      oldDelegate.isBoys != isBoys;
}

// --- CRISP GENDER SYMBOL PAINTER (EXACT MARS/VENUS VECTORS) ---
class GenderSymbolPainter extends CustomPainter {
  final String gender;
  final Color color;
  const GenderSymbolPainter({required this.gender, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    if (gender == 'MALE') {
      // Mars symbol: circle at lower-left, arrow pointing to upper-right
      const radius = 4.8;
      final circleCenter = Offset(cx - 2.2, cy + 2.2);
      canvas.drawCircle(circleCenter, radius, strokePaint);

      final arrowEnd = Offset(cx + 6.2, cy - 6.2);
      final arrowStart = Offset(
        circleCenter.dx + radius * 0.7071,
        circleCenter.dy - radius * 0.7071,
      );
      canvas.drawLine(arrowStart, arrowEnd, strokePaint);
      // Arrowhead
      canvas.drawLine(arrowEnd, Offset(arrowEnd.dx - 4.5, arrowEnd.dy), strokePaint);
      canvas.drawLine(arrowEnd, Offset(arrowEnd.dx, arrowEnd.dy + 4.5), strokePaint);
    } else if (gender == 'FEMALE') {
      // Venus symbol: circle at upper-center, cross pointing downward
      const radius = 4.8;
      final circleCenter = Offset(cx, cy - 2.5);
      canvas.drawCircle(circleCenter, radius, strokePaint);

      final stemStart = Offset(cx, circleCenter.dy + radius);
      final stemEnd = Offset(cx, cy + 7.0);
      canvas.drawLine(stemStart, stemEnd, strokePaint);
      // Crossbar
      canvas.drawLine(Offset(cx - 3.5, cy + 3.8), Offset(cx + 3.5, cy + 3.8), strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GenderSymbolPainter oldDelegate) =>
      oldDelegate.gender != gender || oldDelegate.color != color;
}

// --- GOLDEN LOTUS DIVIDER PAINTER ---
class GoldenLotusDividerPainter extends CustomPainter {
  const GoldenLotusDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final goldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFF996515)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Center petal
    final centerPetal = Path();
    centerPetal.moveTo(cx, cy - 8);
    centerPetal.cubicTo(cx + 6, cy - 4, cx + 4, cy + 4, cx, cy + 6);
    centerPetal.cubicTo(cx - 4, cy + 4, cx - 6, cy - 4, cx, cy - 8);
    canvas.drawPath(centerPetal, goldPaint);

    // Left petal
    final leftPetal = Path();
    leftPetal.moveTo(cx - 2, cy + 4);
    leftPetal.cubicTo(cx - 8, cy, cx - 12, cy - 5, cx - 14, cy - 2);
    leftPetal.cubicTo(cx - 12, cy + 3, cx - 7, cy + 6, cx - 2, cy + 5);
    canvas.drawPath(leftPetal, goldPaint);

    // Right petal
    final rightPetal = Path();
    rightPetal.moveTo(cx + 2, cy + 4);
    rightPetal.cubicTo(cx + 8, cy, cx + 12, cy - 5, cx + 14, cy - 2);
    rightPetal.cubicTo(cx + 12, cy + 3, cx + 7, cy + 6, cx + 2, cy + 5);
    canvas.drawPath(rightPetal, goldPaint);

    // Subtle side hairlines
    final linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.transparent, Color(0xFFD4AF37), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - 45, cy + 4), Offset(cx - 18, cy + 4), linePaint);
    canvas.drawLine(Offset(cx + 18, cy + 4), Offset(cx + 45, cy + 4), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
