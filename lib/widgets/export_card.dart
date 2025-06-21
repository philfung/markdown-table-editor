import 'package:flutter/material.dart';
import 'package:table_editor/widgets/card_utils.dart';
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
    return CardUtils.renderCard(
      context: context,
      index: 3,
      title: 'Export',
      subtitle: '',
      additionalChildren: [
        const SizedBox(height: cardTitleSubtitleSpacing),
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
              isDense: true,
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
              underline: Container(height: 1, color: buttonBorderColor),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // const SizedBox(height: 2),
        ElevatedButton.icon(
          key: exportButtonKey,
          onPressed: () => onCopyToClipboard(),
          icon: const Icon(Icons.copy),
          label: const Text(
            'Export to Clipboard',
            style: TextStyle(fontSize: actionChipFontSize),
          ),
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
      upperRightWidget: null,
    );
  }
}
