import 'dart:convert';
import 'package:flutter/services.dart';

import 'app_settings.dart';
import 'aria_data.dart';

class AllAriasRepository {
  static Future<List<AriaSummary>> loadAllArias() async {
    final jsonString = await rootBundle.loadString(AppSettings.ariasPath);
    final decoded = jsonDecode(jsonString) as List<dynamic>;

    return decoded
        .map((e) => AriaSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ComposerData>> loadComposers() async {
    final jsonString = await rootBundle.loadString(AppSettings.composersPath);
    final decoded = jsonDecode(jsonString) as List<dynamic>;

    return decoded
        .map((e) => ComposerData.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<AriaData> loadAriaDetail(String id) async {
    final path = AppSettings.ariaDetailPaths[id];

    if (path == null) {
      throw Exception('No detail path found for aria id: $id');
    }

    final jsonString = await rootBundle.loadString(path);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    return AriaData.fromJson(decoded);
  }
}
