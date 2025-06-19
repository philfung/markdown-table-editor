import 'package:flutter/material.dart';
import '../styles.dart';
import '../data_parser.dart';

class TextCard extends StatelessWidget {
  final GlobalKey textFieldKey;
  final GlobalKey exportButtonKey;
  final TextEditingController exportController;
  final DataFormat selectedExportFormat;
  final Function(DataFormat?) onFormatChanged;
  final Function(String) onTextChanged;
  final Function onCopyToClipboard;

  const TextCard({
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
                Icon(Icons.text_fields, color: cardTitleTextColor, size: cardTitleIconSize),
                const SizedBox(width: 12),
                Text(
                  'Import / Export',
                  style: TextStyle(
                    color: cardTitleTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: cardTitleFontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('Format: ', style: TextStyle(color: dropdownLabelTextColor)),
                const SizedBox(width: 10),
                DropdownButton<DataFormat>(
                  value: selectedExportFormat,
                  style: const TextStyle(color: dropdownTextColor),
                  dropdownColor: dropdownBackgroundColor,
                  onChanged: onFormatChanged,
                  items: DataFormat.values.map<DropdownMenuItem<DataFormat>>((DataFormat value) {
                    return DropdownMenuItem<DataFormat>(
                      value: value,
                      child: Text(DataParser.getFormatDisplayName(value)),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: textFieldSpacing),
            TextField(
              key: textFieldKey,
              controller: exportController,
              maxLines: textFieldMaxLines,
              decoration: const InputDecoration(
                hintText: 'Paste data here to import or edit text directly. Supports Markdown, CSV, and Google Sheets formats.',
                hintStyle: TextStyle(color: textFieldTextColor),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: textFieldBackgroundColor,
              ),
              style: const TextStyle(fontFamily: textFieldFontFamily, fontSize: textFieldFontSize, color: textFieldTextColor),
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
            const SizedBox(height: textFieldSpacing),
            ElevatedButton.icon(
              key: exportButtonKey,
              onPressed: () => onCopyToClipboard(),
              icon: const Icon(Icons.copy),
              label: const Text('Export to Clipboard', style: TextStyle(fontSize: actionChipFontSize)),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
                foregroundColor: tableTextColor,
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
