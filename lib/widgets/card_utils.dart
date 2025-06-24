import 'package:flutter/material.dart';
import 'package:table_editor/styles.dart';

class CardUtils {
  static renderCard({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    required List<Widget> additionalChildren,
    required Widget? upperRightWidget,
  }) {
    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(cardPaddingLeftRight, cardPaddingTopDown, cardPaddingLeftRight, cardPaddingTopDown),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return appTitleGradient.createShader(bounds);
                  },
                  child: Text(
                    '${index}  $title',
                    style: const TextStyle(
                      color: Colors
                          .white, // This color will be overridden by the shader
                      fontSize: cardTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (upperRightWidget != null) upperRightWidget,
              ],
            ),
            ...(subtitle.isNotEmpty
                ? ([
                    const SizedBox(height: cardTitleSubtitleSpacing),
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: cardSubtitleTextColor,
                            fontSize: cardSubtitleFontSize,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: cardTitleSubtitleSpacing),
                  ])
                : []),
            ...additionalChildren,
          ],
        ),
      ),
    );
  }
}
