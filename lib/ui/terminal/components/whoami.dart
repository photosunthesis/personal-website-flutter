import 'package:flutter/material.dart';
import 'package:sun_envidiado_website/app/app_colors.dart';
import 'package:sun_envidiado_website/constants/screen_widths.dart';
import 'package:sun_envidiado_website/utils/build_context_extensions.dart';

const _whoAmIAscii =
    r'''                _                                             __ 
    _    _     FJ___      ____         ___ _    _ _____       LJ 
   FJ .. L]   J  __ `.   F __ J       F __` L  J '_  _ `,        
  | |/  \| |  | |--| |  | |--| |     | |--| |  | |_||_| |     FJ 
  F   /\   J  F L  J J  F L__J J     F L__J J  F L LJ J J    J  L
 J\__//\\__/LJ__L  J__LJ\______/F   J\____,__LJ__L LJ J__L   J__L
  \__/  \__/ |__L  J__| J______F     J____,__F|__L LJ J__|   |__|
                                                                 ''';

class WhoAmI extends StatelessWidget {
  const WhoAmI({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.scaledBodyFontSize,
      children: [
        if (context.screenWidth >= ScreenWidths.tablet) _buildTitle(context),
        // TODO Move text to database or API
        _buildColoredParagraph(
          context,
          'I\'m {Sun}, a software developer based in {Manila, Philippines}. I enjoy building things, and this website is one of them.',
        ),
        _buildColoredParagraph(
          context,
          'When I\'m not coding, I\'m probably {gaming} (currently hooked on {Helldivers 2}) or singing my heart out at a {karaoke} place. I built this site with {Flutter} to have my own little corner of the internet.',
        ),
        _buildColoredParagraph(
          context,
          'The terminal aesthetic is a throwback to my love for command-line interfaces, which started when I switched from {Windows} to {Linux}. This is where I\'ll share my thoughts on gaming, coding, and anything else that catches my interest.',
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return SelectionArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 50, context.screenWidth * 0.06, 50),
        width: context.screenWidth > ScreenWidths.tablet
            ? ScreenWidths.tablet
            : double.infinity,
        child: Center(
          child: Text(
            _whoAmIAscii,
            style: context.textTheme.titleLarge?.copyWith(
              height: 1,
              color: AppColors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 13, // Fixed font size for ASCII art
            ),
          ),
        ),
      ),
    );
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
      fontSize: context.scaledBodyFontSize,
    );
  }

  TextStyle _getColoredTextStyle(BuildContext context, String word) {
    final lowerCaseWord = word.toLowerCase();
    final color = switch (lowerCaseWord) {
      'sun' => AppColors.orange,
      'flutter' || 'windows' => AppColors.cyan,
      'manila, philippines' => AppColors.magenta,
      'manila, philippines' || 'helldivers 2' => AppColors.yellow,
      'linux' || 'gaming' || 'karaoke' => AppColors.green,
      _ => AppColors.white,
    };

    return context.textTheme.titleLarge!.copyWith(
      height: 1,
      color: color,
      fontSize: context.scaledBodyFontSize,
      fontWeight: lowerCaseWord == 'sun' ? FontWeight.bold : FontWeight.normal,
    );
  }
}
