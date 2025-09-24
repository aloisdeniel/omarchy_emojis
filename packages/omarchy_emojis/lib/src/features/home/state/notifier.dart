import 'dart:io';

import 'package:fuzzywuzzy/model/extracted_result.dart';
import 'package:omarchy_emojis/src/services/database/service.dart';
import 'package:flutter/cupertino.dart';
import 'package:omarchy_emojis/src/services/emojis/service.dart';

class EmojiGroup {
  EmojiGroup(this.name, this.emojis);
  final String name;
  final List<EmojiData> emojis;
}

enum MoveHoveredDirection { left, right, up, down }

class HomeNotifier extends ChangeNotifier {
  HomeNotifier({required this.db, required this.emojis});

  final DatabaseService db;
  final EmojiService emojis;

  late List<EmojiGroup> _results = _filterAndGroup(query);
  List<EmojiGroup> get results => _results;

  EmojiData? _hovered;
  EmojiData? get hovered => _hovered;

  bool _ensureVisible = false;
  bool get ensureVisible => _ensureVisible;

  void setHovered(EmojiData? value) {
    if (value != _hovered) {
      _hovered = value;
      notifyListeners();
    }
  }

  void moveHovered(int columns, MoveHoveredDirection direction) {
    if (results.isEmpty) return;

    if (hovered == null) {
      setHovered(results.first.emojis.first);
      return;
    }

    _activateEnsureVisible();
    for (var groupIndex = 0; groupIndex < results.length; groupIndex++) {
      final group = results[groupIndex];
      final index = group.emojis.indexOf(hovered!);
      if (index != -1) {
        int newIndex;
        switch (direction) {
          case MoveHoveredDirection.left:
            newIndex = (index - 1);
            if (newIndex < 0) {
              if (groupIndex > 0) {
                // Move to the last emoji of the previous group
                setHovered(results[groupIndex - 1].emojis.last);
                return;
              }
              // Wrap around to the last emoji of the last group
              setHovered(results.last.emojis.last);
              return;
            }
          case MoveHoveredDirection.right:
            newIndex = (index + 1);
            if (newIndex >= group.emojis.length) {
              if (groupIndex < results.length - 1) {
                // Move to the first emoji of the next group
                setHovered(results[groupIndex + 1].emojis.first);
                return;
              }
              // Wrap around to the first emoji of the first group
              setHovered(results.first.emojis.first);
              return;
            }
          case MoveHoveredDirection.up:
            newIndex = (index - columns);
            if (newIndex < 0) {
              if (groupIndex > 0) {
                // Move to the emoji of the last row and same column in the previous group
                final prevGroup = results[groupIndex - 1];
                setHovered(
                  prevGroup.emojis[((prevGroup.emojis.length ~/ columns) *
                              columns +
                          index % columns)
                      .clamp(0, prevGroup.emojis.length - 1)],
                );
                return;
              } else {
                newIndex = 0;
              }
            }
          case MoveHoveredDirection.down:
            newIndex = (index + columns);
            if (newIndex >= group.emojis.length) {
              if (groupIndex < results.length - 1) {
                // Move to the first emoji of the next group
                final nextGroup = results[groupIndex + 1];
                setHovered(
                  nextGroup.emojis[(index % columns).clamp(
                    0,
                    nextGroup.emojis.length - 1,
                  )],
                );
                return;
              } else {
                newIndex = group.emojis.length - 1;
              }
            }
        }
        setHovered(group.emojis[newIndex]);
        return;
      }
    }
  }

  String _query = '';
  String get query => _query;

  void setQuery(String value) {
    if (value != _query) {
      _query = value;
      _results = _filterAndGroup(query);
      _hovered = _results.firstOrNull?.emojis.firstOrNull;
      notifyListeners();
    }
  }

  void clearQuery() {
    setQuery('');
  }

  void confirm() {
    if (_hovered case final data?) {
      final code = String.fromCharCodes(
        data.unified.split('-').map((e) => int.parse(e, radix: 16)),
      );
      stdout.write(code);
      exit(0);
    }
  }

  void close() {
    exit(0);
  }

  List<EmojiGroup> _filterAndGroup(String query) {
    final filtered = emojis.filter(query);

    final groupScore = <String, int>{};
    final groups = <String, List<ExtractedResult<EmojiData>>>{};

    for (final emoji in filtered) {
      final groupName = emoji.choice.category;
      var maxScore = groupScore.putIfAbsent(groupName, () {
        return emoji.score;
      });
      if (emoji.score > maxScore) {
        groupScore[groupName] = maxScore;
      }
      var group = groups.putIfAbsent(groupName, () {
        return [];
      });
      group.add(emoji);
    }

    const groupOrder = {
      'Smileys & Emotion': 8,
      'People & Body': 7,
      'Animals & Nature': 6,
      'Food & Drink': 5,
      'Travel & Places': 4,
      'Activities': 3,
      'Objects': 2,
      'Symbols': 1,
      'Flags': 0,
    };

    for (final group in groupScore.entries) {
      groupScore[group.key] = group.value + (groupOrder[group.key] ?? 0);
    }

    for (final group in groups.values) {
      group.sort((a, b) {
        final scoreDiff = b.score - a.score;
        if (scoreDiff != 0) return scoreDiff;
        return a.choice.id.compareTo(b.choice.id);
      });
    }

    final results = groups.entries
        .map((e) => EmojiGroup(e.key, e.value.map((e) => e.choice).toList()))
        .toList();

    results.sort((a, b) {
      final orderA = groupScore[a.name] ?? 0;
      final orderB = groupScore[b.name] ?? 0;
      return orderB.compareTo(orderA);
    });

    return results;
  }

  var _ensureVisibleRequest = 0;
  void _activateEnsureVisible() async {
    final initialRequest = ++_ensureVisibleRequest;
    _ensureVisible = true;
    await Future.delayed(const Duration(milliseconds: 200));
    if (initialRequest != _ensureVisibleRequest) return;
    _ensureVisible = false;
  }
}
