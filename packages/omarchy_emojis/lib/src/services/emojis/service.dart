import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class EmojiData {
  const EmojiData({
    required this.name,
    required this.unified,
    required this.sheetX,
    required this.sheetY,
    required this.category,
    required this.subcategory,
  });

  final String name;
  final String unified;
  final int sheetX;
  final int sheetY;
  final String category;
  final String subcategory;
}

class EmojisService {
  const EmojisService(this.data);

  static Future<EmojisService> loadFromBundle(BuildContext context) async {
    final json = await rootBundle.loadString('assets/emoji.json');
    final data = jsonDecode(json);
    return EmojisService(
      (data as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          EmojiData(
            name: value['name'],
            unified: value['unified'],
            sheetX: value['sheet_x'],
            sheetY: value['sheet_y'],
            category: value['category'],
            subcategory: value['subcategory'],
          ),
        ),
      ),
    );
  }

  final Map<String, EmojiData> data;

  List<EmojiData> filter(String query) {
    if (query.isEmpty) {
      return data.values.toList();
    }
    final lowerQuery = query.toLowerCase();
    return data.values
        .where((emoji) => emoji.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
