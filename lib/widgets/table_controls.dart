import 'package:flutter/material.dart';
import '../styles.dart';
import '../data_parser.dart';

class TableControls extends StatelessWidget {
  final bool isPreviewMode;
  final Function(bool) onModeChanged;
  final Function onAddRow;
  final Function onAddColumn;
  final Function onDeleteRow;
  final Function onDeleteColumn;
  final Function onReset;

  const TableControls({
    Key? key,
    required this.isPreviewMode,
    required this.onModeChanged,
    required this.onAddRow,
    required this.onAddColumn,
    required this.onDeleteRow,
    required this.onDeleteColumn,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 5,
          runSpacing: 5,
          children: [
            _TableEditorActionChip(label: '+ Row', onPressed: () => onAddRow()),
            _TableEditorActionChip(label: '- Row', onPressed: () => onDeleteRow()),
            _TableEditorActionChip(label: '+ Col', onPressed: () => onAddColumn()),
            _TableEditorActionChip(label: '- Col', onPressed: () => onDeleteColumn()),
            _TableEditorActionChip(label: 'Reset', onPressed: () => onReset()),
            Row(
              children: [
                Text(
                  isPreviewMode ? 'Preview Mode' : 'Edit Mode',
                  style: TextStyle(color: switchTextColor, fontSize: switchFontSize),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isPreviewMode,
                  onChanged: onModeChanged,
                  activeColor: buttonHighlightedBackgroundColor,
                  activeTrackColor: buttonBackgroundColor,
                  inactiveThumbColor: buttonTextColor,
                  inactiveTrackColor: buttonBorderColor,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _TableEditorActionChip extends ActionChip {
  _TableEditorActionChip({
    Key? key,
    required String label,
    required VoidCallback onPressed,
  }) : super(
          key: key,
          label: Text(label, style: TextStyle(fontSize: actionChipFontSize, color: buttonTextColor)),
          onPressed: onPressed,
          backgroundColor: buttonBackgroundColor,
          side: BorderSide(color: buttonBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
          padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
        );
}
