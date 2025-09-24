import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_emojis/src/services/config/config.dart';
import 'package:omarchy_emojis/src/services/emojis/service.dart';
import 'package:sprite_image/sprite_image.dart';

class Emoji extends StatelessWidget {
  const Emoji(
    this.data, {
    super.key,
    this.size = 24,
    this.style = EmojiStyle.facebook,
  });

  final EmojiStyle style;
  final double size;
  final EmojiData data;

  @override
  Widget build(BuildContext context) {
    const spriteSize = Size(64, 64);
    final x = (data.sheetX * (spriteSize.width + 2)) + 1;
    final y = (data.sheetY * (spriteSize.height + 2)) + 1;
    return Sprite.asset(
      'assets/sheet_${style.name}_64.png',
      source: Offset(x, y) & spriteSize,
      width: size,
      height: size,
    );
  }
}
