import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class PronunciationService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _sanitizeWord(String word) {
    String s = word.trim().toLowerCase();

    s = s.replaceAll("'", '');
    s = s.replaceAll("’", '');
    s = s.replaceAll("`", '');

    s = s
        .replaceAll('à', 'a')
        .replaceAll('á', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('å', 'a')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('í', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('ú', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n');

    s = s.replaceAll(RegExp(r'[.,!?;:()"“”$$$${}\-]'), '');
    s = s.replaceAll(RegExp(r'\s+'), '_');
    s = s.replaceAll(RegExp(r'[^a-z0-9_]'), '');
    s = s.replaceAll(RegExp(r'_+'), '_');
    s = s.replaceAll(RegExp(r'^_+'), '');
    s = s.replaceAll(RegExp(r'_+$'), '');

    return s;
  }

  Future<void> playPronunciation(String word, String languageCode) async {
    final sanitized = _sanitizeWord(word);
    final fileName = '${sanitized}_$languageCode.mp3';
    final assetPath = 'audio/$fileName';

    debugPrint('>>> 원본 단어: [$word]');
    debugPrint('>>> 정리된 단어: [$sanitized]');
    debugPrint('>>> 재생 시도 asset: [$assetPath]');

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
      debugPrint('>>> 파일 재생 성공: $fileName');
    } catch (e) {
      debugPrint('>>> 파일 재생 실패 ($fileName): $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}