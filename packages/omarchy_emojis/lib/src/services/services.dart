import 'dart:io';

import 'package:omarchy_emojis/src/services/config/service.dart';
import 'package:omarchy_emojis/src/services/database/service.dart';
import 'package:flutter/foundation.dart';
import 'package:omarchy_emojis/src/services/emojis/service.dart';

class Services {
  const Services({
    required this.config,
    required this.database,
    required this.emojis,
  });

  factory Services.demo() {
    return Services(
      config: ConfigService.demo(),
      database: DatabaseService.demo(),
      emojis: EmojiService.demo(),
    );
  }

  static Future<Services> fromPlatform() async {
    if (kIsWeb) {
      return Services.demo();
    }
    if (Platform.isLinux) {
      return Services(
        config: ConfigService.linux(),
        database: await DatabaseService.sql(),
        emojis: await EmojiService.loadFromBundle(),
      );
    }

    return Services(
      config: ConfigService.local(),
      database: await DatabaseService.sql(),
      emojis: await EmojiService.loadFromBundle(),
    );
  }

  final ConfigService config;
  final DatabaseService database;
  final EmojiService emojis;
}
