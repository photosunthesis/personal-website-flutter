import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/constants/screen_widths.dart';
import 'package:sun_envidiado_website/domain/commands.dart';
import 'package:sun_envidiado_website/domain/terminal_content.dart';
import 'package:sun_envidiado_website/ui/terminal/components/fastfetch.dart';
import 'package:sun_envidiado_website/ui/terminal/components/whoami.dart';
import 'package:sun_envidiado_website/ui/terminal/components/work.dart';
import 'package:sun_envidiado_website/ui/terminal/terminal_state_manager.dart';
import 'package:sun_envidiado_website/utils/build_context_extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  late final TerminalStateManager _terminalStateManager;

  @override
  void initState() {
    super.initState();
    _terminalStateManager = TerminalStateManager();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _terminalStateManager.focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _terminalStateManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorScheme.surface,
      child: GestureDetector(
        onTap: () {
          if (_terminalStateManager.focusNode.hasFocus) {
            _terminalStateManager.focusNode.unfocus();
          } else {
            _terminalStateManager.focusNode.requestFocus();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(
            context.screenWidth < ScreenWidths.mobile ? 8 : 16,
          ),
          child: ValueListenableBuilder(
            valueListenable: _terminalStateManager.commandsNotifier,
            builder: (context, commands, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      controller: _terminalStateManager.scrollController,
                      children: [
                        ...commands.map(
                          (content) => _buildTerminalContent(
                            content,
                            showAsciiArt:
                                context.screenWidth >= ScreenWidths.tablet,
                          ),
                        ),
                        _buildInput(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalContent(
    TerminalContent content, {
    required bool showAsciiArt,
  }) {
    return SelectionArea(
      child: switch (content) {
        final TerminalText text => _buildTerminalText(text),
        final TerminalCommand command => _buildTerminalCommand(command),
      },
    );
  }

  Widget _buildTerminalCommand(TerminalCommand command) {
    return switch (command.command) {
      Commands.fastfetch => const Fastfetch(),
      Commands.whoami => const WhoAmI(),
      Commands.work => const Work(),
      _ => throw UnimplementedError(
        'Command ${command.command} is not implemented',
      ),
    };
  }

  Widget _buildTerminalText(TerminalText text) {
    if (text.spans != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: RichText(
          text: TextSpan(
            children: text.spans!.map((span) {
              if (span is TextSpan) {
                return TextSpan(
                  text: span.text,
                  style: context.textTheme.titleLarge?.copyWith(
                    color:
                        span.style?.color ??
                        text.color ??
                        context.colorScheme.primary,
                    fontSize: context.scaledBodyFontSize,
                  ),
                  recognizer: span.recognizer,
                );
              }
              return span;
            }).toList(),
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: context.scaledBodyFontSize,
            ),
          ),
        ),
      );
    }
    final textWidget = Text(
      text.text ?? '',
      style: context.textTheme.titleLarge?.copyWith(
        color: text.color ?? context.colorScheme.primary,
        fontSize: context.scaledBodyFontSize,
      ),
    );
    if (text.url != null) {
      return InkWell(
        onTap: () =>
            launchUrlString(text.url!, mode: LaunchMode.externalApplication),
        child: textWidget,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: textWidget,
    );
  }

  Widget _buildInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r'guest@terminal:~ $  ',
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colorScheme.primary,
            fontSize: context.scaledBodyFontSize,
          ),
        ),
        Expanded(
          child: TextField(
            controller: _terminalStateManager.textController,
            focusNode: _terminalStateManager.focusNode,
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colorScheme.primary,
              fontSize: context.scaledBodyFontSize,
            ),
            cursorWidth: 10,
            cursorHeight: 15,
            cursorColor: context.colorScheme.onSurfaceVariant,
            cursorRadius: Radius.zero,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) =>
                _terminalStateManager.handleSubmit(context.colorScheme),
            autofocus: true,
          ),
        ),
      ],
    );
  }
}
