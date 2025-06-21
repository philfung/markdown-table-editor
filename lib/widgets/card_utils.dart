import 'package:flutter/material.dart';
import 'package:table_editor/styles.dart';

class CardUtils {
  static renderCard(
    BuildContext context,
    int index,
    String title,
    String subtitle,
    List<Widget> additionalChildren,
  ) {
    return Card(
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(cardPadding),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
