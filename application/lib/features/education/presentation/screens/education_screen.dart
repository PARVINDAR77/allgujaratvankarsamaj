import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';
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
              const SizedBox(height: 28),

              // 6. Community Footer
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
