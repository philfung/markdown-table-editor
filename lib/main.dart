import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'data_parser.dart';

// Constants for dimensions
const double columnWidth = 150.0;
const int initialHeaders = 3;
const int snackbarDurationSeconds = 2;
const double syncIconSize = 40.0;
const double tableHeight = 180.0;
const double tableIconSize = 24.0;

List<List<String>> tableData = [
  ['**Header 1**', '**Header 2**', '**Header 3**'],
  ['Row 1, Cell 1', 'Row 1, Cell 2', 'Row 1, Cell 3'],
  ['Row 2, Cell 1', 'Row 2, Cell 2', 'Row 2, Cell 3']
];

void main() {
  runApp(const TableEditorApp());
}

class TableEditorApp extends StatelessWidget {
  const TableEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadTheme(
      data: ShadThemeData(
        colorScheme: ShadColorScheme.fromName('green', brightness: Brightness.light),
        brightness: Brightness.light,
      ),
      child: MaterialApp(
        title: 'Markdown Table Editor',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const TableEditorPage(),
      ),
    );
  }
}

class TableEditorPage extends StatefulWidget {
  const TableEditorPage({super.key});

  @override
  State<TableEditorPage> createState() => _TableEditorPageState();
}

class _TableEditorPageState extends State<TableEditorPage> {

  final TextEditingController importController = TextEditingController();
  final TextEditingController exportController = TextEditingController();
  DataFormat selectedExportFormat = DataFormat.markdown;
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool isPreviewMode = true;
  int? selectedRowIndex;
  int? selectedColIndex;

  // Controllers for table cells
  List<List<TextEditingController>> cellControllers = [];
  List<List<FocusNode>> cellFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _initializeCellControllers();
    updateExportOutput();
  }

  @override
  void dispose() {
    importController.dispose();
    exportController.dispose();
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    _disposeCellControllers();
    super.dispose();
  }

  void _initializeCellControllers() {
    _disposeCellControllers();
    cellControllers = List.generate(
      tableData.length,
      (rowIndex) => List.generate(
        tableData[rowIndex].length,
        (colIndex) => TextEditingController(text: tableData[rowIndex][colIndex]),
      ),
    );
    cellFocusNodes = List.generate(
      tableData.length,
      (rowIndex) => List.generate(
        tableData[rowIndex].length,
        (colIndex) => FocusNode(),
      ),
    );

    // Add listeners to update tableData when controllers change
    for (int rowIndex = 0; rowIndex < cellControllers.length; rowIndex++) {
      for (int colIndex = 0; colIndex < cellControllers[rowIndex].length; colIndex++) {
        final row = rowIndex;
        final col = colIndex;
        cellControllers[rowIndex][colIndex].addListener(() {
          tableData[row][col] = cellControllers[row][col].text;
          updateExportOutput();
        });
      }
    }
  }

  void _disposeCellControllers() {
    for (var row in cellControllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    for (var row in cellFocusNodes) {
      for (var focusNode in row) {
        focusNode.dispose();
      }
    }
    cellControllers.clear();
    cellFocusNodes.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'images/table_icon.svg',
              width: tableIconSize,
              height: tableIconSize,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Markdown Table Editor'),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            isPreviewMode = true;
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTableCard(),
              const SizedBox(height: 10),
              Center(
                child: SvgPicture.asset(
                  'images/sync.svg',
                  width: syncIconSize,
                  height: syncIconSize,
                  colorFilter: ColorFilter.mode(
                    Colors.green,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildTextCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.table_chart, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  'Table',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTable(),
            const SizedBox(height: 20),
            _buildTableControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.text_fields, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  'Text',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Format: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                DropdownButton<DataFormat>(
                  value: selectedExportFormat,
                  onChanged: (DataFormat? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedExportFormat = newValue;
                        updateExportOutput();
                      });
                    }
                  },
                  items: DataFormat.values.map<DropdownMenuItem<DataFormat>>((DataFormat value) {
                    return DropdownMenuItem<DataFormat>(
                      value: value,
                      child: Text(DataParser.getFormatDisplayName(value)),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: exportController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Paste data here to import or edit text directly. Supports Markdown, CSV, and Google Sheets formats.',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  _handlePastedData(value.trim());
                }
              },
              onTap: () {
                if (exportController.text.isNotEmpty) {
                  exportController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: exportController.text.length,
                  );
                }
              },
            ),
            const SizedBox(height: 15),
            Center(
              child: ShadButton(
                onPressed: _copyToClipboard,
                leading: const Icon(Icons.copy),
                child: const Text('Copy to Clipboard'),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
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
      height: tableHeight, // Set a reasonable maximum height for the table
      child: ClipRect(
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              border: TableBorder.all(color: Colors.grey),
              columns: List.generate(
                tableData[0].length,
                (index) => DataColumn(
                  label: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        isPreviewMode = false;
                        selectedRowIndex = 0;
                        selectedColIndex = index;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          cellFocusNodes[0][index].requestFocus();
                        });
                      });
                    },
child: SizedBox(
  width: columnWidth,
                      child: isPreviewMode
                          ? MarkdownBody(
                              data: tableData[0][index],
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(fontSize: 14),
                              ),
                            )
                          : TextField(
                              controller: cellControllers[0][index],
                              focusNode: cellFocusNodes[0][index],
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(overflow: TextOverflow.ellipsis),
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
                            setState(() {
                              isPreviewMode = false;
                              selectedRowIndex = actualRowIndex;
                              selectedColIndex = colIndex;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                cellFocusNodes[actualRowIndex][colIndex].requestFocus();
                              });
                            });
                          },
                          child: SizedBox(
                            width: columnWidth,
                            child: isPreviewMode
                                ? Container(
                                    // Ensure minimum tappable area for empty cells
                                    constraints: BoxConstraints(minHeight: 30),
                                    child: MarkdownBody(
                                      data: tableData[actualRowIndex][colIndex].isEmpty 
                                          ? " " 
                                          : tableData[actualRowIndex][colIndex],
                                      styleSheet: MarkdownStyleSheet(
                                        p: TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis),
                                      ),
                                      onTapLink: (text, href, title) async {
                                        if (href != null) {
                                          final Uri url = Uri.parse(href);
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          }
                                        }
                                      },
                                    ),
                                  )
                                : TextField(
                                    controller: cellControllers[actualRowIndex][colIndex],
                                    focusNode: cellFocusNodes[actualRowIndex][colIndex],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(overflow: TextOverflow.ellipsis),
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

  Widget _buildTableControls() {
    return Wrap(
      spacing: 10,
      children: [
        ShadButton(
          onPressed: _addRow,
          child: const Text('Add Row'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        ShadButton(
          onPressed: _addColumn,
          child: const Text('Add Column'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        ShadButton.secondary(
          onPressed: _deleteRow,
          child: const Text('Delete Row'),
        ),
        ShadButton.secondary(
          onPressed: _deleteColumn,
          child: const Text('Delete Column'),
        ),
        ShadButton.destructive(
          onPressed: _clearTable,
          child: const Text('Clear Table'),
        ),
        ShadButton.secondary(
          onPressed: () {
            setState(() {
              isPreviewMode = !isPreviewMode;
            });
          },
          backgroundColor: isPreviewMode ? Colors.grey : Colors.blue,
          foregroundColor: Colors.white,
          child: Text(isPreviewMode ? 'Preview Mode' : 'Edit Mode'),
        ),
      ],
    );
  }

  void updateExportOutput() {
    String output = '';
    switch (selectedExportFormat) {
      case DataFormat.markdown:
        output = DataParser.generateMarkdown(tableData);
        break;
      case DataFormat.gsheets:
        output = DataParser.generateGoogleSheets(tableData);
        break;
      case DataFormat.csv:
        output = DataParser.generateCSV(tableData);
        break;
    }
    exportController.text = output;
  }

  void _handlePastedData(String data) {
    final detectedFormat = DataParser.detectDataFormat(data);

    if (detectedFormat != null) {
      final formatName = DataParser.getFormatDisplayName(detectedFormat);
      setState(() {
        selectedExportFormat = detectedFormat;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Import Data'),
            content: Text('Detected $formatName data. Do you want to import this data into the table?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  updateExportOutput();
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _importTableData(data, detectedFormat);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Import Error'),
            content: const Text('This text is not recognized as a recognizable format (Google Sheets, CSV, or Markdown table).'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  updateExportOutput();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _importTableData(String data, DataFormat format) {
    final parsedData = DataParser.parseData(data, format);
    if (parsedData.isNotEmpty) {
      setState(() {
        tableData = parsedData;
        _initializeCellControllers();
        updateExportOutput();
      });
    }
  }

  void _addRow() {
    setState(() {
      if (tableData.isEmpty) {
        tableData = [['']];
      } else {
        final columnCount = tableData[0].length;
        final newRow = List.generate(columnCount, (index) => '');
        tableData = List.from(tableData)..add(newRow);
      }
      _initializeCellControllers();
      updateExportOutput();
      // Scroll to the bottom after adding a row
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verticalScrollController.animateTo(
          _verticalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void _addColumn() {
    setState(() {
      if (tableData.isEmpty) {
        tableData = [['']];
      } else {
        // Add a new column to each row
        for (int i = 0; i < tableData.length; i++) {
          tableData[i] = List.from(tableData[i])..add('');
        }
      }
      _initializeCellControllers();
      updateExportOutput();
      // Scroll to the right after adding a column
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _horizontalScrollController.animateTo(
          _horizontalScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  void _deleteRow() {
    setState(() {
      if (tableData.length > 1) {
        tableData.removeLast();
        _initializeCellControllers();
        updateExportOutput();
      }
    });
  }

  void _deleteColumn() {
    setState(() {
      if (tableData.isNotEmpty && tableData[0].length > 1) {
        for (int i = 0; i < tableData.length; i++) {
          if (tableData[i].isNotEmpty) {
            tableData[i] = List.from(tableData[i])..removeLast();
          }
        }
        _initializeCellControllers();
        updateExportOutput();
      }
    });
  }

  void _clearTable() {
    setState(() {
      tableData = List.generate(1, (_) => List.generate(initialHeaders, (index) => index == 0 ? '**Header ${index + 1}**' : 'Header ${index + 1}'));
      _initializeCellControllers();
      updateExportOutput();
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: exportController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${DataParser.getFormatDisplayName(selectedExportFormat)} data copied to clipboard!'),
        duration: const Duration(seconds: snackbarDurationSeconds),
      ),
    );
  }
}
