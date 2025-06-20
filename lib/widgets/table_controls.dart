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
          spacing: 10,
          runSpacing: 10,
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
                  style: TextStyle(color: tableControlsSwitchTextColor, fontSize: tableControlsSwitchFontSize),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isPreviewMode,
                  onChanged: onModeChanged,
                  activeColor: tableControlsSwitchActiveColor,
                  activeTrackColor: tableControlsSwitchActiveTrackColor,
                  inactiveThumbColor: tableControlsSwitchInactiveThumbColor,
                  inactiveTrackColor: tableControlsSwitchInactiveTrackColor,
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
          label: Text(label, style: TextStyle(fontSize: actionChipFontSize, color: tableControlsButtonTextColor)),
          onPressed: onPressed,
          backgroundColor: tableControlsButtonBackgroundColor,
          side: BorderSide(color: tableControlsButtonBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
          padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
        );
}
