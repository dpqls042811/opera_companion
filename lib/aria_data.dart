class AriaSummary {
  final String id;
  final String title;
  final String composer;
  final String languageCode;

  const AriaSummary({
    required this.id,
    required this.title,
    required this.composer,
    required this.languageCode,
  });

  factory AriaSummary.fromJson(Map<String, dynamic> json) {
    return AriaSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      composer: json['composer'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? 'de',
    );
  }
}

class ComposerData {
  final String name;
  final String subtitle;
  final List<String> ariaIds;

  const ComposerData({
    required this.name,
    required this.subtitle,
    required this.ariaIds,
  });

  factory ComposerData.fromJson(Map<String, dynamic> json) {
    return ComposerData(
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      ariaIds: (json['ariaIds'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class AriaData {
  final String id;
  final String title;
  final String composer;
  final String languageCode;
  final List<AriaLineData> lines;

  const AriaData({
    required this.id,
    required this.title,
    required this.composer,
    required this.languageCode,
    required this.lines,
  });

  factory AriaData.fromJson(Map<String, dynamic> json) {
    return AriaData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      composer: json['composer'] as String? ?? '',
      languageCode: json['languageCode'] as String? ?? 'de',
      lines: (json['lines'] as List<dynamic>? ?? [])
          .map((e) => AriaLineData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AriaLineData {
  final String text;
  final String meaning;
  final String ipa;
  final String vocab;

  const AriaLineData({
    required this.text,
    required this.meaning,
    required this.ipa,
    required this.vocab,
  });

  factory AriaLineData.fromJson(Map<String, dynamic> json) {
    return AriaLineData(
      text: json['text'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      ipa: json['ipa'] as String? ?? '',
      vocab: json['vocab'] as String? ?? '',
    );
  }
}
