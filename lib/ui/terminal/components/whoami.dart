import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/app/app_colors.dart';
import 'package:sun_envidiado_website/constants/screen_widths.dart';
import 'package:sun_envidiado_website/utils/build_context_extensions.dart';

class WhoAmI extends StatelessWidget {
  const WhoAmI(this.fontScale, {super.key});

  final double fontScale;

  int get _yearsOfExperience =>
      DateTime.now().year - 2019; // I started coding in 2019

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context),
        _buildSpacing(context),
        // TODO Move text to database or API
        _buildColoredParagraph(
          context,
          'I\'m {Sun} — yes, that\'s actually my name — a software developer who\'s been building apps and websites for $_yearsOfExperience+ years. What started as curiosity about how software works has grown into something I genuinely care about – creating software that actually serves a purpose.',
        ),
        _buildSpacing(context),
        _buildColoredParagraph(
          context,
          'My journey took me through {JavaScript}, {PHP}, and {C#} before I found my way to {Flutter}. Each platform taught me something different, but {Flutter} clicked because I could build for both mobile and web without compromising on quality or user experience.',
        ),
        _buildSpacing(context),
        _buildColoredParagraph(
          context,
          'I code mostly for work but sometimes for fun too. My day job keeps me grounded in real business needs and constraints, while personal projects let me experiment and build things I actually want to use – like this website built with {Flutter}! Both teach me different lessons about what makes software truly useful.',
        ),
        _buildSpacing(context),
        _buildColoredParagraph(
          context,
          'My development method is what I call error-driven development. I write code, it breaks, I figure out why — repeat until stable. I\'ve tried to make peace with test-driven development, but the truth is I don\'t enjoy writing tests for code that doesn\'t exist yet. I prefer writing them when the shape of the solution is clear, and the code has already survived a few real-world bruises. I\'ve learned that clear, simple code that anyone can understand beats overengineered architectural slop every time. Good software doesn\'t need to impress other developers — it needs to work and be maintainable.',
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return SelectionArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1),
        width: context.screenWidth > ScreenWidths.tablet
            ? ScreenWidths.tablet
            : double.infinity,
        child: Center(
          child: Text(
            _sunText,
            style: context.textTheme.titleLarge?.copyWith(
              height: 1,
              color: AppColors.orange,
              fontSize: context.defaultBodyFontSize * fontScale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpacing(BuildContext context) {
    return SizedBox(height: context.defaultBodyFontSize * fontScale);
  }

  Widget _buildColoredParagraph(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      width: context.screenWidth > ScreenWidths.tablet
          ? ScreenWidths.tablet
          : double.infinity,
      child: SelectableText.rich(_parseColoredText(context, text)),
    );
  }

  TextSpan _parseColoredText(BuildContext context, String text) {
    final List<TextSpan> spans = [];
    final RegExp tagPattern = RegExp(r'\{([^}]+)\}');
    int lastEnd = 0;

    for (final match in tagPattern.allMatches(text)) {
      // Add text before the tag
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: _getDefaultTextStyle(context),
          ),
        );
      }

      // Add the colored tag
      final tagContent = match.group(1)!;
      spans.add(
        TextSpan(
          text: tagContent,
          style: _getColoredTextStyle(context, tagContent),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: _getDefaultTextStyle(context),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  TextStyle _getDefaultTextStyle(BuildContext context) {
    return context.textTheme.titleLarge!.copyWith(
      height: 1,
      color: AppColors.white,
      fontSize: context.defaultBodyFontSize * fontScale,
    );
  }

  TextStyle _getColoredTextStyle(BuildContext context, String word) {
    Color color = AppColors.white;

    switch (word.toLowerCase()) {
      case 'sun':
        color = AppColors.orange;
        break;
      case 'flutter':
        color = AppColors.cyan;
        break;
      case 'javascript':
        color = AppColors.yellow;
        break;
      case 'php':
        color = AppColors.magenta;
        break;
      case 'c#':
        color = AppColors.green;
        break;
    }

    return context.textTheme.titleLarge!.copyWith(
      height: 1,
      color: color,
      fontSize: context.defaultBodyFontSize * fontScale,
      fontWeight: word.toLowerCase() == 'sun'
          ? FontWeight.bold
          : FontWeight.normal,
    );
  }
}

const _sunText = r'''      ::::::::  :::    ::: ::::    ::: 
    :+:    :+: :+:    :+: :+:+:   :+:  
   +:+        +:+    +:+ :+:+:+  +:+   
  +#++:++#++ +#+    +:+ +#+ +:+ +#+    
        +#+ +#+    +#+ +#+  +#+#+#     
#+#    #+# #+#    #+# #+#   #+#+#      
########   ########  ###    ####       ''';
