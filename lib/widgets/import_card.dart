import 'package:flutter/material.dart';
import '../styles.dart';
import '../data_parser.dart';

class ImportCard extends StatelessWidget {
  final GlobalKey textFieldKey;
  final GlobalKey exportButtonKey;
  final TextEditingController exportController;
  final DataFormat selectedExportFormat;
  final Function(DataFormat?) onFormatChanged;
  final Function(String) onTextChanged;
  final Function onCopyToClipboard;

  const ImportCard({
    Key? key,
    required this.textFieldKey,
    required this.exportButtonKey,
    required this.exportController,
    required this.selectedExportFormat,
    required this.onFormatChanged,
    required this.onTextChanged,
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
                    '1',
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
                    'Import',
                    style: TextStyle(
                      color: Colors.white, // This color will be overridden by the shader
                      fontWeight: FontWeight.bold,
                      fontSize: cardTitleFontSize,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: cardTitleSubtitleSpacing),
            Row(
              children: [
            Text(
              'Copy/Paste code below. Supports MD, GSheets, Excel.',
              style: TextStyle(
                color: cardSubtitleTextColor,
                fontSize: cardSubtitleFontSize,
                fontStyle: FontStyle.italic,
              ),
            ),              
            ]),
            const SizedBox(height: cardTitleSubtitleSpacing),
            SizedBox(
              width: tableCellWidth * 5, // Approximate width based on 5 columns of the data table
              child: TextField(
                key: textFieldKey,
                controller: exportController,
                maxLines: 2,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: textFieldBorderBackgroundColor)),
                  hintText: 'Paste data here to import or edit text directly. Supports MD, Excel, and Google Sheets formats.',
                  filled: true,
                ),
                style: TextStyle(fontFamily: textFieldFontFamily, fontSize: textFieldFontSize, color: textFieldTextColor),
                onChanged: onTextChanged,
                onTap: () {
                  if (exportController.text.isNotEmpty) {
                    exportController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: exportController.text.length,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: textFieldSpacing),
          ],
        ),
      ),
    );
  }
}
