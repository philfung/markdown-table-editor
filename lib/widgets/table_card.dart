import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../styles.dart';
import '../data_parser.dart';

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
    this.additionalChildren = const [],
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
                Icon(Icons.table_chart, color: cardTitleTextColor, size: cardTitleIconSize),
                const SizedBox(width: 12),
                Text(
                  'Edit',
                  style: TextStyle(
                    color: cardTitleTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: cardTitleFontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTable(),
            ...additionalChildren,
          ],
        ),
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
              headingRowColor: WidgetStateProperty.all(tableHeadingBackgroundColor),
              border: TableBorder.all(color: tableBorderColor, borderRadius: BorderRadius.circular(tableBorderRadius)),
              columns: List.generate(
                tableData[0].length,
                (index) => DataColumn(
                  label: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      onCellTap(0, index);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        cellFocusNodes[0][index].requestFocus();
                      });
                    },
                    child: SizedBox(
                      width: tableCellWidth,
                      height: tableCellHeight,
                      child: isPreviewMode
                          ? ClipRect(
                              child: MarkdownBody(
                                data: tableData[0][index],
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(fontSize: tableCellFontSize, overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            )
                          : TextField(
                              controller: cellControllers[0][index],
                              focusNode: cellFocusNodes[0][index],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.all(tableCellPadding),
                              ),
                              style: TextStyle(
                                fontSize: tableCellFontSize,
                                overflow: TextOverflow.ellipsis,
                                color: cellControllers[0][index].text.contains('**') ? tableHeaderTextColor : tableTextColor,
                                fontWeight: cellControllers[0][index].text.contains('**') ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              rows: List.generate(
                tableData.length - 1,
                (rowIndex) {
                  final actualRowIndex = rowIndex + 1;
                  return DataRow(
                    cells: List.generate(
                      tableData[0].length,
                      (colIndex) => DataCell(
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            onCellTap(actualRowIndex, colIndex);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              cellFocusNodes[actualRowIndex][colIndex].requestFocus();
                            });
                          },
                          child: SizedBox(
                            width: tableCellWidth,
                            height: tableCellHeight,
                            child: isPreviewMode
                                ? ClipRect(
                                    child: Text(
                                      tableData[actualRowIndex][colIndex],
                                      style: TextStyle(
                                        fontSize: tableCellFontSize,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                : TextField(
                                    controller: cellControllers[actualRowIndex][colIndex],
                                    focusNode: cellFocusNodes[actualRowIndex][colIndex],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(tableCellPadding),
                                    ),
                                    style: TextStyle(
                                      fontSize: tableCellFontSize,
                                      overflow: TextOverflow.ellipsis,
                                      color: cellControllers[actualRowIndex][colIndex].text.contains('**') ? tableHeaderTextColor : tableTextColor,
                                      fontWeight: cellControllers[actualRowIndex][colIndex].text.contains('**') ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
