import 'package:omarchy_emojis/src/features/app/app.dart';
import 'package:omarchy_emojis/src/features/home/actions.dart';
import 'package:omarchy_emojis/src/features/home/state/notifier.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_emojis/src/services/emojis/service.dart';
import 'package:omarchy_emojis/src/widgets/emoji.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeNotifier? notifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = ServicesProvider.of(context);
    if (notifier?.db != services.database ||
        notifier?.emojis != services.emojis) {
      notifier = HomeNotifier(db: services.database, emojis: services.emojis);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = this.notifier!;
    final theme = OmarchyTheme.of(context);
    const emojiSize = 24.0;
    return LayoutBuilder(
      builder: (context, layout) {
        return AnimatedBuilder(
          animation: notifier,
          builder: (context, _) {
            final columns = layout.maxWidth ~/ (emojiSize + 18);
            final groups = notifier.results;
            Iterable<Widget> getGroup(int index) sync* {
              final group = groups[index];
              if (index > 0) {
                yield SliverToBoxAdapter(child: OmarchyDivider.vertical());
              }
              yield SliverToBoxAdapter(child: EmojiGroupHeader(group: group));
              yield SliverPadding(
                padding: const EdgeInsets.all(14),
                sliver: SliverGrid(
                  key: Key(group.name),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    childCount: group.emojis.length,
                    (context, i) {
                      final data = group.emojis[i];
                      return EmojiTile(
                        key: ValueKey(data.id),
                        data,
                        notifier: notifier,
                        isHovered: notifier.hovered == data,
                        size: emojiSize,
                        onPressed: () {
                          notifier.setHovered(data);
                          notifier.confirm();
                        },
                        onHovered: () {
                          if (notifier.ensureVisible) return;
                          notifier.setHovered(data);
                        },
                      );
                    },
                  ),
                ),
              );
            }

            return HomeShortcuts(
              child: HomeActions(
                columns: columns,
                notifier: notifier,
                child: OmarchyScaffold(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OmarchyTextInput(
                        autofocus: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        placeholder: const Text(
                          'Search emojis...',
                          style: TextStyle(fontSize: 20),
                        ),
                        onChanged: notifier.setQuery,
                        style: theme.text.normal.copyWith(
                          fontSize: 20,
                          color: theme.colors.bright.blue,
                        ),
                      ),
                      OmarchyDivider.vertical(),
                      Expanded(
                        child: CustomScrollView(
                          slivers: [
                            for (var i = 0; i < groups.length; i++)
                              ...getGroup(i),
                          ],
                        ),
                      ),
                      OmarchyDivider.vertical(),
                      SelectedEmoji(notifier.hovered),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class EmojiGroupHeader extends StatelessWidget {
  const EmojiGroupHeader({super.key, required this.group});

  final EmojiGroup group;
  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 14, top: 14, right: 14),
      child: Text.rich(
        TextSpan(
          style: theme.text.normal,
          children: [
            TextSpan(text: group.name),
            TextSpan(text: ' '),
            TextSpan(
              text: group.emojis.length.toString(),
              style: theme.text.italic.copyWith(
                color: theme.colors.bright.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmojiTile extends StatefulWidget {
  const EmojiTile(
    this.data, {
    super.key,
    required this.size,
    required this.onHovered,
    required this.onPressed,
    required this.isHovered,
    required this.notifier,
  });

  final HomeNotifier notifier;
  final EmojiData data;
  final bool isHovered;
  final double size;
  final VoidCallback onPressed;
  final VoidCallback onHovered;

  @override
  State<EmojiTile> createState() => _EmojiTileState();
}

class _EmojiTileState extends State<EmojiTile> {
  @override
  void didUpdateWidget(covariant EmojiTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered &&
        !oldWidget.isHovered &&
        widget.notifier.ensureVisible) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 100),
        alignment: 1,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return PointerArea(
      onTap: widget.onPressed,
      onHoverStart: widget.onHovered,
      builder: (context, state, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: theme.colors.border.withValues(
                alpha: widget.isHovered ? 1 : 0.0,
              ),
            ),
            color: theme.colors.normal.black.withValues(
              alpha: widget.isHovered ? 1 : 0.0,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Center(child: Emoji(widget.data, size: widget.size)),
        );
      },
    );
  }
}

class SelectedEmoji extends StatelessWidget {
  const SelectedEmoji(this.data, {super.key});

  final EmojiData? data;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Row(
          key: ValueKey(data?.id),
          spacing: 14,
          children: [
            if (data != null)
              Emoji(data!, size: 32)
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colors.normal.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    OmarchyIcons.faClose,
                    color: theme.colors.bright.black,
                  ),
                ),
              ),
            Column(children: [Text(data?.name ?? 'No emoji selected')]),
          ],
        ),
      ),
    );
  }
}
