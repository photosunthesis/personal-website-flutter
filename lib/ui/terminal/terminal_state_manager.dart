import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/domain/commands.dart';
import 'package:sun_envidiado_website/domain/terminal_content.dart';

class TerminalStateManager {
  TerminalStateManager() {
    commandsNotifier.value = [];
    _showFastfetch();
    _addToHistory([const TerminalText('')]);
    textController.addListener(_onTextChanged);
    commandsNotifier.addListener(_scrollToBottom);
  }

  final commandsNotifier = ValueNotifier(<TerminalContent>[]);
  final currentInputNotifier = ValueNotifier('');
  final scrollController = ScrollController();
  final textController = TextEditingController();
  final focusNode = FocusNode();

  void _onTextChanged() {
    currentInputNotifier.value = textController.text;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.linear,
        );
      }
    });
  }

  void handleSubmit([ColorScheme? colorScheme]) {
    final input = textController.text.trim();
    if (input.isNotEmpty) {
      inputCommand(input, colorScheme);
      textController.clear();
    }
  }

  Future<void> inputCommand(String input, [ColorScheme? colorScheme]) async {
    _addToHistory([TerminalText('guest@terminal:~ \$  $input')]);

    final command = Commands.fromString(input.toLowerCase());

    switch (command) {
      case Commands.help:
        _showHelp();
        break;
      case Commands.clear:
        _clearTerminal();
        break;
      case Commands.fastfetch:
        _showFastfetch();
        break;
      case Commands.work:
        _showWork();
        break;
      case Commands.whoami:
        _showWhoAmI();
        break;
      default:
        _addToHistory([
          TerminalText('Unknown command: $input'),
          const TerminalText('Type "help" to see available commands.'),
        ]);
        break;
    }

    if (command != Commands.clear ||
        command != Commands.help ||
        command != Commands.unknown) {
      unawaited(
        FirebaseAnalytics.instance.logEvent(
          name: 'terminal_command',
          parameters: {
            'command': Commands.fromString(input.toLowerCase()).name,
          },
        ),
      );
    }

    _addToHistory([const TerminalText('')]);
  }

  void _addToHistory(List<TerminalContent> content) {
    commandsNotifier.value = [...commandsNotifier.value, ...content];
  }

  void _clearTerminal() {
    commandsNotifier.value = [];
  }

  void _showHelp() {
    _addToHistory([
      const TerminalText('Available commands:'),
      const TerminalText('  help      - Show this help message'),
      const TerminalText('  clear     - Clear the terminal'),
      const TerminalText('  fastfetch - Display system information'),
      const TerminalText('  work      - Display work experience'),
      const TerminalText('  whoami    - Who I am, what I do'),
    ]);
  }

  void _showWhoAmI() => _addToHistory([const TerminalCommand(Commands.whoami)]);

  void _showWork() => _addToHistory([const TerminalCommand(Commands.work)]);

  void _showFastfetch() =>
      _addToHistory([const TerminalCommand(Commands.fastfetch)]);

  void dispose() {
    textController.removeListener(_onTextChanged);
    commandsNotifier.removeListener(_scrollToBottom);
    commandsNotifier.dispose();
    currentInputNotifier.dispose();
    scrollController.dispose();
    textController.dispose();
    focusNode.dispose();
  }
}
