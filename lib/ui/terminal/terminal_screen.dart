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
    final fontScale = _getFontScale(context.screenWidth);

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
                            fontScale: fontScale,
                            showAsciiArt:
                                context.screenWidth >= ScreenWidths.tablet,
                          ),
                        ),
                        _buildInput(fontScale),
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

  // Helper method to determine font scale based on screen width
  double _getFontScale(double screenWidth) => switch (screenWidth) {
    < ScreenWidths.mobile => 0.6,
    < ScreenWidths.tablet => 0.7,
    < ScreenWidths.desktop => 1.0,
    _ => 1.0,
  };

  Widget _buildTerminalContent(
    TerminalContent content, {
    required double fontScale,
    required bool showAsciiArt,
  }) {
    return SelectionArea(
      child: switch (content) {
        final TerminalText text => _buildTerminalText(text, fontScale),
        final TerminalCommand command => _buildTerminalCommand(
          command,
          fontScale,
          showAsciiArt,
        ),
      },
    );
  }

  Widget _buildTerminalCommand(
    TerminalCommand command,
    double fontScale,
    bool showAsciiArt,
  ) {
    return switch (command.command) {
      Commands.whoami => WhoAmI(fontScale),
      Commands.work => Work(fontScale),
      Commands.fastfetch => Fastfetch(
        fontScale: fontScale,
        showAsciiArt: showAsciiArt,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildTerminalText(TerminalText text, double fontScale) {
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
                    fontSize:
                        (span.style?.fontSize ?? context.defaultBodyFontSize) *
                        fontScale,
                  ),
                  recognizer: span.recognizer,
                );
              }
              return span;
            }).toList(),
            style: context.textTheme.titleLarge?.copyWith(
              fontSize:
                  (context.textTheme.titleLarge?.fontSize ??
                      context.defaultBodyFontSize) *
                  fontScale,
            ),
          ),
        ),
      );
    }
    final textWidget = Text(
      text.text ?? '',
      style: context.textTheme.titleLarge?.copyWith(
        color: text.color ?? context.colorScheme.primary,
        fontSize:
            (context.textTheme.titleLarge?.fontSize ??
                context.defaultBodyFontSize) *
            fontScale,
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

  Widget _buildInput(double fontScale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r'guest@terminal:~ $  ',
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colorScheme.primary,
            fontSize:
                (context.textTheme.titleLarge?.fontSize ??
                    context.defaultBodyFontSize) *
                fontScale,
          ),
        ),
        Expanded(
          child: TextField(
            controller: _terminalStateManager.textController,
            focusNode: _terminalStateManager.focusNode,
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colorScheme.primary,
              fontSize:
                  (context.textTheme.titleLarge?.fontSize ??
                      context.defaultBodyFontSize) *
                  fontScale,
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
