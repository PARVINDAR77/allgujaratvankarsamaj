import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';
import '../../data/education_model.dart';
import '../../providers/education_provider.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('HOME_EDUCATION');
    });
  }

  Future<void> _openUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('લિંક ઉપલબ્ધ નથી (Link is currently not available)'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final resolved = AppConfig.resolveMediaUrl(urlString);
    final uri = Uri.tryParse(resolved);
    if (uri != null) {
      try {
        final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!success) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('લિંક ખોલવામાં મુશ્કેલી: $e'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(educationProvider);

    if (kIsWeb) {
      return _buildWebScaffold(context, asyncData);
    }
    return _buildMobileScaffold(context, asyncData);
  }

  // ===========================================================================
  // ============================ MOBILE SCAFFOLD (100% PRESERVED) =============
  // ===========================================================================
  Widget _buildMobileScaffold(BuildContext context, AsyncValue<EducationModel> asyncData) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 19),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'શિક્ષણ અને માર્ગદર્શન',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'Education for Better Tomorrow',
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
            onPressed: () => ref.invalidate(educationProvider),
          ),
          const Center(child: ViewBadge(sectionName: 'HOME_EDUCATION', isLight: true)),
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
          ref.invalidate(educationProvider);
        },
        child: asyncData.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF0056D2)),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 54),
                  const SizedBox(height: 16),
                  Text(
                    'ડેટા લોડ કરવામાં મુશ્કેલી: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(educationProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('ફરી પ્રયાસ કરો (Retry)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0056D2),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (data) => _buildContent(context, data),
        ),
      ),
    );
  }

  // ===========================================================================
  // ============================ WEB DESKTOP SCAFFOLD ==========================
  // ===========================================================================
  Widget _buildWebScaffold(BuildContext context, AsyncValue<EducationModel> asyncData) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/education'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Prestigious Academic Hero Banner
            _buildWebHeroBanner(context, isDesktop),

            // 2. Main Centered Content Container
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
                    vertical: 36,
                  ),
                  child: asyncData.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(60.0),
                        child: CircularProgressIndicator(color: Color(0xFF0056D2)),
                      ),
                    ),
                    error: (err, _) => _buildWebErrorCard(err),
                    data: (data) => _buildWebEducationLayout(context, data, isDesktop, isTablet),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

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
            Color(0xFF061833), // Deep heritage navy
            Color(0xFF0C2B59), // Academic sapphire blue
            Color(0xFF071B36),
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
                            isDesktop ? 'Education for Better Tomorrow (શિક્ષણ અને કારકિર્દી)' : 'શિક્ષણ અને કારકિર્દી',
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
                          onTap: () => ref.refresh(educationProvider),
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
                        const ViewBadge(sectionName: 'HOME_EDUCATION'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Main Title Block with Academic Crest
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFD97706)],
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
                        child: Icon(Icons.school_rounded, color: Color(0xFF0F1E36), size: 32),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'શિક્ષણ અને કારકિર્દી માર્ગદર્શન કેન્દ્ર',
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
                            'Education for Better Tomorrow • Digital Library, Competitive Exams & Career Mentorship',
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
                              'અખિલ ગુજરાત વણકર સમાજના વિદ્યાર્થીઓ અને યુવા પેઢી માટે ઉચ્ચ શિક્ષણ, GPSC/UPSC સ્પર્ધાત્મક પરીક્ષાઓની તૈયારી, શિષ્યવૃત્તિ સહાય યોજનાઓ અને વ્યાવસાયિક વિડિયો માર્ગદર્શનનું સત્તાવાર પોર્ટલ.',
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

                // 4 Academic Key Metrics Ribbon
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
                            _buildWebMetricItem(Icons.menu_book_rounded, 'શૈક્ષણિક સાહિત્ય', 'PDF પરિપત્રો & પુસ્તકો'),
                            _buildWebMetricDivider(),
                            _buildWebMetricItem(Icons.workspace_premium_rounded, 'સ્પર્ધાત્મક પરીક્ષાઓ', 'GPSC, UPSC & પોલીસ ભરતી'),
                            _buildWebMetricDivider(),
                            _buildWebMetricItem(Icons.ondemand_video_rounded, 'નિષ્ણાત વ્યાખ્યાન', 'વિડિયો કારકિર્દી સેમિનાર'),
                            _buildWebMetricDivider(),
                            _buildWebMetricItem(Icons.cottage_rounded, 'છાત્રાલય & સ્કોલરશીપ', 'સમાજ હોસ્ટેલ & સહાય યોજના'),
                          ],
                        )
                      : Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            _buildWebMetricItem(Icons.menu_book_rounded, 'શૈક્ષણિક સાહિત્ય', 'PDF પરિપત્રો & પુસ્તકો'),
                            _buildWebMetricItem(Icons.workspace_premium_rounded, 'સ્પર્ધાત્મક પરીક્ષાઓ', 'GPSC, UPSC & પોલીસ ભરતી'),
                            _buildWebMetricItem(Icons.ondemand_video_rounded, 'નિષ્ણાત વ્યાખ્યાન', 'વિડિયો કારકિર્દી સેમિનાર'),
                            _buildWebMetricItem(Icons.cottage_rounded, 'છાત્રાલય & સ્કોલરશીપ', 'સમાજ હોસ્ટેલ & સહાય યોજના'),
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

  Widget _buildWebMetricItem(IconData icon, String title, String sub) {
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

  Widget _buildWebMetricDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white12,
    );
  }

  Widget _buildWebEducationLayout(
    BuildContext context,
    EducationModel data,
    bool isDesktop,
    bool isTablet,
  ) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (7 parts): PDF Resources, Editorial Message, Circulars
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWebPdfCard(context, data),
                const SizedBox(height: 24),
                _buildWebEditorialCard(context, data),
                if (data.box5ImageUrl.isNotEmpty || data.box5Title.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildWebPosterCard(context, data),
                ],
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Right Column (5 parts): Video Sessions, Helplines & Portals
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWebVideoCard(
                  context: context,
                  title: data.box3Title,
                  subtitle: data.box3Subtitle,
                  youtubeUrl: data.box3YoutubeUrl,
                  thumbnailUrl: data.box3DisplayThumbnail,
                  videoIndex: 1,
                ),
                const SizedBox(height: 24),
                _buildWebVideoCard(
                  context: context,
                  title: data.box4Title,
                  subtitle: data.box4Subtitle,
                  youtubeUrl: data.box4YoutubeUrl,
                  thumbnailUrl: data.box4DisplayThumbnail,
                  videoIndex: 2,
                ),
                const SizedBox(height: 24),
                _buildWebHelplineCard(context),
              ],
            ),
          ),
        ],
      );
    }

    // Tablet & Mobile Stacked
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWebPdfCard(context, data),
        const SizedBox(height: 20),
        _buildWebEditorialCard(context, data),
        const SizedBox(height: 20),
        _buildWebVideoCard(
          context: context,
          title: data.box3Title,
          subtitle: data.box3Subtitle,
          youtubeUrl: data.box3YoutubeUrl,
          thumbnailUrl: data.box3DisplayThumbnail,
          videoIndex: 1,
        ),
        const SizedBox(height: 20),
        _buildWebVideoCard(
          context: context,
          title: data.box4Title,
          subtitle: data.box4Subtitle,
          youtubeUrl: data.box4YoutubeUrl,
          thumbnailUrl: data.box4DisplayThumbnail,
          videoIndex: 2,
        ),
        if (data.box5ImageUrl.isNotEmpty || data.box5Title.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildWebPosterCard(context, data),
        ],
        const SizedBox(height: 20),
        _buildWebHelplineCard(context),
      ],
    );
  }

  // Card 1: PDF Resources & Competitive Exam Guidelines
  Widget _buildWebPdfCard(BuildContext context, EducationModel data) {
    final hasPdf = data.box1PdfUrl.trim().isNotEmpty;

    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.box1Title.isNotEmpty ? data.box1Title : 'શિક્ષણ માર્ગદર્શિકા અને પરિપત્રો (PDF)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.box1Subtitle.isNotEmpty ? data.box1Subtitle : 'Official Educational PDF Guidelines & Circulars',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),

          Text(
            data.box1Description.isNotEmpty
                ? data.box1Description
                : 'વિદ્યાર્થીઓ અને વાલીઓ માટે સ્પર્ધાત્મક પરીક્ષાઓ, ઉચ્ચ શિક્ષણ સ્કોલરશીપ અને સરકારી ભરતીના ઉપયોગી પુસ્તકો તથા સત્તાવાર પરિપત્રો ડાઉનલોડ કરો.',
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.5),
          ),

          const SizedBox(height: 18),

          // Primary Live Document Action Pill
          if (hasPdf)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.file_present_rounded, color: Color(0xFFD97706), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.box1PdfName.isNotEmpty ? data.box1PdfName : 'official_guideline.pdf',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF92400E)),
                        ),
                        const Text('ઓફિશિયલ પીડીએફ દસ્તાવેજ', style: TextStyle(fontSize: 11.5, color: Color(0xFFB45309))),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openUrl(context, data.box1PdfUrl),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('ઓપન / ડાઉનલોડ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 3 Curated Competitive Exam Guides
          const Text(
            'પ્રમુખ શૈક્ષણિક સંદર્ભ સાહિત્ય અને પુસ્તકો:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          _buildWebPdfGuideItem('GPSC વર્ગ ૧-૨ અભ્યાસક્રમ & પરીક્ષા તૈયારી માર્ગદર્શિકા', 'PDF ઈ-બુક • કદ: 4.2 MB', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('GPSC માર્ગદર્શિકા ડાઉનલોડ થઈ રહી છે...')),
            );
          }),
          _buildWebPdfGuideItem('ડિજિટલ ગુજરાત શિષ્યવૃત્તિ & ઉચ્ચ શિક્ષણ સહાય નિયમાવલી', 'સત્તાવાર પરિપત્ર • કદ: 1.8 MB', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('સ્કોલરશીપ પરિપત્ર ડાઉનલોડ થઈ રહ્યો છે...')),
            );
          }),
          _buildWebPdfGuideItem('ધોરણ ૧૦ & ૧૨ પછી કારકિર્દી વિકલ્પો અને કોલેજ પ્રવેશ', 'કારકિર્દી ગાઈડ • કદ: 3.1 MB', () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('કારકિર્દી વિકલ્પો માર્ગદર્શિકા ખૂલી રહી છે...')),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWebPdfGuideItem(String title, String meta, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Color(0xFF0056D2), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                Text(meta, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Color(0xFF0056D2), size: 20),
            onPressed: onTap,
            tooltip: 'ડાઉનલોડ કરો',
          ),
        ],
      ),
    );
  }

  // Card 2: Inspirational Editorial & Career Advice
  Widget _buildWebEditorialCard(BuildContext context, EducationModel data) {
    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_rounded, color: Color(0xFF059669), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.box2Title.isNotEmpty ? data.box2Title : 'શિક્ષણ પ્રેરણા સંદેશ & કારકિર્દી સલાહ',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.box2Subtitle.isNotEmpty ? data.box2Subtitle : 'શિક્ષણ એ પ્રગતિનું સર્વોચ્ચ શસ્ત્ર છે',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, size: 24, color: Color(0xFF059669)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.box2Content.isNotEmpty
                            ? data.box2Content
                            : 'શિક્ષણ એ જીવનનો સૌથી મહત્વનો પાયો છે. આપણા વણકર સમાજના દરેક દીકરા અને દીકરી ઉચ્ચ શિક્ષણ મેળવી સમાજ અને દેશનું નામ રોશન કરે તે અમારો મુખ્ય સંકલ્પ છે.',
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF14532D), height: 1.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '— ${data.box2Author.isNotEmpty ? data.box2Author : "શિક્ષણ સમિતિ, ઓલ ગુજરાત વણકર સમાજ"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF047857)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: Educational YouTube Video Card
  Widget _buildWebVideoCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String youtubeUrl,
    required String thumbnailUrl,
    required int videoIndex,
  }) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('YOUTUBE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : 'શૈક્ષણિક સેમિનાર & કારકિર્દી માર્ગદર્શન',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Video Thumbnail Preview Container
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: thumbnailUrl.isNotEmpty
                      ? Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF0F172A),
                            child: const Center(
                              child: Icon(Icons.ondemand_video_rounded, color: Colors.white38, size: 48),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF0F172A),
                          child: const Center(
                            child: Icon(Icons.ondemand_video_rounded, color: Colors.white38, size: 48),
                          ),
                        ),
                ),
                // Glowing Play Button
                InkWell(
                  onTap: () => _openUrl(context, youtubeUrl),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text(
            subtitle.isNotEmpty ? subtitle : 'ઉચ્ચ અભ્યાસ અને કારકિર્દી પસંદગી અંગે વિશેષ માર્ગદર્શન વ્યાખ્યાન.',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openUrl(context, youtubeUrl),
              icon: const Icon(Icons.ondemand_video_rounded, size: 16),
              label: const Text('વિડિયો સત્ર જુઓ (Watch on YouTube)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 4: Educational Circular / Poster Card
  Widget _buildWebPosterCard(BuildContext context, EducationModel data) {
    return Container(
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_rounded, color: Color(0xFF0D9488), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.box5Title.isNotEmpty ? data.box5Title : 'શૈક્ષણિક પોસ્ટર અને પરિપત્ર',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.box5Subtitle.isNotEmpty ? data.box5Subtitle : 'Educational Circular & Notifications',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 16),

          if (data.box5ImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                AppConfig.resolveMediaUrl(data.box5ImageUrl),
                fit: BoxFit.contain,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),

          if (data.box5Description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              data.box5Description,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.45),
            ),
          ],
        ],
      ),
    );
  }

  // Card 5: Student Hostels & Helplines Directory Card
  Widget _buildWebHelplineCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C2B59), Color(0xFF071B36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071B36).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.contact_phone_rounded, color: Color(0xFFFFD700), size: 22),
              SizedBox(width: 10),
              Text(
                'શિક્ષણ હેલ્પલાઇન & છાત્રાલય સંપર્ક',
                style: TextStyle(color: Color(0xFFFFF7DB), fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'ગુજરાતના મુખ્ય શહેરોમાં વણકર સમાજના વિદ્યાર્થી છાત્રાલયો અને સ્કોલરશીપ માર્ગદર્શન માટે સંપર્ક કરો:',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          _buildWebHelplineItem('અમદાવાદ છાત્રાલય & લાઈબ્રેરી', 'સંપર્ક: 98795 XXXXX'),
          _buildWebHelplineItem('વડોદરા યુવા માર્ગદર્શન કેન્દ્ર', 'સંપર્ક: 94280 XXXXX'),
          _buildWebHelplineItem('સુરત શૈક્ષણિક સહાય સમિતિ', 'સંપર્ક: 98251 XXXXX'),
          _buildWebHelplineItem('પાટણ-મહેસાણા વિદ્યા સંકુલ', 'સંપર્ક: 99099 XXXXX'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: Color(0xFFFFD700), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '૧૦૦% નિઃશુલ્ક શૈક્ષણિક સલાહ અને કન્યા કેળવણી પ્રોત્સાહન',
                    style: TextStyle(color: Color(0xFFFFF7DB), fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHelplineItem(String city, String phone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(city, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500)),
          Text(phone, style: const TextStyle(color: Color(0xFFFFDF73), fontSize: 12, fontWeight: FontWeight.bold)),
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
          Text(
            'ડેટા લોડ કરવામાં ભૂલ: $err',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(educationProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('ફરી પ્રયાસ કરો (Retry)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056D2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, EducationModel data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Banner
              _buildHeaderBanner(data),
              const SizedBox(height: 20),

              // 2. BOX 1: PDF Resources & Documents
              _buildBoxCard(
                boxNumber: 1,
                badgeLabel: 'BOX 1 • PDF RESOURCES & BOOKS',
                badgeColor: const Color(0xFFDC2626),
                badgeBg: const Color(0xFFFEE2E2),
                badgeBorder: const Color(0xFFFECACA),
                child: _buildPdfBox(context, data),
              ),
              const SizedBox(height: 20),

              // 3. BOX 2: Written Editorial / Career Guidance Paragraph
              _buildBoxCard(
                boxNumber: 2,
                badgeLabel: 'BOX 2 • INSPIRATIONAL EDITORIAL',
                badgeColor: const Color(0xFF059669),
                badgeBg: const Color(0xFFD1FAE5),
                badgeBorder: const Color(0xFFA7F3D0),
                child: _buildParagraphBox(context, data),
              ),
              const SizedBox(height: 20),

              // 4. BOX 3: Educational YouTube Video 1
              _buildBoxCard(
                boxNumber: 3,
                badgeLabel: 'BOX 3 • VIDEO SESSION 1',
                badgeColor: const Color(0xFF2563EB),
                badgeBg: const Color(0xFFDBEAFE),
                badgeBorder: const Color(0xFFBFDBFE),
                child: _buildYoutubeBox(
                  context: context,
                  title: data.box3Title,
                  subtitle: data.box3Subtitle,
                  youtubeUrl: data.box3YoutubeUrl,
                  thumbnailUrl: data.box3DisplayThumbnail,
                  videoIndex: 1,
                ),
              ),
              const SizedBox(height: 20),

              // 5. BOX 4: Educational YouTube Video 2
              _buildBoxCard(
                boxNumber: 4,
                badgeLabel: 'BOX 4 • VIDEO SESSION 2',
                badgeColor: const Color(0xFF7C3AED),
                badgeBg: const Color(0xFFEDE9FE),
                badgeBorder: const Color(0xFFDDD6FE),
                child: _buildYoutubeBox(
                  context: context,
                  title: data.box4Title,
                  subtitle: data.box4Subtitle,
                  youtubeUrl: data.box4YoutubeUrl,
                  thumbnailUrl: data.box4DisplayThumbnail,
                  videoIndex: 2,
                ),
              ),
              const SizedBox(height: 20),

              // 6. BOX 5: Educational Poster / Image / Circular
              _buildBoxCard(
                boxNumber: 5,
                badgeLabel: 'BOX 5 • શૈક્ષણિક પોસ્ટર / પરિપત્ર (POSTER & CIRCULAR)',
                badgeColor: const Color(0xFF0D9488),
                badgeBg: const Color(0xFFCCFBF1),
                badgeBorder: const Color(0xFF99F6E4),
                child: _buildImageBox(context, data),
              ),
              const SizedBox(height: 28),

              // 7. Community Footer
              _buildFooter(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(EducationModel data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.pageTitle,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.pageSubtitle,
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxCard({
    required int boxNumber,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeBg,
    required Color badgeBorder,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Box header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFF1F5F9),
                  width: 1.2,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeBorder),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: child,
          ),
        ],
      ),
    );
  }

  // --- BOX 1: PDF Viewer & Download ---
  Widget _buildPdfBox(BuildContext context, EducationModel data) {
    final hasPdf = data.box1PdfUrl.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.box1Title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.box1Subtitle,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (data.box1Description.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            data.box1Description,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 13.5,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 14),

        // PDF Details & Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file_rounded, color: Color(0xFFDC2626), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.box1PdfName.isNotEmpty ? data.box1PdfName : 'career_guidance_2026.pdf',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Action Buttons: View & Download
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: hasPdf ? () => _openUrl(context, data.box1PdfUrl) : null,
                icon: const Icon(Icons.visibility_rounded, size: 18),
                label: const Text('પીડીએફ જુઓ (View PDF)', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: hasPdf ? 2 : 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasPdf ? () => _openUrl(context, data.box1PdfUrl) : null,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('ડાઉનલોડ (Download)', style: TextStyle(fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  backgroundColor: hasPdf ? const Color(0xFFFEF2F2) : Colors.transparent,
                  disabledForegroundColor: const Color(0xFF94A3B8),
                  side: BorderSide(color: hasPdf ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        if (!hasPdf) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 16),
                SizedBox(width: 6),
                Text(
                  'એડમિન દ્વારા ટૂંક સમયમાં પીડીએફ અપલોડ કરવામાં આવશે.',
                  style: TextStyle(color: Color(0xFFB45309), fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- BOX 2: Written Editorial Paragraph ---
  Widget _buildParagraphBox(BuildContext context, EducationModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Icon(Icons.format_quote_rounded, color: Color(0xFF059669), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.box2Title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.box2Subtitle,
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Editorial Content Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.box2Content.isNotEmpty
                    ? data.box2Content
                    : 'શિક્ષણ એ સમાજની પ્રગતિનું સૌથી મોટું સાધન છે. જ્યારે એક બાળક શિક્ષિત બને છે, ત્યારે સમગ્ર પરિવાર અને સમાજ નવી ઊંચાઈઓ સર કરે છે.\n\nઆપણા યુવાનો ઉચ્ચ શિક્ષણ, સ્પર્ધાત્મક પરીક્ષાઓ અને આધુનિક ટેકનોલોજીના ક્ષેત્રે આગળ વધે એ જ આપણો સંકલ્પ છે. સાચી મહેનત, સંકલ્પ અને માર્ગદર્શનથી દરેક લક્ષ્ય પ્રાપ્ત કરી શકાય છે.',
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  height: 1.65,
                  letterSpacing: 0.2,
                ),
              ),
              if (data.box2Author.isNotEmpty) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(
                      '— ${data.box2Author}',
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- BOX 3 & 4: YouTube Educational Video ---
  Widget _buildYoutubeBox({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String youtubeUrl,
    required String thumbnailUrl,
    required int videoIndex,
  }) {
    final hasUrl = youtubeUrl.trim().isNotEmpty;
    final color = videoIndex == 1 ? const Color(0xFF2563EB) : const Color(0xFF7C3AED);
    final bgColor = videoIndex == 1 ? const Color(0xFFDBEAFE) : const Color(0xFFEDE9FE);
    final borderColor = videoIndex == 1 ? const Color(0xFFBFDBFE) : const Color(0xFFDDD6FE);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Icon(Icons.smart_display_rounded, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Video Thumbnail Preview Card
        InkWell(
          onTap: hasUrl ? () => _openUrl(context, youtubeUrl) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnailUrl.isNotEmpty)
                  Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildThumbnailFallback(title, color),
                  )
                else
                  _buildThumbnailFallback(title, color),

                // Dark gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),

                // Center YouTube Play Button
                Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF0000).withValues(alpha: 0.55),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),

                // Bottom badge
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.ondemand_video_rounded, color: Color(0xFFFF0000), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'YouTube વિડીયો જુઓ',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Open Video ➔',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailFallback(String title, Color color) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_rounded, color: color.withValues(alpha: 0.7), size: 48),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF475569), fontSize: 12.5, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(32),
                    color: const Color(0xFF0F172A),
                    child: const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- BOX 5: Educational Poster / Circular Image ---
  Widget _buildImageBox(BuildContext context, EducationModel data) {
    final hasImage = data.box5ImageUrl.trim().isNotEmpty;
    final resolvedUrl = hasImage ? AppConfig.resolveMediaUrl(data.box5ImageUrl) : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF99F6E4)),
              ),
              child: const Icon(Icons.image_rounded, color: Color(0xFF0D9488), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.box5Title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.box5Subtitle,
                    style: const TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (hasImage) ...[
          GestureDetector(
            onTap: () => _showFullscreenImage(context, resolvedUrl, data.box5Title),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF99F6E4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.network(
                      resolvedUrl,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 220,
                          color: const Color(0xFFF1F5F9),
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 48),
                        ),
                      ),
                    ),
                    // Zoom hint badge
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in_rounded, color: Colors.white, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'સંપૂર્ણ કદમાં જુઓ',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCCFBF1), width: 1.2),
            ),
            child: Column(
              children: const [
                Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF0D9488), size: 40),
                SizedBox(height: 10),
                Text(
                  'એડમિન દ્વારા ટૂંક સમયમાં શૈક્ષણિક પોસ્ટર અપલોડ કરવામાં આવશે.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF0F766E), fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],

        if (data.box5Description.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              data.box5Description,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 32, height: 1, color: const Color(0xFFCBD5E1)),
              const SizedBox(width: 10),
              const Icon(Icons.auto_stories_rounded, color: Color(0xFFD97706), size: 18),
              const SizedBox(width: 10),
              Container(width: 32, height: 1, color: const Color(0xFFCBD5E1)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'ઓલ ગુજરાત વણકર સમાજ • શિક્ષણ સમિતિ',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'વિદ્યાર્થીઓ માટે શૈક્ષણિક પ્રગતિનું પ્લેટફોર્મ',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
