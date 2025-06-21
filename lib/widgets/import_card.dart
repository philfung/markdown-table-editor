import 'package:flutter/material.dart';
import 'package:table_editor/widgets/card_utils.dart';
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
    return CardUtils.renderCard(context, 1, 'Import', 'Copy/Paste code below. Supports MD, GSheets, Excel.', [
      SizedBox(
        width:
            tableCellWidth *
            5, // Approximate width based on 5 columns of the data table
        child: TextField(
          key: textFieldKey,
          controller: exportController,
          maxLines: 2,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: textFieldBorderBackgroundColor),
            ),
            hintText:
                'Paste data here to import or edit text directly. Supports MD, Excel, and Google Sheets formats.',
            filled: true,
          ),
          style: TextStyle(
            fontFamily: textFieldFontFamily,
            fontSize: textFieldFontSize,
            color: textFieldTextColor,
          ),
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
    ]);
  }
}
