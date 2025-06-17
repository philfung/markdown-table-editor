import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data_parser.dart';

// Strings
const String appTitle = 'Markdown Table Editor';

const Color appBarBackgroundColor = Color(0xFF171717); // dark background
const Color appBarIconColor = Color(0xFFFAFAFA); // white
const Color appBarSurfaceTintColor = Colors.blue; // default blue
const Color appBarTextColor = Color(0xFFFAFAFA); // white
const Color backgroundColor = Color(0xFF0A0A0A); // dark dark
const Color buttonBackgroundColor = Color(0xFF212121); // dark gray
const Color buttonBorderColor = Color(0xFF3A3A3A); // light gray
const Color buttonHighlightedBackgroundColor = Color(0xFFE5E5E5); // very light gray
const Color buttonHighlightedBorderColor = Color(0xFF717171); // light gray
const Color buttonTextColor = Color(0xFFF0F0F0); // light gray
const Color cardBackgroundColor = Color(0xFF171717); // dark background
const Color cardBorderColor = Color(0xFF2E2E2E); // light gray
const Color cardTitleTextColor = Color(0xFFF6F6F6); // white
const Color dividerColor = Color(0xFF2E2E2E); // light gray
const Color dropdownBackgroundColor = Color(0xFF212121); // dark gray
const Color dropdownBorderColor = Color(0xFF434343); // dark gray
const Color dropdownTextColor = Color(0xFFFAFAFA); // white
const Color headerBackgroundColor = Color(0xFF1F1F1F); // dark gray
const Color headerTextColor = Color(0xFFFAFAFA); // white
Color onboardingFontColor = Colors.blue.shade700; // light gray
const Color placeholderTextColor = Color(0xFFA1A1A1); // light gray
const Color switchTextColor = Color(0xFFFAFAFA); // white
const Color syncIconColor = Color(0xFFA1A1A1); 
const Color tableBorderColor = Color(0xFF2E2E2E); // light gray
const Color tableDataRowColor = Color(0xFF2E2E2E); // light gray
const Color tableHeaderCellBackgroundColor = Color(0xFF1F1F1F); // dark gray
const Color tableHeaderTextColor = Color(0xFFFAFAFA); // white
const Color tableHeadingBackgroundColor = Color(0xFF1F1F1F); // dark gray
const Color tableNormalCellBackgroundColor = Color(0xFF171717); // dark background
const Color tableTextColor = Color(0xFFF9F9F9); // light gray
const Color textFieldBackgroundColor = Color(0xFF212121); // dark gray
const Color textFieldBorderBackgroundColor = Color(0xFF212121); // dark gray
const Color textFieldTextColor = Color(0xFFA1A1A1); // light gray

const double actionChipFontSize = 12.0;
const double appTitleFontSize = 24.0;
const double buttonBorderRadius = 4.0;
const double cardPadding = 20.0;
const double cardTitleFontSize = 18.0;
const double cardTitleIconSize = 20.0;
const double onboardingFontSize = 25.0;
const double onboardingOpacity = 0.8;
const int initialHeaders = 3;
const int snackbarDurationSeconds = 2;
const double switchFontSize = 12.0;
const double syncIconSize = 40.0;
const double tableBorderRadius = 0.0;
const double tableCellFontSize = 12.0;
const double tableCellHeight = 20.0;
const double tableCellPadding = 0.0;
const double tableCellWidth = 100.0;
const double tableDataRowMaxHeight = 40.0;
const double tableDataRowMinHeight = 10.0;
const double tableHeadingRowHeight = 30.0;
const double tableHeight = 120.0;
const double tableIconSize = 35.0;
const double textAreaFontSize = 12.0;
const int textAreaHeight = 3;
const double textAreaSpacing = 10.0;

List<List<String>> defaultTableData = [
  ['**Header 1**', '**Header 2**', '**Header 3**'],
  ['Row 1, Cell 1', 'Row 1, Cell 2', 'Row 1, Cell 3'],
  ['Row 2, Cell 1', 'Row 2, Cell 2', 'Row 2, Cell 3']
];

List<List<String>> tableData = defaultTableData.map((row) => List<String>.from(row)).toList();

enum OnboardingStage {
  welcome,
  textHighlight,
  tableHighlight,
  completed,
}

class OnboardingOverlay extends StatefulWidget {
  final OnboardingStage stage;
  final GlobalKey tableKey;
  final GlobalKey textFieldKey;
  final VoidCallback onTap;

  const OnboardingOverlay({
    super.key,
    required this.stage,
    required this.tableKey,
    required this.textFieldKey,
    required this.onTap,
  });

  @override
  _OnboardingOverlayState createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stage == OnboardingStage.welcome) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(onboardingOpacity),
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Welcome!  Easily edit your Markdown tables.',
                  style: TextStyle(
                    color: onboardingFontColor,
                    fontSize: onboardingFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final GlobalKey targetKey = widget.stage == OnboardingStage.tableHighlight
        ? widget.tableKey
        : widget.textFieldKey;
    final String message = widget.stage == OnboardingStage.tableHighlight
        ? 'Step 2. Click a cell to start editing.'
        : "Step 1. Paste your table's Markdown here (if any).";

    if (targetKey.currentContext == null || targetKey.currentContext!.findRenderObject() == null) {
      return const SizedBox.shrink();
    }

    final RenderBox targetBox = targetKey.currentContext!.findRenderObject() as RenderBox;
    if (!targetBox.hasSize) {
      // Delay rendering until the target has a size
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
      return const SizedBox.shrink();
    }

    final Offset targetOffset = targetBox.localToGlobal(Offset.zero);
    final Size targetSize = targetBox.size;
    // print("HERE4 - Target Offset: dx=${targetOffset.dx}, dy=${targetOffset.dy}, Size: width=${targetSize.width}, height=${targetSize.height}");

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(onboardingOpacity),
            ),
          ),
          Positioned(
            left: targetOffset.dx,
            top: targetOffset.dy - 60, // TODO: magic number
            width: targetSize.width,
            height: targetSize.height,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                double expansion = 10 * _pulseAnimation.value;
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue.withOpacity(1 - _pulseAnimation.value),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8 + expansion),
                  ),
                  padding: EdgeInsets.all(expansion),
                );
              },
            ),
          ),
          Positioned(
            left: targetOffset.dx,
            top: targetOffset.dy - 120, // Position above the highlighted element
            width: targetSize.width,
            child: Container(
              padding: const EdgeInsets.all(10),
              // decoration: BoxDecoration(
              //   color: Colors.blue.shade700,
              //   borderRadius: BorderRadius.circular(8),
              // ),
              child: Text(
                message,
                style: TextStyle(
                  // color: Colors.white,
                  color: onboardingFontColor,
                  fontSize: onboardingFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const TableEditorApp());
}

class TableEditorActionChip extends ActionChip {
  TableEditorActionChip({
    super.key,
    required String label,
    required VoidCallback onPressed,
  }) : super(
          label: Text(label, style: TextStyle(fontSize: actionChipFontSize, color: buttonTextColor)),
          onPressed: onPressed,
          backgroundColor: buttonBackgroundColor,
          side: BorderSide(color: buttonBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 1.0, vertical: 4.0),
        );
}

class TableEditorApp extends StatelessWidget {
  const TableEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        cardColor: cardBackgroundColor,
        dividerColor: dividerColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            headlineSmall: TextStyle(color: cardTitleTextColor),
            bodyMedium: TextStyle(color: tableTextColor),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: textFieldBackgroundColor,
          border: OutlineInputBorder(borderSide: BorderSide(color: textFieldBorderBackgroundColor)),
          hintStyle: TextStyle(color: placeholderTextColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackgroundColor,
            foregroundColor: tableTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonBorderRadius),
              side: BorderSide(color: buttonBorderColor),
            ),
          ),
        ),
// Update DataTable theme to use tableDataRowColor for row borders
        dataTableTheme: DataTableThemeData(
          headingRowColor: WidgetStateProperty.all(tableHeaderCellBackgroundColor),
          dataRowColor: WidgetStateProperty.all(tableNormalCellBackgroundColor),
          headingTextStyle: TextStyle(color: tableHeaderTextColor),
          dataTextStyle: TextStyle(color: tableTextColor),
          dividerThickness: 1.0,
          decoration: BoxDecoration(border: Border.all(color: tableDataRowColor)),
        ),
      ),
      home: const TableEditorPage(),
    );
  }
}

class TableEditorPage extends StatefulWidget {
  const TableEditorPage({super.key});

  @override
  State<TableEditorPage> createState() => _TableEditorPageState();
}

class _TableEditorPageState extends State<TableEditorPage> {
  final GlobalKey _tableKey = GlobalKey();
  final GlobalKey _textFieldKey = GlobalKey();
  OnboardingStage _onboardingStage = OnboardingStage.welcome;
  
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
    // Removed automatic transition to textHighlight to ensure welcome stage persists until user interaction
    // WidgetsBinding.instance.addPostFrameCallback and Future.delayed were setting the stage to textHighlight after 500ms
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
        backgroundColor: appBarBackgroundColor,
        surfaceTintColor: appBarSurfaceTintColor,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                SvgPicture.asset(
                  'images/table_icon.svg',
                  width: syncIconSize,
                  height: syncIconSize,
                  colorFilter: ColorFilter.mode(
                    syncIconColor,
                    BlendMode.srcIn,
                  ),
                ),
              const SizedBox(width: 8),
              const Text(appTitle, style: TextStyle(color: appBarTextColor, fontWeight: FontWeight.bold, fontSize: appTitleFontSize)),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
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
                  const SizedBox(height: 5),
                  _buildTextCard(),
                  const SizedBox(height: 10),
                  Row(
                    children: 
                    [const SizedBox(width: 100),
                      SvgPicture.asset(
                      'images/sync.svg',
                      width: syncIconSize,
                      height: syncIconSize,
                      colorFilter: ColorFilter.mode(
                        const Color.fromARGB(255, 64, 62, 62),
                        BlendMode.srcIn,
                      ),
                    )
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTableCard(),
                  const SizedBox(height: 20),
                  _buildFooter(),
                ],
              ),
            ),
          ),
          if (_onboardingStage != OnboardingStage.completed)
            OnboardingOverlay(
              stage: _onboardingStage,
              tableKey: _tableKey,
              textFieldKey: _textFieldKey,
              onTap: () {
                setState(() {
                  if (_onboardingStage == OnboardingStage.welcome) {
                    _onboardingStage = OnboardingStage.textHighlight;
                  } else if (_onboardingStage == OnboardingStage.textHighlight) {
                    _onboardingStage = OnboardingStage.tableHighlight;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_tableKey.currentContext != null) {
                        final RenderBox tableBox = _tableKey.currentContext!.findRenderObject() as RenderBox;
                        final Offset tableOffset = tableBox.localToGlobal(Offset.zero);
                        _verticalScrollController.animateTo(
                          tableOffset.dy - 100, // Adjust for some padding
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  } else {
                    _onboardingStage = OnboardingStage.completed;
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTableCard() {
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: cardTitleTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: cardTitleFontSize
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTable(),
            const SizedBox(height: 10),
            _buildTableControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextCard() {
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: cardTitleTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: cardTitleFontSize
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('Format: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                DropdownButton<DataFormat>(
                  value: selectedExportFormat,
                  style: const TextStyle(color: dropdownTextColor),
                  dropdownColor: dropdownBackgroundColor,
                  
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
            const SizedBox(height: textAreaSpacing),
            TextField(
              key: _textFieldKey,
              controller: exportController,
              maxLines: textAreaHeight,
              decoration: const InputDecoration(
                hintText: 'Paste data here to import or edit text directly. Supports Markdown, CSV, and Google Sheets formats.',
                hintStyle: TextStyle(color: textFieldTextColor),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: textFieldBackgroundColor,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: textAreaFontSize, color: textFieldTextColor),
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
            const SizedBox(height: textAreaSpacing),
            ElevatedButton.icon(
              onPressed: _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Export to Clipboard', style: TextStyle(fontSize: actionChipFontSize),),
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

  Widget _buildTable() {
    if (tableData.isEmpty || cellControllers.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return SizedBox(
      key: _tableKey,
      height: tableHeight, // Set a reasonable maximum height for the table
    
      child: ClipRect(
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          child: SingleChildScrollView(
            controller: _horizontalScrollController,
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
                      width: tableCellWidth,
                      height: tableCellHeight,
                      child: isPreviewMode
                          ? MarkdownBody(
                              data: tableData[0][index],
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(fontSize: tableCellFontSize),
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
                            width: tableCellWidth,
                            height: tableCellHeight,
                            child: isPreviewMode
                                ? MarkdownBody(
                                    data: tableData[actualRowIndex][colIndex],
                                    styleSheet: MarkdownStyleSheet(
                                      p: TextStyle(fontSize: tableCellFontSize, overflow: TextOverflow.ellipsis),
                                    ),
                                    onTapLink: (text, href, title) async {
                                      if (href != null) {
                                        final Uri url = Uri.parse(href);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url, mode: LaunchMode.externalApplication);
                                        }
                                      }
                                    },
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

  Widget _buildTableControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, thickness: 1, color: dividerColor),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: [
            TableEditorActionChip(label: 'Add Row', onPressed: _addRow),
            TableEditorActionChip(label: 'Add Col', onPressed: _addColumn),
            TableEditorActionChip(label: 'Delete Row', onPressed: _deleteRow),
            TableEditorActionChip(label: 'Delete Col', onPressed: _deleteColumn),
            TableEditorActionChip(label: 'Reset', onPressed: _resetTable),
            Row(
              children: [
                Text(
                  isPreviewMode ? 'Preview Mode' : 'Edit Mode',
                  style: TextStyle(color: switchTextColor, fontSize: switchFontSize),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isPreviewMode,
                  onChanged: (value) {
                    setState(() {
                      isPreviewMode = value;
                    });
                  },
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
            content: const Text('This text is not recognized as a recognizable format (Google Sheets, CSV, or Markdown).'),
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

  void _resetTable() {
    setState(() {
      tableData = [List<String>.from(defaultTableData[0])];
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: appBarBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              const url = 'https://github.com/your-repo/markdown-table-editor';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text(
              'GitHub',
              style: TextStyle(color: appBarTextColor),
            ),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () async {
              const url = 'https://flutter.dev';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text(
              'Written in Flutter',
              style: TextStyle(color: appBarTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
