import 'dart:async';
import 'dart:io' as io;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/app/app_colors.dart';
import 'package:sun_envidiado_website/constants/screen_widths.dart';
import 'package:sun_envidiado_website/constants/sun_ascii_sequence.dart';
import 'package:sun_envidiado_website/utils/build_context_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;

class Fastfetch extends StatefulWidget {
  const Fastfetch({super.key});

  @override
  State<Fastfetch> createState() => _FastfetchState();
}

class _FastfetchState extends State<Fastfetch> {
  Timer? _animationTimer;
  int _currentFrame = 0;
  late List<String> _frames;

  @override
  void initState() {
    super.initState();
    _initializeFrames();
    _startAnimation();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _initializeFrames() {
    final lines = SunAsciiSequence.sequence.split('\n');
    _frames = [];

    for (int i = 0; i < lines.length; i += SunAsciiSequence.linesPerFrame) {
      final frameLines = lines
          .skip(i)
          .take(SunAsciiSequence.linesPerFrame)
          .toList();
      // Remove empty lines at the end of each frame
      while (frameLines.isNotEmpty && frameLines.last.trim().isEmpty) {
        frameLines.removeLast();
      }
      if (frameLines.isNotEmpty) {
        _frames.add(frameLines.join('\n'));
      }
    }
  }

  void _startAnimation() {
    if (_frames.isEmpty) return;

    _animationTimer = Timer.periodic(const Duration(milliseconds: 800), (
      timer,
    ) {
      if (mounted) {
        setState(() {
          _currentFrame = (_currentFrame + 1) % _frames.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return context.screenWidth >= ScreenWidths.tablet
        ? _buildWithAsciiArt(context)
        : _buildContentOnly(context);
  }

  Widget _buildWithAsciiArt(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildAsciiArt(context),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildContent(context)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsciiArt(BuildContext context) {
    final currentArt = _frames.isNotEmpty ? _frames[_currentFrame] : '';

    return SelectableText.rich(
      TextSpan(
        text: currentArt,
        style: context.textTheme.bodySmall?.copyWith(
          color: AppColors.orange,
          fontSize: 13, // Fixed font size for ASCII art
          height: -1,
          // letterSpacing: 1.4,
          fontFeatures: const [
            FontFeature.tabularFigures(),
            FontFeature.enable('tnum'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fastfetchContent
          .map((info) => _buildInfoLine(context, info))
          .toList(),
    );
  }

  Widget _buildContentOnly(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fastfetchContent
          .map((info) => _buildInfoLine(context, info))
          .toList(),
    );
  }

  Widget _buildInfoLine(BuildContext context, Map<String, dynamic> info) {
    if (info['value']?.toString().isEmpty ?? true) {
      return const SizedBox(height: 14);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: SelectableText.rich(
        TextSpan(
          children: _buildInfoSpans(context, info),
          style: context.textTheme.titleLarge?.copyWith(height: 1),
        ),
      ),
    );
  }

  List<InlineSpan> _buildInfoSpans(
    BuildContext context,
    Map<String, dynamic> info,
  ) {
    final label = info['label'] ?? '';
    final value = info['value'] ?? '';
    final color = info['color'] ?? '';
    final url = info['url'];

    final colorMap = {
      'yellow': AppColors.yellow,
      'magenta': AppColors.magenta,
      'orange': const Color(0xFFFFB86C),
      'cyan': AppColors.cyan,
      'green': AppColors.green,
      'divider': AppColors.gray,
    };

    final textColor = colorMap[color] ?? AppColors.white;

    return [
      if (label.isNotEmpty)
        TextSpan(
          text: '$label: ',
          style: context.textTheme.titleLarge?.copyWith(
            color: AppColors.lightGray,
            fontSize: context.scaledBodyFontSize,
            height: 1,
          ),
        ),
      if (value.isNotEmpty)
        TextSpan(
          text: value,
          style: context.textTheme.titleLarge?.copyWith(
            color: textColor,
            fontSize: context.scaledBodyFontSize,
            decoration: url != null ? TextDecoration.underline : null,
            decorationColor: url != null ? textColor : null,
            height: 1,
          ),
          recognizer: url != null
              ? (TapGestureRecognizer()
                  ..onTap = () => launchUrl(Uri.parse(url)))
              : null,
        ),
    ];
  }

  String get currentPlatform {
    if (kIsWeb) {
      final userAgent = web.window.navigator.userAgent.toLowerCase();
      if (userAgent.contains('windows')) return 'windows';
      if (userAgent.contains('mac')) return 'macos';
      if (userAgent.contains('linux')) return 'linux';
      if (userAgent.contains('android')) return 'android';
      if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
        return 'ios';
      }
      return 'browser';
    } else {
      return io.Platform.operatingSystem;
    }
  }

  // TODO Move to a database or API
  List<Map<String, dynamic>> get fastfetchContent => [
    {'label': 'OS', 'value': currentPlatform, 'color': 'cyan'},
    {'label': 'Alias', 'value': 'Sun', 'color': 'cyan'},
    {'label': 'Location', 'value': 'Manila, Philippines', 'color': 'cyan'},
    {'label': 'Work', 'value': 'Software Developer', 'color': 'cyan'},
    {
      'label': 'Domain',
      'value': 'sun-envidiado.com',
      'color': 'cyan',
      'url': 'https://sun-envidiado.com',
    },
    {'label': 'Site', 'value': 'Built with Flutter', 'color': 'cyan'},
    {'label': '', 'value': '', 'color': ''},
    {
      'label': 'Interests',
      'value': 'Gaming, Singing, Running (away from problems)',
      'color': 'yellow',
    },
    {'label': 'Currently Playing', 'value': 'Helldivers 2', 'color': 'yellow'},
    {'label': '', 'value': '', 'color': ''},
    {
      'label': 'Fun Fact',
      'value': 'I can eat a whole pizza by myself.',
      'color': 'magenta',
    },
    {
      'label': 'Status',
      'value': 'Probably overthinking something',
      'color': 'magenta',
    },
    {'label': '', 'value': '', 'color': ''},
    {
      'label': 'Email',
      'value': 'sunadriann31@gmail.com',
      'color': 'green',
      'url': 'mailto:sunadriann31@gmail.com',
    },
    {
      'label': 'LinkedIn',
      'value': '/in/sunenvidiado',
      'color': 'green',
      'url': 'https://linkedin.com/in/sunenvidiado/',
    },
    {
      'label': 'GitHub',
      'value': '@photosunthesis',
      'color': 'green',
      'url': 'https://github.com/photosunthesis',
    },
    {'label': '', 'value': '', 'color': ''},
    {
      'label': '',
      'value': '© ${DateTime.now().year} Sun Envidiado. All rights reserved.',
      'color': 'divider',
    },
  ];
}
