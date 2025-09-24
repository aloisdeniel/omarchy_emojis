import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:fuzzywuzzy/model/extracted_result.dart';

class EmojiData {
  const EmojiData({
    required this.id,
    required this.name,
    required this.unified,
    required this.sheetX,
    required this.sheetY,
    required this.category,
    required this.subcategory,
  });

  final int id;
  final String name;
  final String unified;
  final int sheetX;
  final int sheetY;
  final String category;
  final String subcategory;

  @override
  String toString() {
    return name;
  }
}

class EmojiService {
  const EmojiService(this.data);

  const EmojiService.demo()
    : data = const {
        'grinning face': EmojiData(
          id: 0,
          name: 'grinning face',
          unified: '1F600',
          sheetX: 0,
          sheetY: 0,
          category: 'Smileys & Emotion',
          subcategory: 'face-smiling',
        ),
      };

  static Future<EmojiService> loadFromBundle() async {
    final json = await rootBundle.loadString('assets/emoji.json');
    final data = jsonDecode(json);
    EmojiData read(int i) {
      final value = data[i];
      return EmojiData(
        id: i,
        name: value['name'],
        unified: value['unified'],
        sheetX: value['sheet_x'],
        sheetY: value['sheet_y'],
        category: value['category'],
        subcategory: value['subcategory'],
      );
    }

    return EmojiService({
      for (var i = 0; i < (data as List<dynamic>).length; i++)
        data[i]['name']: read(i),
    });
  }

  final Map<String, EmojiData> data;

  List<ExtractedResult<EmojiData>> filter(String query) {
    if (query.isEmpty) {
      return data.values
          .toList()
          .map((e) => ExtractedResult(e, 100, 1, (c) => c.name))
          .toList();
    }
    return extractTop(
      query: query,
      choices: data.values.toList(),
      limit: 40,
      cutoff: 70,
      getter: (v) => v.name,
    );
  }
}
