import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/statistics_api.dart';
import '../providers/view_badge.dart';
import '../providers/views_provider.dart';
import '../widgets/web_home_header.dart';
import '../widgets/web_home_footer.dart';

class BirthdaysScreen extends ConsumerStatefulWidget {
  const BirthdaysScreen({super.key});

  @override
  ConsumerState<BirthdaysScreen> createState() => _BirthdaysScreenState();
}

class _BirthdaysScreenState extends ConsumerState<BirthdaysScreen> {
  // Web Interactive State
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Map<String, int> _wishCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('HOME_SERVICE');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // ============================== BUILD DISPATCHER ===========================
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final birthdaysAsync = ref.watch(todaysBirthdaysProvider);

    if (kIsWeb) {
      return _buildWebScaffold(context, birthdaysAsync);
    }
    return _buildMobileScaffold(context, birthdaysAsync);
  }

  // ===========================================================================
  // ============================ MOBILE SCAFFOLD (100% PRESERVED) =============
  // ===========================================================================
  Widget _buildMobileScaffold(BuildContext context, AsyncValue<List<dynamic>> birthdaysAsync) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Today's Birthdays", 
          style: TextStyle(color: Color(0xFF041126), fontSize: 20, fontWeight: FontWeight.bold)
        ),
        iconTheme: const IconThemeData(color: Color(0xFF041126)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF041126)),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(todaysBirthdaysProvider),
          ),
          const Center(child: ViewBadge(sectionName: 'HOME_SERVICE', isLight: true)),
          const SizedBox(width: 14),
        ],
      ),
      body: birthdaysAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load birthdays\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(todaysBirthdaysProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF041126),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
        data: (birthdays) {
          if (birthdays.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: const Icon(Icons.cake_outlined, size: 64, color: Color(0xFFD4AF37)),
                  ),
                  const SizedBox(height: 24),
                  const Text('No birthdays today!', style: TextStyle(color: Color(0xFF718096), fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: birthdays.length,
            itemBuilder: (context, index) {
              final bday = birthdays[index];
              return _buildBirthdayCard(context, bday);
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // ============================ WEB DESKTOP SCAFFOLD ==========================
  // ===========================================================================
  Widget _buildWebScaffold(BuildContext context, AsyncValue<List<dynamic>> birthdaysAsync) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/birthdays'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Prestigious Celebratory Hero Banner
            _buildWebHeroBanner(context, isDesktop),

            // 2. Centered Content Container
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
                    vertical: 36,
                  ),
                  child: birthdaysAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(60.0),
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      ),
                    ),
                    error: (err, _) => _buildWebErrorCard(err),
                    data: (birthdays) {
                      final filtered = _filterBirthdays(birthdays);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (birthdays.isEmpty)
                            _buildWebHeartwarmingCelebrationShowcase(context, isDesktop)
                          else ...[
                            _buildWebSectionHeader(filtered.length),
                            const SizedBox(height: 24),
                            if (filtered.isEmpty)
                              _buildWebNoResultsState()
                            else
                              _buildWebBirthdaysGrid(context, filtered, isDesktop, isTablet),
                          ],

                          const SizedBox(height: 48),

                          // Community Service & Care Initiatives
                          _buildWebServicePillarsSection(isDesktop),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Official Web Home Footer
            const WebHomeFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeroBanner(BuildContext context, bool isDesktop) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 700 && width < 1100;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E112A), // Festive royal purple
            Color(0xFF3B0B24), // Velvet wine
            Color(0xFF0F172A), // Deep heritage navy
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 20,
              vertical: isDesktop ? 32 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Breadcrumbs & Action Badges
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => context.go('/main-poster'),
                          borderRadius: BorderRadius.circular(4),
                          child: const Text(
                            'Home',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                        ),
                        Flexible(
                          child: Text(
                            isDesktop ? 'Service to Society • Birthdays (જન્મદિન મહોત્સવ)' : 'જન્મદિન મહોત્સવ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => ref.refresh(todaysBirthdaysProvider),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.refresh_rounded, size: 15, color: Color(0xFFFFD700)),
                                SizedBox(width: 5),
                                Text(
                                  'Refresh',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const ViewBadge(sectionName: 'HOME_SERVICE'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Main Title Block with Cake & Crown
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.cake_rounded, color: Color(0xFF1E112A), size: 32),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'સમાજ સ્નેહ સંવાદ અને જન્મદિન શુભકામનાઓ',
                            style: TextStyle(
                              color: Color(0xFFFFF7DB),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Service to Society • Community Felicitations & Daily Celebrations',
                            style: TextStyle(
                              color: Color(0xFFFFDF73),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: const Text(
                              'આજના પાવન દિવસે જન્મદિન ધરાવતા અખિલ ગુજરાત વણકર સમાજના તમામ સભ્યોને દીર્ઘાયુષ્ય, ઉત્તમ આરોગ્ય અને સફળતાની મંગલકામનાઓ. સમાજ સેવા અને પારસ્પરિક સ્નેહ આપણી ઓળખ છે.',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Search Bar
                Container(
                  width: isDesktop ? 360 : double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1E36).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: Color(0xFFFFD700)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5),
                          decoration: const InputDecoration(
                            hintText: 'શોધો: સભ્યનું નામ, ગામ કે શહેર...',
                            hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: const Icon(Icons.close, size: 18, color: Colors.white70),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 4 Community Service Key Metrics
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.25)),
                  ),
                  child: isDesktop || isTablet
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetricItem(Icons.cake_rounded, 'જન્મદિન સ્નેહ વંદના', 'દૈનિક શુભકામના મંચ'),
                            _buildMetricDivider(),
                            _buildMetricItem(Icons.bloodtype_rounded, 'રક્તદાન અભિયાન', 'જીવનરક્ષક સમાજ સેવા'),
                            _buildMetricDivider(),
                            _buildMetricItem(Icons.elderly_rounded, 'વડીલ વંદના & સેવા', 'આદર અને સંભાળ પ્રોજેક્ટ'),
                            _buildMetricDivider(),
                            _buildMetricItem(Icons.volunteer_activism_rounded, 'આપાતકાલીન રાહત', 'મુશ્કેલીમાં તુરંત સહાય'),
                          ],
                        )
                      : Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            _buildMetricItem(Icons.cake_rounded, 'જન્મદિન સ્નેહ વંદના', 'દૈનિક શુભકામના મંચ'),
                            _buildMetricItem(Icons.bloodtype_rounded, 'રક્તદાન અભિયાન', 'જીવનરક્ષક સમાજ સેવા'),
                            _buildMetricItem(Icons.elderly_rounded, 'વડીલ વંદના & સેવા', 'આદર અને સંભાળ પ્રોજેક્ટ'),
                            _buildMetricItem(Icons.volunteer_activism_rounded, 'આપાતકાલીન રાહત', 'મુશ્કેલીમાં તુરંત સહાય'),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String title, String sub) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFF7DB),
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white12,
    );
  }

  Widget _buildWebSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 4, height: 18, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 8),
            const Text(
              'આજના જન્મદિન ધરાવતા તેજસ્વી સભ્યો',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF2F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFBCFE8)),
          ),
          child: Text(
            'કુલ સભ્યો: $count',
            style: const TextStyle(color: Color(0xFF9D174D), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildWebBirthdaysGrid(
    BuildContext context,
    List<dynamic> list,
    bool isDesktop,
    bool isTablet,
  ) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        mainAxisExtent: 220,
      ),
      itemBuilder: (context, index) {
        final bday = list[index];
        return _buildWebBirthdayCard(context, bday);
      },
    );
  }

  Widget _buildWebBirthdayCard(BuildContext context, dynamic bday) {
    final String firstName = bday['firstName'] ?? 'Unknown';
    final String lastName = bday['lastName'] ?? '';
    final String gender = bday['gender'] ?? 'MALE';
    final String? photoUrl = bday['photoUrl'];
    final String id = bday['id']?.toString() ?? '$firstName-$lastName';

    int age = 0;
    final String dateOfBirthStr = bday['dateOfBirth'] ?? '';
    if (dateOfBirthStr.isNotEmpty) {
      try {
        final dob = DateTime.parse(dateOfBirthStr);
        final today = DateTime.now();
        age = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
      } catch (_) {
        age = bday['age'] ?? 0;
      }
    } else {
      age = bday['age'] ?? 0;
    }

    final isFemale = gender == 'FEMALE';
    final wishCount = _wishCounts[id] ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Photo Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
                ),
                child: ClipOval(
                  child: _buildBdayImage(photoUrl),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$firstName $lastName',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isFemale ? const Color(0xFFFDF2F8) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🎂 $age Years Celebrating',
                        style: TextStyle(
                          color: isFemale ? const Color(0xFFBE185D) : const Color(0xFF1D4ED8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),

          // City or Occupation info
          if (bday['city'] != null && bday['city'].toString().isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    bday['city'].toString(),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const Spacer(),

          // Wish Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _sendBirthdayWish(context, id, '$firstName $lastName'),
              icon: const Icon(Icons.celebration_rounded, size: 15),
              label: Text(wishCount > 0 ? 'શુભેચ્છા પાઠવી ($wishCount)' : 'શુભેચ્છા પાઠવો 🎂💐'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B0B24),
                foregroundColor: const Color(0xFFFFDF73),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBdayImage(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        try {
          final parts = photoUrl.split(',');
          if (parts.length > 1) {
            Uint8List bytes = base64Decode(parts[1]);
            return Image.memory(bytes, fit: BoxFit.cover);
          }
        } catch (_) {}
      } else {
        return Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 34, color: Color(0xFF94A3B8)),
        );
      }
    }
    return const Icon(Icons.person, size: 34, color: Color(0xFF94A3B8));
  }

  void _sendBirthdayWish(BuildContext context, String id, String name) {
    HapticFeedback.lightImpact();
    setState(() {
      _wishCounts[id] = (_wishCounts[id] ?? 0) + 1;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF3B0B24),
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$name ને આપની જન્મદિન શુભકામનાઓ પાઠવવામાં આવી! 🎂💐',
                style: const TextStyle(
                  color: Color(0xFFFFF7DB),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Heartwarming Banner when list is empty
  Widget _buildWebHeartwarmingCelebrationShowcase(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFBEB),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.cake_rounded, color: Color(0xFFD97706), size: 44),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'આજના પાવન દિવસે જે પણ જ્ઞાતિજનોનો જન્મદિન છે તેમને',
            style: TextStyle(fontSize: 18, color: Color(0xFF475569), fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'અખિલ ગુજરાત વણકર સમાજ પરિવાર તરફથી હાર્દિક શુભકામનાઓ! 🎂💐',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF8B1538)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: const Text(
              'સમાજના પ્રત્યેક પરિવારમાં સદાય સુખ, શાંતિ, સમૃદ્ધિ, દીર્ઘાયુષ્ય અને ઉત્તમ આરોગ્ય જળવાઈ રહે તેવી ઈશ્વરચરણે હૃદયપૂર્વકની પ્રાર્થના. આપનું જીવન સમાજ માટે પ્રેરણાદાયી બને.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.55),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('આજના તમામ જ્ઞાતિજનોને સામૂહિક શુભકામનાઓ પાઠવી! 🙏✨')),
              );
            },
            icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
            label: const Text('સર્વે જ્ઞાતિજનોને મંગલ આશીર્વાદ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1538),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  // 4 Community Service Pillars Section
  Widget _buildWebServicePillarsSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'સમાજ સેવા અને જન કલ્યાણ પ્રવૃત્તિઓ (Service to Society):',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'અખિલ ગુજરાત વણકર સમાજ દ્વારા વર્ષ દરમિયાન યોજાતી માનવસેવા અને સહાય યોજનાઓ',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildServiceItem(Icons.bloodtype_rounded, 'રક્તદાન શિબિરો', 'સમગ્ર રાજ્યમાં બ્લડ ડોનેશન કેમ્પ', const Color(0xFFDC2626))),
                const SizedBox(width: 16),
                Expanded(child: _buildServiceItem(Icons.elderly_rounded, 'વડીલ વંદના યોજના', 'વરિષ્ઠ નાગરિક સહાય & આદર', const Color(0xFFD97706))),
                const SizedBox(width: 16),
                Expanded(child: _buildServiceItem(Icons.school_rounded, 'કન્યા કેળવણી સહાય', 'દીકરીઓ માટે સ્કોલરશીપ પ્રોત્સાહન', const Color(0xFF059669))),
                const SizedBox(width: 16),
                Expanded(child: _buildServiceItem(Icons.medical_services_rounded, 'તબીબી રાહત ભંડોળ', 'ગરીબ દર્દીઓ માટે સારવાર સહાય', const Color(0xFF2563EB))),
              ],
            )
          else
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildServiceItem(Icons.bloodtype_rounded, 'રક્તદાન શિબિરો', 'સમગ્ર રાજ્યમાં બ્લડ ડોનેશન કેમ્પ', const Color(0xFFDC2626)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildServiceItem(Icons.elderly_rounded, 'વડીલ વંદના યોજના', 'વરિષ્ઠ નાગરિક સહાય & આદર', const Color(0xFFD97706)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildServiceItem(Icons.school_rounded, 'કન્યા કેળવણી સહાય', 'દીકરીઓ માટે સ્કોલરશીપ પ્રોત્સાહન', const Color(0xFF059669)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildServiceItem(Icons.medical_services_rounded, 'તબીબી રાહત ભંડોળ', 'ગરીબ દર્દીઓ માટે સારવાર સહાય', const Color(0xFF2563EB)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildWebNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 50, color: Color(0xFF94A3B8)),
          const SizedBox(height: 14),
          const Text('આ નામ મુજબ કોઈ સભ્ય મળ્યા નથી', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            child: const Text('શોધ સાફ કરો'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebErrorCard(Object err) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
          const SizedBox(height: 14),
          Text('ડેટા લોડ કરવામાં ભૂલ: $err', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(todaysBirthdaysProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('ફરી પ્રયાસ કરો (Retry)'),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterBirthdays(List<dynamic> list) {
    if (_searchQuery.trim().isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((bday) {
      final name = '${bday['firstName'] ?? ''} ${bday['lastName'] ?? ''}'.toLowerCase();
      final city = (bday['city'] ?? '').toString().toLowerCase();
      return name.contains(q) || city.contains(q);
    }).toList();
  }

  // --- Mobile Helper Card ---
  Widget _buildBirthdayCard(BuildContext context, dynamic bday) {
    final String firstName = bday['firstName'] ?? 'Unknown';
    final String lastName = bday['lastName'] ?? '';
    final String gender = bday['gender'] ?? 'MALE';
    final String? photoUrl = bday['photoUrl'];
    
    int age = 0;
    final String dateOfBirthStr = bday['dateOfBirth'] ?? '';
    if (dateOfBirthStr.isNotEmpty) {
      try {
        final dob = DateTime.parse(dateOfBirthStr);
        final today = DateTime.now();
        age = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
      } catch (e) {
        age = bday['age'] ?? 0;
      }
    } else {
      age = bday['age'] ?? 0;
    }

    Widget imageWidget = const Icon(Icons.person, size: 40, color: Color(0xFF718096));
    if (photoUrl != null && photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('data:image')) {
        try {
          final parts = photoUrl.split(',');
          if (parts.length > 1) {
            Uint8List bytes = base64Decode(parts[1]);
            imageWidget = Image.memory(bytes, fit: BoxFit.cover, width: 70, height: 70);
          }
        } catch (_) {}
      } else {
        imageWidget = Image.network(
          photoUrl,
          fit: BoxFit.cover,
          width: 70,
          height: 70,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40, color: Color(0xFF718096)),
        );
      }
    }

    final isFemale = gender == 'FEMALE';
    final accentColor = isFemale ? const Color(0xFFD53F8C) : const Color(0xFF3182CE);
    final accentBg = isFemale ? const Color(0xFFFFF5F7) : const Color(0xFFEBF8FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF041126).withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showProfileDialog(context, bday, age, imageWidget),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: const Color(0xFFEDF2F7),
                    child: imageWidget,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$firstName $lastName',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF041126)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(isFemale ? Icons.female : Icons.male, size: 14, color: accentColor),
                                const SizedBox(width: 4),
                                Text(
                                  'Turning $age',
                                  style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('today! 🎂', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, dynamic bday, int age, Widget imageWidget) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: imageWidget,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${bday['firstName'] ?? ''} ${bday['lastName'] ?? ''}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF041126)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '🎂 Celebrating $age Years!',
                  style: const TextStyle(fontSize: 16, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (bday['occupation'] != null && bday['occupation'].toString().isNotEmpty) ...[
                  _buildDialogRow(Icons.work, bday['occupation']),
                  const SizedBox(height: 12),
                ],
                if (bday['education'] != null && bday['education'].toString().isNotEmpty) ...[
                  _buildDialogRow(Icons.school, bday['education']),
                  const SizedBox(height: 12),
                ],
                if (bday['city'] != null && bday['city'].toString().isNotEmpty) ...[
                  _buildDialogRow(Icons.location_on, bday['city']),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF041126),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close View', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF718096)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Color(0xFF4A5568)),
          ),
        ),
      ],
    );
  }
}
