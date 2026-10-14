import 'package:application/shared/models/chat_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMedia', () {
    test('encodes and parses image/video/pdf', () {
      for (final type in ChatMediaType.values) {
        final encoded = ChatMedia.encode(type, 'https://allgujaratvankarsamaj.com/uploads/a.bin', 'my|file.pdf');
        final parsed = ChatMedia.tryParse(encoded);
        expect(parsed, isNotNull);
        expect(parsed!.type, type);
        expect(parsed.url, 'https://allgujaratvankarsamaj.com/uploads/a.bin');
        expect(parsed.fileName, 'my_file.pdf');
      }
    });

    test('plain text is not media', () {
      expect(ChatMedia.tryParse('નમસ્તે 🙏'), isNull);
      expect(ChatMedia.previewText('Hello'), 'Hello');
    });

    test('rejects non-http urls', () {
      expect(ChatMedia.tryParse('[IMAGE]javascript:alert(1)|x.jpg'), isNull);
      expect(ChatMedia.tryParse('[PDF]|x.pdf'), isNull);
    });

    test('preview text for media', () {
      expect(ChatMedia.previewText('[IMAGE]/uploads/a.jpg|a.jpg'), contains('Photo'));
      expect(ChatMedia.previewText('[VIDEO]/uploads/a.mp4|a.mp4'), contains('Video'));
      expect(ChatMedia.previewText('[PDF]/uploads/a.pdf|Biodata.pdf'), contains('Biodata.pdf'));
    });
  });
}
