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
        builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
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
      backgroundColor: const Color(0xFF040A18),
      appBar: AppBar(
        title: const Text(
          'મેળ અને સંબંધો (Matches & Interests)',
          style: TextStyle(color: Color(0xFFFFD700), fontSize: 17, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF041126),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFD700), size: 20),
            tooltip: 'રીફ્રેશ કરો (Refresh)',
            onPressed: () => ref.read(matchProvider.notifier).loadAll(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: const Color(0xFF020712),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFFFD700),
              indicatorWeight: 3,
              labelColor: const Color(0xFFFFD700),
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              tabAlignment: TabAlignment.start,
              tabs: [
                _buildTab('પરસ્પર મેળ (Mutual)', matchState.mutualInterests.length, const Color(0xFF10B981)),
                _buildTab('આવેલી (Received)', matchState.receivedInterests.length, const Color(0xFFF59E0B)),
                _buildTab('મોકલેલી (Sent)', matchState.sentInterests.length, const Color(0xFF3B82F6)),
                _buildTab('સ્માર્ટ મેળ (Smart)', matchState.smartMatches.length, const Color(0xFFEC4899)),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFFD700),
          backgroundColor: const Color(0xFF041126),
          onRefresh: () => ref.read(matchProvider.notifier).loadAll(),
          child: matchState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD700)),
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

  Widget _buildTab(String title, int count, Color badgeColor) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- TAB 1: MUTUAL MATCHES ---
  Widget _buildMutualTab(MatchState state) {
    if (state.mutualInterests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite,
        iconColor: const Color(0xFFEC4899),
        title: 'હજી સુધી કોઈ પરસ્પર મેળ નથી',
        subtitle: 'જ્યારે તમે અને અન્ય ઉમેદવાર એકબીજાની વિનંતી સ્વીકારો ત્યારે અહીં સંબંધ દેખાશે.',
        actionLabel: 'સુસંગત મેળ જુઓ (Explore Smart Matches)',
        onAction: () => _tabController.animateTo(3),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.mutualInterests.length,
      itemBuilder: (context, index) {
        final item = state.mutualInterests[index];
        final p = item.profile;
        if (p == null) return const SizedBox.shrink();

        return _buildCardWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCandidateTile(p, badgeText: 'પરસ્પર જોડાયેલા (Connected)', badgeColor: const Color(0xFF10B981)),
              const Divider(color: Color(0xFF1E293B), height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/candidate-profile-details?id=${p.id}', extra: p),
                      icon: const Icon(Icons.person, size: 15, color: Color(0xFFFFD700)),
                      label: const Text('પ્રોફાઇલ જુઓ (View)', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFD700)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openChat(context, p, item.conversationId),
                      icon: const Icon(Icons.chat, size: 15, color: Colors.white),
                      label: const Text('વાતચીત કરો (Chat)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  // --- TAB 2: RECEIVED REQUESTS ---
  Widget _buildReceivedTab(MatchState state) {
    if (state.receivedInterests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mark_email_read_outlined,
        iconColor: const Color(0xFFF59E0B),
        title: 'કોઈ નવી વિનંતી નથી (No Requests)',
        subtitle: 'જ્યારે કોઈ સભ્ય તમને કનેક્શન વિનંતી મોકલશે ત્યારે અહીં દર્શાવવામાં આવશે.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.receivedInterests.length,
      itemBuilder: (context, index) {
        final item = state.receivedInterests[index];
        final p = item.profile;
        if (p == null) return const SizedBox.shrink();

        return _buildCardWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCandidateTile(p, badgeText: 'આવેલી વિનંતી (Received)', badgeColor: const Color(0xFFF59E0B)),
              const Divider(color: Color(0xFF1E293B), height: 16),
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
                        side: const BorderSide(color: Color(0xFF64748B)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('નકારો (Decline)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
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
                      icon: const Icon(Icons.check_circle, size: 15, color: Colors.white),
                      label: const Text('સ્વીકારો (Accept)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        icon: Icons.send_outlined,
        iconColor: const Color(0xFF3B82F6),
        title: 'તમે કોઈ વિનંતી મોકલી નથી',
        subtitle: 'તમને ગમતા ઉમેદવારોને કનેક્શન વિનંતી મોકલો અને સંબંધ આગળ વધારો.',
        actionLabel: 'ઉમેદવારો શોધો (Find Candidates)',
        onAction: () => context.go('/home'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
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
                badgeText: isAccepted ? 'સ્વીકારાઈ (Accepted)' : 'ચકાસણી હેઠળ (Pending)',
                badgeColor: isAccepted ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
              ),
              const Divider(color: Color(0xFF1E293B), height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/candidate-profile-details?id=${p.id}', extra: p),
                      icon: const Icon(Icons.person, size: 15, color: Color(0xFFFFD700)),
                      label: const Text('પ્રોફાઇલ જુઓ (View)', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFD700)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  if (isAccepted) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openChat(context, p, item.conversationId),
                        icon: const Icon(Icons.chat, size: 15, color: Colors.white),
                        label: const Text('વાતચીત કરો (Chat)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056D2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        icon: Icons.auto_awesome,
        iconColor: const Color(0xFFEC4899),
        title: 'હાલ કોઈ ભલામણો નથી (No Matches)',
        subtitle: 'તમારી પ્રોફાઇલ માહિતી અપડેટ કરો જેથી વધુ સુસંગત મેળ મળી શકે.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
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
                badgeText: '${item.matchScore}% સુમેળ (Match)',
                badgeColor: const Color(0xFFEC4899),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.matchReasons.map((r) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF334155), width: 0.8),
                    ),
                    child: Text(
                      '• $r',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  );
                }).toList(),
              ),
              const Divider(color: Color(0xFF1E293B), height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/candidate-profile-details?id=${p.id}', extra: p),
                      icon: const Icon(Icons.person, size: 15, color: Color(0xFFFFD700)),
                      label: const Text('પ્રોફાઇલ જુઓ (View)', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFD700)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      icon: const Icon(Icons.favorite, size: 15, color: Colors.white),
                      label: const Text('રસ દર્શાવો (Connect)', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  // Helper Card Builder
  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCandidateTile(ProfileModel p, {required String badgeText, required Color badgeColor}) {
    final photo = p.fullPhotoUrl;
    final hasPhoto = photo != null && photo.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
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
        const SizedBox(width: 12),
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
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (p.isVerified == true) ...[
                    const SizedBox(width: 5),
                    const Icon(Icons.verified, color: Color(0xFFFFD700), size: 16),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '${p.age != null ? "${p.age} વર્ષ • " : ""}${p.displayGender} • ${p.district.isNotEmpty ? p.district : "ગુજરાત"}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              if (p.education.isNotEmpty || p.displayProfession.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  [if (p.education.isNotEmpty) p.education, if (p.displayProfession.isNotEmpty) p.displayProfession].join(' • '),
                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: badgeColor, width: 0.8),
          ),
          child: Text(
            badgeText,
            style: TextStyle(color: badgeColor, fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _fallbackAvatar(ProfileModel p) {
    final isFemale = p.gender.toLowerCase().contains('female');
    return Container(
      color: isFemale ? const Color(0xFF831843) : const Color(0xFF1E3A8A),
      child: Center(
        child: Icon(
          isFemale ? Icons.woman : Icons.man,
          color: Colors.white70,
          size: 32,
        ),
      ),
    );
  }

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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, size: 54, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.explore, size: 16, color: Colors.black87),
                label: Text(
                  actionLabel,
                  style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
