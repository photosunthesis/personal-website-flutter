import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/domain/commands.dart';

/// Represents content that can be displayed in the terminal
sealed class TerminalContent {
  const TerminalContent();
}

/// Text content with optional styling and URL
class TerminalText extends TerminalContent {
  const TerminalText(this.text, {this.url, this.color}) : spans = null;
  const TerminalText.rich(this.spans, {this.url}) : text = null, color = null;

  final String? text;
  final String? url;
  final Color? color;
  final List<InlineSpan>? spans;
}

/// Command content that requires custom widget rendering
class TerminalCommand extends TerminalContent {
  const TerminalCommand(this.command);

  final Commands command;
}
