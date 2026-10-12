import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../chat/providers/chat_provider.dart';
import '../../providers/match_provider.dart';

class MutualInterestScreen extends ConsumerStatefulWidget {
  const MutualInterestScreen({super.key});

  @override
  ConsumerState<MutualInterestScreen> createState() => _MutualInterestScreenState();
}

class _MutualInterestScreenState extends ConsumerState<MutualInterestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openChat(BuildContext context, ProfileModel profile, String? conversationId) async {
    if (conversationId != null && conversationId.isNotEmpty) {
      context.push(
        '/chat/$conversationId',
        extra: {
          'partnerName': profile.fullName,
          'partnerPhotoUrl': profile.fullPhotoUrl,
          'partnerGender': profile.gender,
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0056D2)),
        ),
      );
      final res = await ref.read(chatRepositoryProvider).getOrCreateConversation(profile.id);
      if (context.mounted) {
        Navigator.pop(context);
        if (res != null && res['conversationId'] != null) {
          context.push(
            '/chat/${res['conversationId']}',
            extra: {
              'partnerName': profile.fullName,
              'partnerPhotoUrl': profile.fullPhotoUrl,
              'partnerGender': profile.gender,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ચેટ શરૂ થઈ શકી નથી (Could not start chat)')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        centerTitle: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF0056D2), Color(0xFFE11D48)],
                  ).createShader(bounds),
                  child: const Text(
                    'મેળ અને સંબંધો',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '(Matches)',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'પરસ્પર સ્વીકૃતિ અને સુમેળ ધરાવતા સભ્યો',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0056D2), size: 20),
              tooltip: 'રીફ્રેશ કરો (Refresh)',
              onPressed: () => ref.read(matchProvider.notifier).loadAll(),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildPillTab(
                    index: 0,
                    label: 'પરસ્પર મેળ (Mutual)',
                    icon: Icons.favorite_rounded,
                    count: matchState.mutualInterests.length,
                    activeGradient: const LinearGradient(
                      colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPillTab(
                    index: 1,
                    label: 'આવેલી (Received)',
                    icon: Icons.mark_email_read_rounded,
                    count: matchState.receivedInterests.length,
                    activeGradient: const LinearGradient(
                      colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPillTab(
                    index: 2,
                    label: 'મોકલેલી (Sent)',
                    icon: Icons.send_rounded,
                    count: matchState.sentInterests.length,
                    activeGradient: const LinearGradient(
                      colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPillTab(
                    index: 3,
                    label: 'સ્માર્ટ મેળ (Smart)',
                    icon: Icons.auto_awesome_rounded,
                    count: matchState.smartMatches.length,
                    activeGradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF0056D2),
          backgroundColor: Colors.white,
          onRefresh: () => ref.read(matchProvider.notifier).loadAll(),
          child: matchState.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF0056D2), strokeWidth: 3),
                      const SizedBox(height: 16),
                      Text(
                        'મેળ ડેટા લોડ થઈ રહ્યો છે...',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMutualTab(matchState),
                    _buildReceivedTab(matchState),
                    _buildSentTab(matchState),
                    _buildSmartMatchesTab(matchState),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPillTab({
    required int index,
    required String label,
    required IconData icon,
    required int count,
    required Gradient activeGradient,
  }) {
    final isSelected = _tabController.index == index;

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF334155),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- TAB 1: MUTUAL MATCHES ---
  Widget _buildMutualTab(MatchState state) {
    if (state.mutualInterests.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero Cultural Card with mutual_interest_bg.jpg
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/mutual_interest_bg.jpg',
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0A2540), Color(0xFF1A365D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.stars_rounded, size: 14, color: Color(0xFF0F172A)),
                                SizedBox(width: 4),
                                Text(
                                  'પરસ્પર સુમેળ • Mutual Interest',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'બે પવિત્ર મનનું મિલન',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'જ્યારે બંને તરફથી સંમતિ મળે ત્યારે સીધી વાતચીત અને સંબંધ શરૂ થાય છે.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // How Mutual Connections Work Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFF0056D2), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'પરસ્પર મેળ કેવી રીતે બને છે?',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildStepRow(
                    stepNumber: '1',
                    title: 'ઉમેદવાર પસંદ કરો',
                    desc: 'તમારી પસંદગી અને પરગણા મુજબ મનપસંદ પ્રોફાઇલ શોધો.',
                    icon: Icons.search_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                  const SizedBox(height: 12),
                  _buildStepRow(
                    stepNumber: '2',
                    title: 'રસ દર્શાવો (Express Interest)',
                    desc: 'કનેક્શન વિનંતી મોકલો જેથી સામેવાળા ઉમેદવારને જાણ થાય.',
                    icon: Icons.favorite_outline_rounded,
                    color: const Color(0xFFE11D48),
                  ),
                  const SizedBox(height: 12),
                  _buildStepRow(
                    stepNumber: '3',
                    title: 'સ્વીકારાય એટલે વાતચીત (Chat)',
                    desc: 'બંને તરફથી મંજૂરી મળતાં જ સુરક્ષિત ચેટ આપમેળે શરૂ થશે.',
                    icon: Icons.chat_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Status Card (if sent or received exist)
            if (state.sentInterests.isNotEmpty || state.receivedInterests.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0056D2).withValues(alpha: 0.06),
                      const Color(0xFFD4AF37).withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0056D2).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0056D2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.receivedInterests.isNotEmpty
                              ? 'તમારી પાસે ${state.receivedInterests.length} નવી વિનંતીઓ છે!'
                              : 'તમે ${state.sentInterests.length} વિનંતીઓ મોકલી છે.',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.receivedInterests.isNotEmpty
                              ? 'સ્વીકારવા માટે "આવેલી" ટેબ તપાસો.'
                              : 'પ્રતિસાદ મળતાં જ અહીં દેખાશે.',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _tabController.animateTo(state.receivedInterests.isNotEmpty ? 1 : 2),
                      child: const Text('જુઓ →', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056D2))),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // CTA Button to Explore Smart Matches
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0056D2), Color(0xFF1E40AF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0056D2).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(3),
                icon: const Icon(Icons.explore_rounded, color: Colors.white, size: 20),
                label: const Text(
                  '🧭 સ્માર્ટ મેળ જુઓ (Explore Smart Matches)',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: state.mutualInterests.length,
      itemBuilder: (context, index) {
        final item = state.mutualInterests[index];
        final p = item.profile;
        if (p == null) return const SizedBox.shrink();

        return _buildCardWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCandidateTile(
                p,
                badgeText: 'પરસ્પર જોડાયેલા (Connected)',
                badgeColor: const Color(0xFFDCFCE7),
                badgeTextColor: const Color(0xFF15803D),
                badgeBorderColor: const Color(0xFF86EFAC),
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/candidate-profile-details?id=${p.id}', extra: p),
                      icon: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF0056D2)),
                      label: const Text(
                        'પ્રોફાઇલ જુઓ (View)',
                        style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(context, p, item.conversationId),
                      icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'વાતચીત કરો (Chat)',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: color),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: RECEIVED REQUESTS ---
  Widget _buildReceivedTab(MatchState state) {
    if (state.receivedInterests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mark_email_read_outlined,
        iconColor: const Color(0xFFF59E0B),
        title: 'કોઈ નવી વિનંતી નથી (No Pending Requests)',
        subtitle: 'જ્યારે કોઈ સભ્ય તમને કનેક્શન વિનંતી મોકલશે ત્યારે અહીં દર્શાવવામાં આવશે અને તમે સ્વીકારી શકશો.',
        actionLabel: 'સ્માર્ટ મેળ જુઓ (Find Matches)',
        onAction: () => _tabController.animateTo(3),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: state.receivedInterests.length,
      itemBuilder: (context, index) {
        final item = state.receivedInterests[index];
        final p = item.profile;
        if (p == null) return const SizedBox.shrink();

        return _buildCardWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCandidateTile(
                p,
                badgeText: 'આવેલી વિનંતી (Received)',
                badgeColor: const Color(0xFFFEF3C7),
                badgeTextColor: const Color(0xFFB45309),
                badgeBorderColor: const Color(0xFFFCD34D),
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final ok = await ref.read(matchProvider.notifier).declineRequest(item.id);
                        if (context.mounted && ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('વિનંતી નકારાઈ (Request Declined)')),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'નકારો (Decline)',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final ok = await ref.read(matchProvider.notifier).acceptRequest(item.id);
                        if (context.mounted && ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF10B981),
                              content: Text('વિનંતી સ્વીકારાઈ! હવે તમે ચેટ કરી શકો છો. (Accepted!)'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'સ્વીકારો (Accept)',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: SENT REQUESTS ---
  Widget _buildSentTab(MatchState state) {
    if (state.sentInterests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send_rounded,
        iconColor: const Color(0xFF0284C7),
        title: 'તમે હજી કોઈ વિનંતી મોકલી નથી',
        subtitle: 'તમને અનુકૂળ લાગતા ઉમેદવારોને કનેક્શન વિનંતી મોકલો અને સંબંધ આગળ વધારો.',
        actionLabel: 'ઉમેદવારો શોધો (Find Candidates)',
        onAction: () => context.go('/home'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: state.sentInterests.length,
      itemBuilder: (context, index) {
        final item = state.sentInterests[index];
        final p = item.profile;
        if (p == null) return const SizedBox.shrink();

        final isAccepted = item.status == 'ACCEPTED';
        return _buildCardWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCandidateTile(
                p,
                badgeText: isAccepted ? 'સ્વીકારાઈ (Accepted)' : 'વિચારણા હેઠળ (Pending)',
                badgeColor: isAccepted ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                badgeTextColor: isAccepted ? const Color(0xFF15803D) : const Color(0xFF1D4ED8),
                badgeBorderColor: isAccepted ? const Color(0xFF86EFAC) : const Color(0xFFBFDBFE),
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/candidate-profile-details?id=${p.id}', extra: p),
                      icon: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF0056D2)),
                      label: const Text(
                        'પ્રોફાઇલ જુઓ (View)',
                        style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  if (isAccepted) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openChat(context, p, item.conversationId),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Colors.white),
                        label: const Text(
                          'વાતચીત કરો (Chat)',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056D2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 4: SMART MATCHES ---
  Widget _buildSmartMatchesTab(MatchState state) {
    if (state.smartMatches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.auto_awesome_rounded,
        iconColor: const Color(0xFF10B981),
        title: 'હાલ કોઈ ભલામણો નથી (No Matches)',
        subtitle: 'તમારી પ્રોફાઇલ માહિતી અપડેટ કરો જેથી તમારા પરગણા અને શિક્ષણ અનુસાર વધુ સુસંગત મેળ મળી શકે.',
        actionLabel: 'પ્રોફાઇલ અપડેટ કરો (Update Profile)',
        onAction: () => context.push('/profile'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: state.smartMatches.length,
      itemBuilder: (context, index) {
        final item = state.smartMatches[index];
        final p = item.profile;

        return _buildCardWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCandidateTile(
                p,
                badgeText: '${item.matchScore}% મેળ (Match)',
                badgeColor: const Color(0xFFFFF1F2),
                badgeTextColor: const Color(0xFFE11D48),
                badgeBorderColor: const Color(0xFFFECDD3),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: item.matchReasons.map((r) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          r,
                          style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Divider(color: Color(0xFFF1F5F9), height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/candidate-profile-details?id=${p.id}', extra: p),
                      icon: const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF0056D2)),
                      label: const Text(
                        'પ્રોફાઇલ જુઓ (View)',
                        style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF8FAFC),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final res = await ref.read(matchProvider.notifier).sendInterest(p.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: res['success'] == true ? const Color(0xFF10B981) : Colors.red,
                              content: Text(res['message'] ?? 'વિનંતી મોકલાઈ (Interest Sent)'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.favorite_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'રસ દર્શાવો (Connect)',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- REUSABLE CARD CONTAINER ---
  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // --- CANDIDATE HEADER ROW ---
  Widget _buildCandidateTile(
    ProfileModel p, {
    required String badgeText,
    required Color badgeColor,
    Color? badgeTextColor,
    Color? badgeBorderColor,
  }) {
    final photo = p.fullPhotoUrl;
    final hasPhoto = photo != null && photo.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with golden border accent
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: hasPhoto
                ? Image.network(
                    photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallbackAvatar(p),
                  )
                : _fallbackAvatar(p),
          ),
        ),
        const SizedBox(width: 14),
        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      p.fullName.isNotEmpty ? p.fullName : 'ઉમેદવાર (Candidate)',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (p.isVerified == true) ...[
                    const SizedBox(width: 5),
                    const Icon(Icons.verified, color: Color(0xFF0056D2), size: 17),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      '${p.age != null ? "${p.age} વર્ષ • " : ""}${p.pargana.isNotEmpty ? "${p.pargana} પરગણા • " : ""}${p.district.isNotEmpty ? p.district : "ગુજરાત"}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (p.education.isNotEmpty || p.displayProfession.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.work_outline_rounded, size: 13, color: Color(0xFF0056D2)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        [if (p.education.isNotEmpty) p.education, if (p.displayProfession.isNotEmpty) p.displayProfession].join(' • '),
                        style: const TextStyle(color: Color(0xFF0056D2), fontSize: 11.5, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: badgeBorderColor ?? badgeColor, width: 0.8),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              color: badgeTextColor ?? badgeColor,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallbackAvatar(ProfileModel p) {
    final isFemale = p.gender.toLowerCase().contains('female');
    return Container(
      color: isFemale ? const Color(0xFFFCE7F3) : const Color(0xFFEFF6FF),
      child: Center(
        child: Icon(
          isFemale ? Icons.woman : Icons.man,
          color: isFemale ? const Color(0xFFDB2777) : const Color(0xFF2563EB),
          size: 34,
        ),
      ),
    );
  }

  // --- GENERIC EMPTY STATE FOR OTHER TABS ---
  Widget _buildEmptyState({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    iconColor.withValues(alpha: 0.15),
                    iconColor.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(color: iconColor.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Icon(icon, size: 52, color: iconColor),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.45),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.explore_rounded, size: 16, color: Colors.white),
                label: Text(
                  actionLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
