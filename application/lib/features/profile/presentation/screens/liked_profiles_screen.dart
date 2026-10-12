import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/profile_model.dart';
import '../../providers/liked_profiles_provider.dart';

class LikedProfilesScreen extends ConsumerStatefulWidget {
  const LikedProfilesScreen({super.key});

  @override
  ConsumerState<LikedProfilesScreen> createState() => _LikedProfilesScreenState();
}

class _LikedProfilesScreenState extends ConsumerState<LikedProfilesScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Brides (કન્યાઓ), 2: Grooms (વરરાજાઓ)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(likedProfilesProvider.notifier).loadLikedProfiles();
    });
  }

  List<ProfileModel> _getFilteredProfiles(List<ProfileModel> allProfiles) {
    if (_selectedFilterIndex == 1) {
      return allProfiles.where((p) => p.isFemale).toList();
    } else if (_selectedFilterIndex == 2) {
      return allProfiles.where((p) => !p.isFemale).toList();
    }
    return allProfiles;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(likedProfilesProvider);
    final allProfiles = state.profiles;
    final totalCount = allProfiles.length;
    final bridesCount = allProfiles.where((p) => p.isFemale).length;
    final groomsCount = allProfiles.where((p) => !p.isFemale).length;
    final filteredProfiles = _getFilteredProfiles(allProfiles);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: const Icon(Icons.favorite_rounded, color: Color(0xFFE11D48), size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'પસંદ કરેલ પ્રોફાઈલ',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Text(
                        '$totalCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Shortlisted Matrimonial Profiles',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'રિફ્રેશ કરો (Refresh)',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF334155)),
            ),
            onPressed: () => ref.read(likedProfilesProvider.notifier).loadLikedProfiles(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Royal Community Header Banner
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ALL GUJARAT VANKAR SAMAJ',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '“એક સમાજ, એક વિચાર, એક પરિવાર” • પસંદ કરેલા સંબંધો',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Interactive Filter Bar (All / Brides / Grooms)
            if (allProfiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  children: [
                    _buildFilterTab(
                      title: 'બધા (All)',
                      count: totalCount,
                      isSelected: _selectedFilterIndex == 0,
                      onTap: () => setState(() => _selectedFilterIndex = 0),
                      activeColor: const Color(0xFF0F172A),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      title: '👧 કન્યાઓ',
                      count: bridesCount,
                      isSelected: _selectedFilterIndex == 1,
                      onTap: () => setState(() => _selectedFilterIndex = 1),
                      activeColor: const Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterTab(
                      title: '👦 વરરાજાઓ',
                      count: groomsCount,
                      isSelected: _selectedFilterIndex == 2,
                      onTap: () => setState(() => _selectedFilterIndex = 2),
                      activeColor: const Color(0xFF0056D2),
                    ),
                  ],
                ),
              ),

            // 3. Profiles List or Empty State
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFD4AF37),
                onRefresh: () => ref.read(likedProfilesProvider.notifier).loadLikedProfiles(),
                child: state.isLoading && allProfiles.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      )
                    : filteredProfiles.isEmpty
                        ? _buildEmptyState(context, isFiltered: _selectedFilterIndex != 0)
                        : _buildProfilesList(context, filteredProfiles),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FILTER TAB PILL ---
  Widget _buildFilterTab({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState(BuildContext context, {bool isFiltered = false}) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
                    ),
                    border: Border.all(color: const Color(0xFFFECDD3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFE11D48),
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  isFiltered ? 'આ કેટેગરીમાં કોઈ પ્રોફાઈલ નથી' : 'હજુ સુધી કોઈ પ્રોફાઈલ પસંદ કરેલ નથી',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isFiltered
                      ? 'કૃપા કરીને અન્ય કેટેગરી અથવા તમામ પસંદ કરેલી પ્રોફાઇલ્સ તપાસો.'
                      : 'કોઈપણ ઉમેદવારની પ્રોફાઈલ પર હાર્ટ (❤️) બટન દબાવીને તમે અહીં તમારી પસંદગી મુજબ યાદી બનાવી શકો છો.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    if (isFiltered) {
                      setState(() => _selectedFilterIndex = 0);
                    } else {
                      context.push('/search-results');
                    }
                  },
                  icon: Icon(isFiltered ? Icons.filter_alt_off_rounded : Icons.search_rounded, size: 18),
                  label: Text(
                    isFiltered ? 'તમામ પ્રોફાઇલ્સ જુઓ (Show All)' : 'નવા ઉમેદવારો શોધો (Browse Candidates)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- PROFILES LIST ---
  Widget _buildProfilesList(BuildContext context, List<ProfileModel> profiles) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return _buildLikedCard(context, profile);
      },
    );
  }

  // --- ELEVATED ROYAL CANDIDATE CARD ---
  Widget _buildLikedCard(BuildContext context, ProfileModel profile) {
    final isGirl = profile.isFemale;
    final employmentStr = profile.displayProfession;
    final locationStr = profile.displayLocation;
    final hasPhoto = profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Candidate Main Header Details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 68px Royal Medallion Avatar with Golden Bevel
                GestureDetector(
                  onTap: () => context.push('/candidate-profile-details', extra: profile),
                  child: Stack(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isGirl ? const Color(0xFFFCE4EC) : const Color(0xFFE8F4FD),
                          border: Border.all(
                            color: const Color(0xFFD4AF37),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: hasPhoto
                              ? Image.network(
                                  profile.fullPhotoUrl!,
                                  fit: BoxFit.cover,
                                  width: 68,
                                  height: 68,
                                  errorBuilder: (_, _, _) => _buildAvatarFallback(isGirl, profile.fullName),
                                )
                              : _buildAvatarFallback(isGirl, profile.fullName),
                        ),
                      ),
                      if (profile.isVerified == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF0056D2),
                              size: 19,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Candidate Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Red Heart Unlike Action
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              profile.fullName.isNotEmpty ? profile.fullName : 'User Member',
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFECDD3)),
                                ),
                                child: const Icon(Icons.favorite_rounded, color: Color(0xFFE11D48), size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Gender Pill Badge & Age/Marital status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: isGirl ? const Color(0xFFFCE4EC) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isGirl ? const Color(0xFFF48FB1) : const Color(0xFF93C5FD),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              isGirl ? '👧 કન્યા (Bride)' : '👦 વર (Groom)',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: isGirl ? const Color(0xFFBE185D) : const Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${profile.age != null ? "${profile.age} વર્ષ • " : ""}${profile.maritalStatus}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Sky Blue ID Capsule with Tap-to-Copy
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: profile.id));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('ID કોપી થયો: ${profile.id}'),
                              backgroundColor: const Color(0xFF0056D2),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F0FF),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF90CAF9), width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.copy_rounded, size: 10, color: Color(0xFF1976D2)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'ID: ${profile.id}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF0056D2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Education Row
                      if (profile.education.isNotEmpty && profile.education != 'Not Specified')
                        _buildInfoRow(Icons.school_outlined, profile.education),

                      // Profession Row
                      _buildInfoRow(
                        Icons.work_outline_rounded,
                        employmentStr.isEmpty ? 'વ્યવસાય દર્શાવેલ નથી' : employmentStr,
                      ),

                      // Location & Pargana Row
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        locationStr.isEmpty ? 'સ્થળ દર્શાવેલ નથી' : locationStr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Action Buttons Footer Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2)),
            ),
            child: Row(
              children: [
                // Remove Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 16),
                    label: const Text(
                      'દૂર કરો',
                      style: TextStyle(color: Color(0xFFE11D48), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F2),
                      side: const BorderSide(color: Color(0xFFFECDD3)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // View Full Profile Button
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0056D2), Color(0xFF1E40AF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0056D2).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/candidate-profile-details', extra: profile);
                      },
                      icon: const Icon(Icons.visibility_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'સંપૂર્ણ પ્રોફાઈલ જુઓ →',
                        style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE INFO ROW ---
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13.5, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), height: 1.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- CANDIDATE AVATAR FALLBACK ---
  Widget _buildAvatarFallback(bool isGirl, String name) {
    final trimmed = name.trim();
    final String initial = trimmed.isNotEmpty
        ? trimmed.characters.first.toUpperCase()
        : (isGirl ? 'B' : 'G');
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGirl
              ? const [Color(0xFFFCE4EC), Color(0xFFF8BBD0)]
              : const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: isGirl ? const Color(0xFFAD1457) : const Color(0xFF0D47A1),
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
