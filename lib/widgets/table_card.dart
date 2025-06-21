import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:table_editor/widgets/card_utils.dart';
import '../styles.dart';
import '../data_parser.dart';
// Conditional import for web platform only
import 'dart:html' if (dart.library.html) 'dart:html' as html;

class TableCard extends StatelessWidget {
  final GlobalKey tableKey;
  final bool isPreviewMode;
  final int? selectedRowIndex;
  final int? selectedColIndex;
  final List<List<String>> tableData;
  final List<List<TextEditingController>> cellControllers;
  final List<List<FocusNode>> cellFocusNodes;
  final ScrollController verticalScrollController;
  final ScrollController horizontalScrollController;
  final Function(int, int) onCellTap;
  final Function(bool) onModeChanged;
  final List<Widget> additionalChildren;

  const TableCard({
    Key? key,
    required this.tableKey,
    required this.isPreviewMode,
    required this.selectedRowIndex,
    required this.selectedColIndex,
    required this.tableData,
    required this.cellControllers,
    required this.cellFocusNodes,
    required this.verticalScrollController,
    required this.horizontalScrollController,
    required this.onCellTap,
    required this.onModeChanged,
    this.additionalChildren = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardUtils.renderCard(
      context: context,
      index: 2,
      title: 'Edit',
      subtitle: 'Click cell to edit. ',
      additionalChildren: [_buildTable(), ...additionalChildren],
      upperRightWidget: Row(
        children: [
          Text(
            isPreviewMode ? 'Preview Mode' : 'Edit Mode',
            style: TextStyle(
              color: tableControlsSwitchTextColor,
              fontSize: tableControlsSwitchFontSize,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 10, // hack: set to small number so switch renders to transformed scale
            alignment: Alignment.center,
            child: Transform.scale(
              scaleY: tableControlsSwitchScale,
              scaleX: tableControlsSwitchScale,
              child: Switch(
                value: isPreviewMode,
                onChanged: onModeChanged,
                activeColor: tableControlsSwitchActiveColor,
                activeTrackColor: tableControlsSwitchActiveTrackColor,
                inactiveThumbColor: tableControlsSwitchInactiveThumbColor,
                inactiveTrackColor: tableControlsSwitchInactiveTrackColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    if (tableData.isEmpty || cellControllers.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return SizedBox(
      key: tableKey,
      height: tableHeight, // Set a reasonable maximum height for the table
      child: ClipRect(
        child: SingleChildScrollView(
          controller: verticalScrollController,
          child: SingleChildScrollView(
            controller: horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: tableHeadingRowHeight,
              dataRowMinHeight: tableDataRowMinHeight,
              dataRowMaxHeight: tableDataRowMaxHeight,
              headingRowColor: WidgetStateProperty.all(
                tableHeadingBackgroundColor,
              ),
              border: TableBorder.all(
                color: whiteColor,
                borderRadius: BorderRadius.circular(tableBorderRadius),
              ),
              columns: List.generate(
                tableData[0].length,
                (index) => DataColumn(label: _buildCellContent(0, index)),
              ),
              rows: List.generate(tableData.length - 1, (rowIndex) {
                final actualRowIndex = rowIndex + 1;
                return DataRow(
                  cells: List.generate(
                    tableData[0].length,
                    (colIndex) =>
                        DataCell(_buildCellContent(actualRowIndex, colIndex)),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(int rowIndex, int colIndex) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onCellTap(rowIndex, colIndex);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cellFocusNodes[rowIndex][colIndex].requestFocus();
        });
      },
      child: SizedBox(
        width: tableCellWidth,
        height: tableCellHeight,
        child: isPreviewMode
            ? ClipRect(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: tableCellWidth,
                    maxHeight: tableCellHeight,
                  ),
                  child: Center(
                    child: MarkdownBody(
                      data: tableData[rowIndex][colIndex],
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: tableCellFontSize,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          try {
                            html.window.open(href, '_blank');
                          } catch (e) {
                            // Fallback for non-web platforms or if html is not available
                            print('Could not open link: $href');
                          }
                        }
                      },
                    ),
                  ),
                ),
              )
            : ClipRect(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: tableCellWidth,
                    maxHeight: tableCellHeight,
                  ),
                  child: TextField(
                    controller: cellControllers[rowIndex][colIndex],
                    focusNode: cellFocusNodes[rowIndex][colIndex],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.all(tableCellPadding),
                    ),
                    style: TextStyle(
                      fontSize: tableCellFontSize,
                      overflow: TextOverflow.ellipsis,
                      color:
                          cellControllers[rowIndex][colIndex].text.contains(
                            '**',
                          )
                          ? tableHeaderTextColor
                          : tableTextColor,
                      fontWeight:
                          cellControllers[rowIndex][colIndex].text.contains(
                            '**',
                          )
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1, // Enforce single line with ellipsis
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),
      ),
    );
  }
}
