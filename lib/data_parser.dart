// Data format constants
enum DataFormat {
  markdown('MARKDOWN'),
  gsheets('GSHEETS'),
  csv('CSV');

  const DataFormat(this.value);
  final String value;
}

// Data parsing and formatting library
class DataParser {
  
  /// Detect the format of pasted data
  /// Returns the detected format or null if not recognized
  static DataFormat? detectDataFormat(String data) {
    // Check for markdown table (must have pipes and separator row)
    if (data.contains('|') && data.contains('---')) {
      final lines = data.split('\n');
      final hasTableStructure = lines.any((line) => line.trim().startsWith('|')) &&
                                lines.any((line) => line.contains('---'));
      if (hasTableStructure) {
        return DataFormat.markdown;
      }
    }
    
    // Check for tab-separated values (Google Sheets)
    if (data.contains('\t')) {
      final lines = data.split('\n');
      final tabCount = '\t'.allMatches(data).length;
      // Must have at least 2 lines and multiple tabs
      if (lines.length >= 2 && tabCount >= 1) {
        return DataFormat.gsheets;
      }
    }
    
    // Check for CSV (comma-separated values)
    if (data.contains(',')) {
      final lines = data.split('\n');
      final commaCount = ','.allMatches(data).length;
      // Must have at least 2 lines and multiple commas
      if (lines.length >= 2 && commaCount >= 1) {
        return DataFormat.csv;
      }
    }
    
    return null; // Not recognized
  }
  
  /// Get user-friendly display name for format
  static String getFormatDisplayName(DataFormat format) {
    switch (format) {
      case DataFormat.gsheets:
        return 'Google Sheets';
      case DataFormat.csv:
        return 'CSV';
      case DataFormat.markdown:
        return 'Markdown table';
    }
  }
  
  /// Parse data based on detected format
  /// Returns 2D list of table data
  static List<List<String>> parseData(String data, DataFormat format) {
    switch (format) {
      case DataFormat.csv:
        return parseCSV(data);
      case DataFormat.gsheets:
        return parseGoogleSheets(data);
      case DataFormat.markdown:
        return parseMarkdown(data);
    }
  }
  
  /// Parse CSV data
  /// Returns 2D list
  static List<List<String>> parseCSV(String data) {
    final rows = data.split('\n').map((row) => 
        row.split(',').map((cell) => cell.trim()).toList()
    ).toList();
    return rows.isNotEmpty ? rows : [];
  }
  
  /// Parse Google Sheets data (tab-separated values)
  /// Returns 2D list
  static List<List<String>> parseGoogleSheets(String data) {
    final rows = data.split('\n')
        .where((row) => row.trim().isNotEmpty) // Remove empty rows
        .map((row) {
          // Split by tab and handle empty cells
          final cells = row.split('\t').map((cell) => cell.trim()).toList();
          // Ensure at least one cell per row
          return cells.isNotEmpty ? cells : [''];
        }).toList();
    
    if (rows.isNotEmpty) {
      // Ensure all rows have the same number of columns
      final maxCols = rows.map((row) => row.length).reduce((a, b) => a > b ? a : b);
      final normalizedRows = rows.map((row) {
        while (row.length < maxCols) {
          row.add('');
        }
        return row;
      }).toList();
      return normalizedRows;
    }
    return [];
  }
  
  /// Parse Markdown table data
  /// Returns 2D list
  static List<List<String>> parseMarkdown(String data) {
    final rows = data.split('\n')
        .where((row) => row.trim().startsWith('|'))
        .map((row) {
          // Extract cell content between pipes
          final parts = row.split('|');
          return parts.sublist(1, parts.length - 1)
              .map((cell) => cell.trim())
              .toList();
        }).toList();
    
    // Remove separator row (the one with dashes)
    final tableRows = rows.where((row) => 
        !row.every((cell) => RegExp(r'^[-:]+$').hasMatch(cell))
    ).toList();
    
    return tableRows.isNotEmpty ? tableRows : [];
  }
  
  /// Generate markdown table from 2D list
  /// Returns markdown table string
  static String generateMarkdown(List<List<String>> tableData) {
    if (tableData.isEmpty) return '';
    
    final buffer = StringBuffer();
    final columnCount = tableData[0].length;
    
    // Header row
    buffer.writeln('| ${tableData[0].join(' | ')} |');
    
    // Separator row
    buffer.writeln('| ${List.filled(columnCount, '---').join(' | ')} |');
    
    // Data rows
    for (int i = 1; i < tableData.length; i++) {
      buffer.writeln('| ${tableData[i].join(' | ')} |');
    }
    
    return buffer.toString();
  }
  
  /// Generate Google Sheets format (TSV) from 2D list
  /// Returns tab-separated values string
  static String generateGoogleSheets(List<List<String>> tableData) {
    if (tableData.isEmpty) return '';
    
    return tableData.map((row) => row.join('\t')).join('\n');
  }
  
  /// Generate CSV format from 2D list
  /// Returns CSV string
  static String generateCSV(List<List<String>> tableData) {
    if (tableData.isEmpty) return '';
    
    return tableData.map((row) => 
        row.map((cell) {
          // Escape cells that contain commas, quotes, or newlines
          if (cell.contains(',') || cell.contains('"') || cell.contains('\n')) {
            return '"${cell.replaceAll('"', '""')}"';
          }
          return cell;
        }).join(',')
    ).join('\n');
  }
}
