import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:table_editor/widgets/card_utils.dart';
import '../styles.dart';
import '../data_parser.dart';

class ImportCard extends StatefulWidget {
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
  _ImportCardState createState() => _ImportCardState();
}

class _ImportCardState extends State<ImportCard> {
  late ScrollController _scrollController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _focusNode = FocusNode()
      ..addListener(() {
        if (!_focusNode.hasFocus) {
          _scrollController.jumpTo(0);
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CardUtils.renderCard(
      context: context,
      index: 1,
      title: 'Import',
      subtitle: 'Copy/Paste code below. Supports MD, GSheets, Excel.',
      additionalChildren: [
        SizedBox(
          width:
              Math.max(MediaQuery.of(context).size.width - 300, 400), 
          child: TextField(
            key: widget.textFieldKey,
            controller: widget.exportController,
            maxLines: 2,
            scrollController: _scrollController,
            focusNode: _focusNode,
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
            onChanged: widget.onTextChanged,
            onTap: () {
              if (widget.exportController.text.isNotEmpty) {
                widget.exportController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: widget.exportController.text.length,
                );
              }
            },
          ),
        ),
      ],
      upperRightWidget: null,
    );
  }
}
