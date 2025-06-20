import 'package:flutter/material.dart';
import '../styles.dart';
import '../data_parser.dart';

class ExportCard extends StatelessWidget {
  final GlobalKey exportButtonKey;
  final TextEditingController exportController;
  final DataFormat selectedExportFormat;
  final Function(DataFormat?) onFormatChanged;
  final Function onCopyToClipboard;

  const ExportCard({
    Key? key,
    required this.exportButtonKey,
    required this.exportController,
    required this.selectedExportFormat,
    required this.onFormatChanged,
    required this.onCopyToClipboard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    return cardTitleGradient.createShader(bounds);
                  },
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white, // This color will be overridden by the shader
                      fontSize: cardTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return cardTitleGradient.createShader(bounds);
                  },
                  child: Text(
                    'Export',
                    style: TextStyle(
                      color: Colors.white, // This color will be overridden by the shader
                      fontWeight: FontWeight.bold,
                      fontSize: cardTitleFontSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            Row(
              children: [
                Text(
                  'Format:',
                  style: TextStyle(
                    color: cardSubtitleTextColor,
                    fontSize: exportFormatFontSize,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<DataFormat>(
                  value: selectedExportFormat,
                  onChanged: onFormatChanged,
                  items: DataFormat.values.map((DataFormat format) {
                    return DropdownMenuItem<DataFormat>(
                      value: format,
                      child: Text(
                        DataParser.getFormatDisplayName(format),
                        style: TextStyle(
                          color: cardSubtitleTextColor,
                          fontSize: exportFormatFontSize,
                        ),
                      ),
                    );
                  }).toList(),
                  dropdownColor: cardBackgroundColor,
                  underline: Container(
                    height: 2,
                    color: buttonBorderColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            ElevatedButton.icon(
              key: exportButtonKey,
              onPressed: () => onCopyToClipboard(),
              icon: const Icon(Icons.copy),
              label: const Text('Export to Clipboard', style: TextStyle(fontSize: actionChipFontSize)),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonBorderRadius),
                  side: BorderSide(color: buttonBorderColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
