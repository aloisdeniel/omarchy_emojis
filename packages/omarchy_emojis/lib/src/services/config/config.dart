import 'package:yaml/yaml.dart';

part 'default.dart';

enum EmojiStyle { google, twitter, facebook }

class Config {
  const Config({
    required this.demo,
    required this.emojiSize,
    required this.style,
  });

  final bool demo;
  final EmojiStyle style;
  final double emojiSize;

  factory Config.fromYaml(String yaml) {
    final map = loadYaml(yaml);
    if (map is YamlMap) {
      return Config(
        demo: map['demo'] as bool,
        emojiSize: (map['emoji_size'] as num?)?.toDouble() ?? 24.0,
        style: switch (map['style']) {
          'google' => EmojiStyle.google,
          'twitter' => EmojiStyle.twitter,
          'facebook' => EmojiStyle.facebook,
          _ => throw ArgumentError.value(
            map['style']?.toString() ?? '',
            'style',
            'Invalid emoji style',
          ),
        },
      );
    } else {
      throw ArgumentError.value(yaml, 'yaml', 'Invalid YAML format');
    }
  }
}
