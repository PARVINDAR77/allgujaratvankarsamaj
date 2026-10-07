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
          backgroundColor: Color(0xFFC62828),
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
              backgroundColor: const Color(0xFFC62828),
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
      backgroundColor: const Color(0xFF041126),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061224),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37)),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'શિક્ષણ અને માર્ગદર્શન',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'Education for Better Tomorrow',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4AF37)),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(educationProvider),
          ),
          const Center(child: ViewBadge(sectionName: 'HOME_EDUCATION')),
          const SizedBox(width: 14),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFD4AF37).withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF061224),
        onRefresh: () async {
          ref.invalidate(educationProvider);
        },
        child: asyncData.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 54),
                  const SizedBox(height: 16),
                  Text(
                    'ડેટા લોડ કરવામાં મુશ્કેલી: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(educationProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('ફરી પ્રયાસ કરો (Retry)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF041126),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
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
              const SizedBox(height: 24),

              // 2. BOX 1: PDF Resources & Documents
              _buildBoxCard(
                boxNumber: 1,
                badgeLabel: 'BOX 1 • PDF RESOURCES & BOOKS',
                badgeColor: const Color(0xFFE53935),
                child: _buildPdfBox(context, data),
              ),
              const SizedBox(height: 22),

              // 3. BOX 2: Written Editorial / Career Guidance Paragraph
              _buildBoxCard(
                boxNumber: 2,
                badgeLabel: 'BOX 2 • INSPIRATIONAL EDITORIAL',
                badgeColor: const Color(0xFF10B981),
                child: _buildParagraphBox(context, data),
              ),
              const SizedBox(height: 22),

              // 4. BOX 3: Educational YouTube Video 1
              _buildBoxCard(
                boxNumber: 3,
                badgeLabel: 'BOX 3 • VIDEO SESSION 1',
                badgeColor: const Color(0xFF3B82F6),
                child: _buildYoutubeBox(
                  context: context,
                  title: data.box3Title,
                  subtitle: data.box3Subtitle,
                  youtubeUrl: data.box3YoutubeUrl,
                  thumbnailUrl: data.box3DisplayThumbnail,
                  videoIndex: 1,
                ),
              ),
              const SizedBox(height: 22),

              // 5. BOX 4: Educational YouTube Video 2
              _buildBoxCard(
                boxNumber: 4,
                badgeLabel: 'BOX 4 • VIDEO SESSION 2',
                badgeColor: const Color(0xFF8B5CF6),
                child: _buildYoutubeBox(
                  context: context,
                  title: data.box4Title,
                  subtitle: data.box4Subtitle,
                  youtubeUrl: data.box4YoutubeUrl,
                  thumbnailUrl: data.box4DisplayThumbnail,
                  videoIndex: 2,
                ),
              ),
              const SizedBox(height: 32),

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F244A),
            Color(0xFF07152B),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37), Color(0xFF8C6D15)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF041126),
              size: 32,
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
                    color: Color(0xFFFFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.pageSubtitle,
                  style: const TextStyle(
                    color: Color(0xFFF3E5AB),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF081730),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.32),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
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
            decoration: BoxDecoration(
              color: const Color(0xFF051024),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10.5,
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
                color: const Color(0xFFE53935).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE53935).withOpacity(0.35)),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF5350), size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.box1Title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.box1Subtitle,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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
              color: Color(0xFFCBD5E1),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
        const SizedBox(height: 14),

        // PDF Details & Buttons
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF040E1E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              const Icon(Icons.file_present_rounded, color: Color(0xFF94A3B8), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.box1PdfName.isNotEmpty ? data.box1PdfName : 'Career_Guidance_Document.pdf',
                  style: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12.5,
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
                label: const Text('પીડીએફ જુઓ (View PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: const Color(0xFF041126),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasPdf ? () => _openUrl(context, data.box1PdfUrl) : null,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('ડાઉનલોડ (Download)', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        if (!hasPdf) ...[
          const SizedBox(height: 8),
          const Text(
            '⚠️ એડમિન દ્વારા ટૂંક સમયમાં પીડીએફ અપલોડ કરવામાં આવશે.',
            style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11.5, fontStyle: FontStyle.italic),
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
                color: const Color(0xFF10B981).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35)),
              ),
              child: const Icon(Icons.format_quote_rounded, color: Color(0xFF34D399), size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.box2Title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.box2Subtitle,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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
            color: const Color(0xFF040E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.box2Content.isNotEmpty
                    ? data.box2Content
                    : 'શિક્ષણ એ સમાજની પ્રગતિનું સૌથી મોટું સાધન છે. જ્યારે એક બાળક શિક્ષિત બને છે, ત્યારે સમગ્ર પરિવાર અને સમાજ નવી ઊંચાઈઓ સર કરે છે.\n\nઆપણા યુવાનો ઉચ્ચ શિક્ષણ, સ્પર્ધાત્મક પરીક્ષાઓ અને આધુનિક ટેકનોલોજીના ક્ષેત્રે આગળ વધે એ જ આપણો સંકલ્પ છે. સાચી મહેનત, સંકલ્પ અને માર્ગદર્શનથી દરેક લક્ષ્ય પ્રાપ્ત કરી શકાય છે.',
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 13.5,
                  height: 1.6,
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
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: Text(
                      '— ${data.box2Author}',
                      style: const TextStyle(
                        color: Color(0xFF34D399),
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
    final color = videoIndex == 1 ? const Color(0xFF3B82F6) : const Color(0xFF8B5CF6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Icon(Icons.smart_display_rounded, color: color, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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
              border: Border.all(color: color.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 12,
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
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Center YouTube Play Button
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE53935).withOpacity(0.6),
                          blurRadius: 18,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.ondemand_video_rounded, color: Color(0xFFEF4444), size: 14),
                            SizedBox(width: 6),
                            Text(
                              'YouTube વિડીયો જુઓ',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Open Video ➔',
                          style: TextStyle(
                            color: Color(0xFF041126),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
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
      color: const Color(0xFF0B1B36),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_rounded, color: color.withOpacity(0.7), size: 48),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
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
              Container(width: 32, height: 1, color: const Color(0xFFD4AF37).withOpacity(0.3)),
              const SizedBox(width: 10),
              const Icon(Icons.auto_stories_rounded, color: Color(0xFFD4AF37), size: 16),
              const SizedBox(width: 10),
              Container(width: 32, height: 1, color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'ઓલ ગુજરાત વણકર સમાજ • શિક્ષણ સમિતિ',
            style: TextStyle(
              color: const Color(0xFFD4AF37).withOpacity(0.85),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'વિદ્યાર્થીઓ માટે શૈક્ષણિક પ્રગતિનું પ્લેટફોર્મ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
