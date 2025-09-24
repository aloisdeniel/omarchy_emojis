import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:omarchy_emojis/src/features/home/state/notifier.dart';

class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const MoveLeftIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const MoveRightIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const MoveUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const MoveDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const ExitIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ConfirmIntent(),
        LogicalKeySet(LogicalKeyboardKey.numpadEnter): const ConfirmIntent(),
      },
      child: child,
    );
  }
}

class HomeActions extends StatelessWidget {
  const HomeActions({
    super.key,
    required this.columns,
    required this.notifier,
    required this.child,
  });

  final int columns;
  final HomeNotifier notifier;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        MoveRightIntent: MoveHoveredAction(notifier, columns),
        MoveLeftIntent: MoveHoveredAction(notifier, columns),
        MoveUpIntent: MoveHoveredAction(notifier, columns),
        MoveDownIntent: MoveHoveredAction(notifier, columns),
        ConfirmIntent: ConfirmAction(notifier),
        ExitIntent: ExitAction(notifier),
      },
      child: child,
    );
  }
}

class ExitAction extends Action<ExitIntent> {
  ExitAction(this.model);
  final HomeNotifier model;
  @override
  void invoke(covariant ExitIntent intent) {
    model.close();
  }
}

class ConfirmAction extends Action<ConfirmIntent> {
  ConfirmAction(this.model);
  final HomeNotifier model;
  @override
  void invoke(covariant ConfirmIntent intent) {
    model.confirm();
  }
}

class MoveHoveredAction extends Action<MoveIntent> {
  MoveHoveredAction(this.model, this.columns);
  final HomeNotifier model;
  final int columns;
  @override
  void invoke(covariant MoveIntent intent) {
    model.moveHovered(columns, intent.direction);
  }
}

abstract class MoveIntent extends Intent {
  const MoveIntent();

  MoveHoveredDirection get direction;
}

class MoveRightIntent extends MoveIntent {
  const MoveRightIntent();

  @override
  MoveHoveredDirection get direction => MoveHoveredDirection.right;
}

class MoveLeftIntent extends MoveIntent {
  const MoveLeftIntent();

  @override
  MoveHoveredDirection get direction => MoveHoveredDirection.left;
}

class MoveUpIntent extends MoveIntent {
  const MoveUpIntent();

  @override
  MoveHoveredDirection get direction => MoveHoveredDirection.up;
}

class MoveDownIntent extends MoveIntent {
  const MoveDownIntent();

  @override
  MoveHoveredDirection get direction => MoveHoveredDirection.down;
}

class ExitIntent extends Intent {
  const ExitIntent();
}

class ConfirmIntent extends Intent {
  const ConfirmIntent();
}
