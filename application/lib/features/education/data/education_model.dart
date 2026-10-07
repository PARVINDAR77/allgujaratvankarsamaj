class EducationModel {
  final dynamic id;
  final String pageTitle;
  final String pageSubtitle;
  final bool isActive;

  // Box 1: PDF Resources
  final String box1Title;
  final String box1Subtitle;
  final String box1PdfUrl;
  final String box1PdfName;
  final String box1Description;

  // Box 2: Written Paragraph / Editorial
  final String box2Title;
  final String box2Subtitle;
  final String box2Content;
  final String box2Author;

  // Box 3: YouTube Video 1
  final String box3Title;
  final String box3Subtitle;
  final String box3YoutubeUrl;
  final String box3ThumbnailUrl;

  // Box 4: YouTube Video 2
  final String box4Title;
  final String box4Subtitle;
  final String box4YoutubeUrl;
  final String box4ThumbnailUrl;

  final DateTime? updatedAt;

  EducationModel({
    required this.id,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.isActive,
    required this.box1Title,
    required this.box1Subtitle,
    required this.box1PdfUrl,
    required this.box1PdfName,
    required this.box1Description,
    required this.box2Title,
    required this.box2Subtitle,
    required this.box2Content,
    required this.box2Author,
    required this.box3Title,
    required this.box3Subtitle,
    required this.box3YoutubeUrl,
    required this.box3ThumbnailUrl,
    required this.box4Title,
    required this.box4Subtitle,
    required this.box4YoutubeUrl,
    required this.box4ThumbnailUrl,
    this.updatedAt,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    String getStr(List<String> keys, String fallback) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null && json[k].toString().trim().isNotEmpty) {
          return json[k].toString().trim();
        }
      }
      return fallback;
    }

    final rawIsActive = json['isActive'] ?? json['is_active'];
    final bool active = rawIsActive == null ? true : (rawIsActive == true || rawIsActive == 1 || rawIsActive == '1');

    return EducationModel(
      id: json['id'] ?? 'default',
      pageTitle: getStr(['headerTitle', 'header_title', 'pageTitle', 'page_title'], 'Education for Better Tomorrow'),
      pageSubtitle: getStr(['headerSubtitle', 'header_subtitle', 'pageSubtitle', 'page_subtitle'], 'શિક્ષણ અને ઉજ્જવળ ભવિષ્ય માર્ગદર્શન'),
      isActive: active,

      // Box 1: PDF
      box1Title: getStr(['box1Title', 'box1_title'], 'શિક્ષણ માર્ગદર્શિકા અને પરિપત્રો (PDF)'),
      box1Subtitle: getStr(['box1Subtitle', 'box1_subtitle'], 'Download Official Educational PDF Guidelines & Circulars'),
      box1PdfUrl: getStr(['box1PdfUrl', 'box1_pdf_url'], ''),
      box1PdfName: getStr(['box1FileName', 'box1_file_name', 'box1PdfName', 'box1_pdf_name'], 'career_guidance_2026.pdf'),
      box1Description: getStr(['box1Description', 'box1_description'], 'અહીંથી વિદ્યાર્થીઓ અને વાલીઓ માટે ઉપયોગી શૈક્ષણિક સાહિત્ય ડાઉનલોડ કરો.'),

      // Box 2: Editorial Paragraph
      box2Title: getStr(['box2Title', 'box2_title'], 'શિક્ષણ પ્રેરણા સંદેશ & કારકિર્દી સલાહ'),
      box2Subtitle: getStr(['box2Subtitle', 'box2_subtitle'], 'શિક્ષણ એ પ્રગતિનું સર્વોચ્ચ શસ્ત્ર છે'),
      box2Content: getStr([
        'box2Content',
        'box2_content'
      ], 'શિક્ષણ એ જીવનનો સૌથી મહત્વનો પાયો છે. આપણા વણકર સમાજના દરેક દીકરા અને દીકરી ઉચ્ચ શિક્ષણ મેળવી સમાજ અને દેશનું નામ રોશન કરે તે અમારો મુખ્ય સંકલ્પ છે. ધોરણ ૧૦ અને ૧૨ પછીના વિવિધ અભ્યાસક્રમો, સ્કોલરશીપ સહાય, અને સરકારી ભરતીઓની તૈયારી માટે સમાજ સદાય તમારી સાથે છે. જ્ઞાન એ જ શક્તિ છે, અને શિક્ષણ દ્વારા જ પ્રગતિ શક્ય છે.'),
      box2Author: getStr(['box2Author', 'box2_author'], 'શિક્ષણ સમિતિ, ઓલ ગુજરાત વણકર સમાજ'),

      // Box 3: YouTube 1
      box3Title: getStr(['box3Title', 'box3_title'], 'શૈક્ષણિક સેમિનાર & કારકિર્દી માર્ગદર્શન'),
      box3Subtitle: getStr(['box3Subtitle', 'box3_subtitle', 'box3Description', 'box3_description'], 'ઉચ્ચ અભ્યાસ અને કારકિર્દી પસંદગી અંગે વિશેષ માર્ગદર્શન વ્યાખ્યાન.'),
      box3YoutubeUrl: getStr(['box3YoutubeUrl', 'box3_youtube_url'], 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
      box3ThumbnailUrl: getStr(['box3ThumbnailUrl', 'box3_thumbnail_url'], ''),

      // Box 4: YouTube 2
      box4Title: getStr(['box4Title', 'box4_title'], 'યુવા પ્રેરણા સંવાદ & સફળતાની વાર્તાઓ'),
      box4Subtitle: getStr(['box4Subtitle', 'box4_subtitle', 'box4Description', 'box4_description'], 'સમાજના તેજસ્વી તારલાઓ અને અધિકારીઓના પ્રેરણાદાયી અનુભવો.'),
      box4YoutubeUrl: getStr(['box4YoutubeUrl', 'box4_youtube_url'], 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
      box4ThumbnailUrl: getStr(['box4ThumbnailUrl', 'box4_thumbnail_url'], ''),

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : (json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headerTitle': pageTitle,
      'headerSubtitle': pageSubtitle,
      'isActive': isActive,
      'box1Title': box1Title,
      'box1Subtitle': box1Subtitle,
      'box1PdfUrl': box1PdfUrl,
      'box1FileName': box1PdfName,
      'box1Description': box1Description,
      'box2Title': box2Title,
      'box2Subtitle': box2Subtitle,
      'box2Content': box2Content,
      'box2Author': box2Author,
      'box3Title': box3Title,
      'box3Subtitle': box3Subtitle,
      'box3YoutubeUrl': box3YoutubeUrl,
      'box3ThumbnailUrl': box3ThumbnailUrl,
      'box4Title': box4Title,
      'box4Subtitle': box4Subtitle,
      'box4YoutubeUrl': box4YoutubeUrl,
      'box4ThumbnailUrl': box4ThumbnailUrl,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Extracts YouTube video ID for thumbnail preview if thumbnail URL is empty
  static String extractYoutubeId(String url) {
    if (url.isEmpty) return '';
    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match != null ? match.group(1) ?? '' : '';
  }

  String get box3DisplayThumbnail {
    if (box3ThumbnailUrl.isNotEmpty) return box3ThumbnailUrl;
    final id = extractYoutubeId(box3YoutubeUrl);
    if (id.isNotEmpty) return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    return '';
  }

  String get box4DisplayThumbnail {
    if (box4ThumbnailUrl.isNotEmpty) return box4ThumbnailUrl;
    final id = extractYoutubeId(box4YoutubeUrl);
    if (id.isNotEmpty) return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    return '';
  }
}
