/// This file defines and implements classes for handling different file types.
/// For example, when the user uploads a Third Eye file vice a Quickbooks file,
/// they will need to be handled differently. All file implementations will
/// store the files as List<list<String>>
library files_handlers;

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:logging/logging.dart';

abstract class FileHandlers {
  FileHandlers(this.name, this.bytes) {
    table = _handleFile();
  }

  List<List<String>> _handleFile();
  List<List<String>> _readExcel(Uint8List bytes);
  List<List<String>> _readDelimeter(Uint8List bytes);

  late final List<List<String>>? table;
  final String name;
  final Uint8List bytes;
}

class ThirdEyeFile extends FileHandlers {
  ThirdEyeFile(super.name, super.bytes);

  @override
  List<List<String>> _handleFile() {
    // determine file type
    if (name.endsWith('.xlsx')) {
      return _readExcel(bytes);
    } else if (name.endsWith('csv')) {
      return _readDelimeter(bytes);
    } else {
      throw ArgumentError("Unsupported file selection");
    }
  }

  /// @brief This function reads an Excel file, identifies a specific header 
  /// cell (defined by headerText), and parses the data into a structured table 
  /// format while removing null or empty cells. The parsed data is returned as 
  /// a List<List<String>>, where each inner list represents a row of non-empty 
  /// strings extracted from the Excel sheet.
  /// 
  /// @param Uint8List bytes: The raw bytes of the Excel file to be read. This 
  /// data is used to initialize the Excel object in memory for parsing.
  /// 
  /// @returns List<List<String>>: A 2D list of strings representing the data 
  /// from the Excel sheet. Each inner list corresponds to a row, with all null 
  /// and empty cells removed.
  /// 
  /// @throws ArgumentError: Thrown if:
  /// 1. The default sheet is unsupported or missing.
  /// 2. The specified header element cannot be found.
  @override
  List<List<String>> _readExcel(Uint8List bytes) {
    const String headerText = 'CHECK #'; // BEGIN TABLE DATA
    String? sheetName;
    Excel excel;
    Sheet sheet;

    // load excel file into memory
    excel = Excel.decodeBytes(bytes);
    sheetName = excel.getDefaultSheet();
    if (sheetName == null) {
      throw (ArgumentError("Unsupported file selection"));
    }
    sheet = excel[sheetName];

    // find the cell that says 'CHECK #'
    // this is the header data
    late final CellIndex? index;
    for (int i = 0; i < sheet.maxRows; ++i) {
      for (int j = 0; j < sheet.maxColumns; ++j) {
        CellIndex rIndex =
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i);
        if (sheet.cell(rIndex).value == TextCellValue(headerText)) {
          index = rIndex;
        }
      }
    }

    // if unable to find data then return
    if (index == null) {
      throw ArgumentError('Could not parse excel fiel');
    }

    // create a list of null columns
    List<int> nullColumns = List.empty(growable: true);
    for (int j = 0; j < sheet.maxColumns; ++j) {
      Data data = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: index.rowIndex));
      if (data.value == null) {
        nullColumns.add(j);
      }
    }

    // create table data and remove null columns
    // TODO The non producer fee file has columns that are not in line with their headers
    // TODO function works for PF files
    List<List<Data?>> tableData = List.empty(growable: true);
    for (int i = index.rowIndex; i < sheet.maxRows; ++i) {
      List<Data?> row = sheet.row(i);

      // remove null cells
      for (int x = nullColumns.length - 1; x >= 0; --x) {
        row.removeAt(nullColumns[x]);
      }

      // add trimmed data to table
      tableData.add(row);
    }

    // trim null rows from bottom
    for (int i = tableData.length - 1; i >= 0; --i) {
      if (tableData[i][index.columnIndex]!.value == null ||
          tableData[i][index.columnIndex]!.value ==
              TextCellValue('Total Checks Listed For All Groups:')) {
        tableData.removeAt(i);
      }
    }

    // convert table data from List<List<Data?>> to List<List<String>>
    List<List<String>> data = List.empty(growable: true);
    for (final d in tableData) {
      List<String> row = List.empty(growable: true);
      for (final elem in d) {
        row.add(elem.toString());
      }
      data.add(row);
    }

    return data;
  }

  @override
  List<List<String>> _readDelimeter(Uint8List bytes) {
    // TODO: implement _readDelimeter
    throw UnimplementedError();
  }

  final _log = Logger('File Input: Third Eye');
}

class QuickbooksFile extends FileHandlers {
  QuickbooksFile(super.name, super.bytes);

  @override
  List<List<String>> _handleFile() {
    // TODO: implement _handleExcelFile
    List<List<String>> table = List.empty(growable: true);
    return table;
  }

  final _log = Logger('File Input: Quick Books');

  @override
  List<List<String>> _readDelimeter(Uint8List bytes) {
    // TODO: implement _readDelimeter
    throw UnimplementedError();
  }

  @override
  List<List<String>> _readExcel(Uint8List bytes) {
    // TODO: implement _readExcel
    throw UnimplementedError();
  }
}
