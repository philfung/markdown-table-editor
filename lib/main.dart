import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data_parser.dart';
import 'styles.dart';
import 'widgets/table_card.dart';
import 'widgets/import_card.dart';
import 'widgets/table_controls.dart';
import 'widgets/export_card.dart';
import 'widgets/footer.dart';

// strings
const String appTitle = 'Awesome Markdown Table Editor';
const String onboardingWelcomeMessage =
    'Welcome - edit your Markdown tables with ease!';
List<List<String>> tableDefaultData = [
  ['**Name**', '**Pokedex**', '**Type**', '**Ability**', '**Weakness**'],
  [
    'Pikachu',
    '[Dex link](https://pokemondb.net/pokedex/pikachu)',
    'Electric',
    'Static',
    'Ground',
  ],
  [
    'Charmander',
    '[Dex link](https://pokemondb.net/pokedex/charmander)',
    'Fire',
    'Blaze',
    'Water',
  ],
  [
    'Bulbasaur',
    '[Dex link](https://pokemondb.net/pokedex/bulbasaur)',
    'Grass / Poison',
    'Overgrow',
    'Fire',
  ],
];
List<List<String>> tableData = tableDefaultData
    .map((row) => List<String>.from(row))
    .toList();

enum OnboardingStage {
  welcome,
  textHighlight,
  tableHighlight,
  exportHighlight,
  completed,
}

class OnboardingOverlay extends StatefulWidget {
  final OnboardingStage stage;
  final GlobalKey tableKey;
  final GlobalKey textFieldKey;
  final GlobalKey exportButtonKey;
  final VoidCallback onTap;

  const OnboardingOverlay({
    super.key,
    required this.stage,
    required this.tableKey,
    required this.textFieldKey,
    required this.exportButtonKey,
    required this.onTap,
  });

  @override
  _OnboardingOverlayState createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_pulseController);

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 3), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 3, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -2, end: 2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: -1), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -1, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OnboardingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stage != oldWidget.stage) {
      _shakeController.reset();
      _shakeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stage == OnboardingStage.welcome) {
      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            widget.onTap();
          }
        },
        child: GestureDetector(
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
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: RichText(
                          text: TextSpan(
                            text: onboardingWelcomeMessage,
                            style: TextStyle(
                              fontSize: onboardingFirstMessageFontSize,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = onboardingGradient.createShader(
                                  Rect.fromLTWH(0, 0, 500, 50),
                                ),
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final GlobalKey targetKey = widget.stage == OnboardingStage.tableHighlight
        ? widget.tableKey
        : widget.stage == OnboardingStage.exportHighlight
        ? widget.exportButtonKey
        : widget.textFieldKey;
    final String message = widget.stage == OnboardingStage.tableHighlight
        ? 'Step 2. Edit table.'
        : widget.stage == OnboardingStage.exportHighlight
        ? 'Step 3. Export to Clipboard.'
        : "Step 1. Paste Markdown.";

    if (targetKey.currentContext == null ||
        targetKey.currentContext!.findRenderObject() == null) {
      return const SizedBox.shrink();
    }

    final RenderBox targetBox =
        targetKey.currentContext!.findRenderObject() as RenderBox;
    if (!targetBox.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
      return const SizedBox.shrink();
    }

    final Offset targetOffset = targetBox.localToGlobal(Offset.zero);
    final Size targetSize = targetBox.size;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          widget.onTap();
        }
      },
      child: GestureDetector(
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
                        color: Colors.blue.withOpacity(
                          1 - _pulseAnimation.value,
                        ),
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
              top:
                  targetOffset.dy -
                  120, // Position above the highlighted element
              // width: targetSize.width,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: RichText(
                        text: TextSpan(
                          text: message,
                          style: TextStyle(
                            fontSize: onboardingFontSize,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = onboardingGradient.createShader(
                                Rect.fromLTWH(0, 0, 400, 50),
                              ),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const TableEditorApp());
}

class TableEditorApp extends StatelessWidget {
  const TableEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: appTheme,
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
  final GlobalKey _exportButtonKey = GlobalKey();
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
        (colIndex) =>
            TextEditingController(text: tableData[rowIndex][colIndex]),
      ),
    );
    cellFocusNodes = List.generate(
      tableData.length,
      (rowIndex) =>
          List.generate(tableData[rowIndex].length, (colIndex) => FocusNode()),
    );

    // Add listeners to update tableData when controllers change
    for (int rowIndex = 0; rowIndex < cellControllers.length; rowIndex++) {
      for (
        int colIndex = 0;
        colIndex < cellControllers[rowIndex].length;
        colIndex++
      ) {
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
          child: GestureDetector(
            onTap: _reloadApp,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'images/table_icon.svg',
                  width: appBarIconSize,
                  height: appBarIconSize,
                  colorFilter: ColorFilter.mode(
                    appBarIconColor,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Awesome ',
                        style: TextStyle(
                          // color: appBarTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: appTitleFontSize,
                          foreground: Paint()
                            ..shader = appTitleGradient.createShader(
                              Rect.fromLTWH(0, 0, 250, 40),
                            ),
                        ),
                      ),
                      TextSpan(
                        text: 'Markdown Table Editor',
                        style: TextStyle(
                          color: appBarTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: appTitleFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 0),
                  SizedBox(
                    width: cardWidth, // Use width from styles.dart
                    child: Center(
                      child: ImportCard(
                        textFieldKey: _textFieldKey,
                        exportButtonKey: _exportButtonKey,
                        exportController: exportController,
                        selectedExportFormat: selectedExportFormat,
                        onFormatChanged: (DataFormat? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedExportFormat = newValue;
                              updateExportOutput();
                            });
                          }
                        },
                        onTextChanged: (value) {
                          if (value.trim().isNotEmpty) {
                            _handlePastedData(value.trim());
                          }
                        },
                        onCopyToClipboard: _copyToClipboard,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth, // Use width from styles.dart
                    child: Center(
                      child: TableCard(
                        tableKey: _tableKey,
                        isPreviewMode: isPreviewMode,
                        selectedRowIndex: selectedRowIndex,
                        selectedColIndex: selectedColIndex,
                        tableData: tableData,
                        cellControllers: cellControllers,
                        cellFocusNodes: cellFocusNodes,
                        verticalScrollController: _verticalScrollController,
                        horizontalScrollController: _horizontalScrollController,
                        onCellTap: (rowIndex, colIndex) {
                          setState(() {
                            isPreviewMode = false;
                            selectedRowIndex = rowIndex;
                            selectedColIndex = colIndex;
                          });
                        },
                        onModeChanged: (value) {
                          setState(() {
                            isPreviewMode = value;
                          });
                        },
                        additionalChildren: [
                          TableControls(
                            isPreviewMode: isPreviewMode,
                            onAddRow: _addRow,
                            onAddColumn: _addColumn,
                            onDeleteRow: _deleteRow,
                            onDeleteColumn: _deleteColumn,
                            onReset: _resetTable,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: cardWidth, // Use width from styles.dart
                    child: Center(
                      child: ExportCard(
                        exportButtonKey: _exportButtonKey,
                        exportController: exportController,
                        selectedExportFormat: selectedExportFormat,
                        onFormatChanged: (DataFormat? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedExportFormat = newValue;
                              updateExportOutput();
                            });
                          }
                        },
                        onCopyToClipboard: _copyToClipboard,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Footer(),
                ],
              ),
            ),
          ),
          if (_onboardingStage != OnboardingStage.completed)
            OnboardingOverlay(
              stage: _onboardingStage,
              tableKey: _tableKey,
              textFieldKey: _textFieldKey,
              exportButtonKey: _exportButtonKey,
              onTap: () {
                setState(() {
                  if (_onboardingStage == OnboardingStage.welcome) {
                    _onboardingStage = OnboardingStage.textHighlight;
                  } else if (_onboardingStage ==
                      OnboardingStage.textHighlight) {
                    _onboardingStage = OnboardingStage.tableHighlight;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_tableKey.currentContext != null) {
                        final RenderBox tableBox =
                            _tableKey.currentContext!.findRenderObject()
                                as RenderBox;
                        final Offset tableOffset = tableBox.localToGlobal(
                          Offset.zero,
                        );
                        _verticalScrollController.animateTo(
                          tableOffset.dy - 100, // Adjust for some padding
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  } else if (_onboardingStage ==
                      OnboardingStage.tableHighlight) {
                    _onboardingStage = OnboardingStage.exportHighlight;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_exportButtonKey.currentContext != null) {
                        final RenderBox exportBox =
                            _exportButtonKey.currentContext!.findRenderObject()
                                as RenderBox;
                        final Offset exportOffset = exportBox.localToGlobal(
                          Offset.zero,
                        );
                        _verticalScrollController.animateTo(
                          exportOffset.dy - 100, // Adjust for some padding
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  } else if (_onboardingStage ==
                      OnboardingStage.exportHighlight) {
                    _onboardingStage = OnboardingStage.completed;
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
            backgroundColor: backgroundColor,
            title: const Text('Import Data'),
            content: Text(
              'Detected $formatName data. Do you want to import this data into the table?',
              style: TextStyle(color: buttonTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  updateExportOutput();
                },
                child: Text('No', style: TextStyle(color: buttonTextColor)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _importTableData(data, detectedFormat);
                },
                child: Text('Yes', style: TextStyle(color: buttonTextColor)),
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
            content: const Text(
              'This text is not recognized as a recognizable format (Google Sheets, CSV, or Markdown).',
            ),
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
        tableData = [
          [''],
        ];
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
        tableData = [
          [''],
        ];
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
      tableData = tableDefaultData
          .map((row) => List<String>.from(row))
          .toList();
      _initializeCellControllers();
      updateExportOutput();
      // Reset scroll position to top-left
      _verticalScrollController.jumpTo(0.0);
      _horizontalScrollController.jumpTo(0.0);
    });
  }

  void _reloadApp() {
    setState(() {
      tableData = tableDefaultData
          .map((row) => List<String>.from(row))
          .toList();
      _initializeCellControllers();
      updateExportOutput();
      _onboardingStage = OnboardingStage.welcome;
      importController.clear();
      exportController.text = DataParser.generateMarkdown(tableData);
      isPreviewMode = true;
      selectedRowIndex = null;
      selectedColIndex = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App reloaded'),
        duration: Duration(seconds: snackbarDurationSeconds),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: exportController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${DataParser.getFormatDisplayName(selectedExportFormat)} data copied to clipboard!',
        ),
        duration: const Duration(seconds: snackbarDurationSeconds),
      ),
    );
  }
}
