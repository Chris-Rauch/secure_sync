/// This file defines and implements classes for handling different file types.
/// For example, when the user uploads a Third Eye file vice a Quickbooks file,
/// they will need to be handled differently. All file implementations will
/// store the files as List<List<String>> in their data member, 'table'.
///
/// FileHandlers class also impements several static functions to help with
/// table operations.
///
/// Note:
///   To add file reading functionality, the following must be implemented:
///     1) Add header index to headerIndices[] in FileHandlerFactory
///     2) Add header text to headerText[[]] in FileHandlerFactory
///     3) Add else if statement in createReader() and return new subclass
///
library file_handlers;

import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:secure_sync/detail_record/ledger.dart';
import 'package:secure_sync/file_handlers/file_handler_factory.dart';

abstract class FileHandlers {
  FileHandlers(this.name, this.bytes, this.table, this.header);

  //=== ABSTRACT METHODS ======================================================
  // 1. getRecord(List<String>)
  // 2. trimTable()
  //===========================================================================

  /// @brief Abstract method to map a row of data from a List<String> into a
  /// DetailRecord object.
  ///
  /// This method must be overridden in derived classes to account for
  /// variations in column structure across different file types. Each
  /// implementation should define how the input data is transformed into a
  /// DetailRecord.
  ///
  /// @param row A List<String> representing a single row of data.
  ///
  /// @return A DetailRecord object constructed from the input data.
  DetailRecord getRecord(List<String> row);

  /// @brief Abstract method to preprocess and clean the table data for
  /// improved readability.
  ///
  /// This method is intended to be overridden in derived classes to remove
  /// blank cells and unnecessary data from the table. The cleaned data should
  /// be optimized for creating a DetailRecord. This is used in conjuction with
  /// the function, getRecord, to locate table data
  ///
  /// @return void
  void trimTable();

  // data members
  final String name;
  final Uint8List bytes;
  List<List<String>> table;
  final List<String> header;

  //=== CONCRETE FUNCTIONS =====================================================
  //
  //============================================================================

  /// @brief Returns a list of records. This concrete function relies on the
  /// custom implementation of the method 'getRecord'.
  ///
  /// @return a list of records
  List<DetailRecord> getRecords() {
    List<DetailRecord> records = [];

    // iterate through the table. Ignore any header rows.
    for (var row in table) {
      if (!FileHandlerFactory.listEquality.equals(row, header)) {
        DetailRecord record = getRecord(row);
        records.add(record);
      }
    }
    return records;
  }

  /// @brief Prints the table to the terminal. Used for debugging
  void printTable() {
    for (var row in table) {
      String rowStr = '';
      for (var val in row) {
        rowStr += '${val.padRight(8)},';
      }
      // ignore: avoid_print
      print(rowStr);
    }
  }

  //=== STATIC FUNCTIONS =======================================================
  //
  // ===========================================================================

  /// @brief This function reads an Excel file and returns a table
  /// (List<List<String>>). Null values are represented as empty strings.
  /// Merged cells values are reflected in the top-left most cell. All other
  /// cells will be empty strings.
  ///
  /// @return List<List<String>>: Excel file as lists of non null strings
  static List<List<String>> convertExcelToList(Uint8List bytes) {
    String? sheetName;
    Excel excel;
    Sheet sheet;
    List<List<String>> tmpTable = [];

    // load excel file into memory
    excel = Excel.decodeBytes(bytes);
    sheetName = excel.getDefaultSheet();
    if (sheetName == null) {
      throw ArgumentError('Unknown sheet name');
    }

    sheet = excel[sheetName];
    for (int row = 0; row < sheet.maxRows; ++row) {
      tmpTable.add([]);
      for (int col = 0; col < sheet.maxColumns; ++col) {
        String strVal = _getCellVal(sheet: sheet, col: col, row: row);
        tmpTable[row].add(strVal);
      }
    }
    return tmpTable;
  }

  static List<List<String>> convertDelimFileToList(
      Uint8List bytes, String delim) {
    String fileAsString = utf8.decode(bytes);
    List<String> split = fileAsString.split('\n');
    List<List<String>> newTable = [];

    for (var row in split) {
      newTable.add(row.split(delim));
    }

    return newTable;
  }

  /// @brief Grabs the cell at [col, row] and returns the value as a string.
  /// This function is just to help hide the details of excel -> string
  /// conversion. Helper function for convertExcelToList
  ///
  /// @param sheet - The excel sheet
  /// @param col - column index
  /// @param row - row index
  ///
  /// @return The cell value as a string. Null cell values will be returned as
  /// empty strings
  static String _getCellVal(
      {required Sheet sheet, required int col, required int row}) {
    CellIndex x = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row);
    CellValue? cellVal = sheet.cell(x).value;
    String strVal = (cellVal == null) ? '' : cellVal.toString();
    return strVal;
  }

  /// @brief checks the specified row for empty strings. If a row is  entirely
  /// made up of empty strings, it removes the row from table
  ///
  /// @param table -
  /// @param rowIndex - the target row index
  ///
  /// @return true if the removal occured. False is the table remains unchanged
  static bool trimRow(List<List<String>> table, int rowIndex) {
    bool delete = true;
    List<String> row = table[rowIndex];

    for (String cell in row) {
      if (cell != '') {
        delete = false;
        break;
      }
    }

    if (delete == true) {
      table.removeAt(rowIndex);
    }

    return delete;
  }

  /// @brief checks the specified col for empty strings. If a col is entirely
  /// made up of empty strings, it removes the col from table
  ///
  /// @param table -
  /// @param colIndex - the target col index
  ///
  /// @return true if the removal occured. False is the table remains unchanged
  static bool trimCol(List<List<String>> table, int colIndex) {
    bool delete = true;
    List<String> col = [];

    for (List<String> row in table) {
      col.add(row[colIndex]);
    }

    for (String cell in col) {
      if (cell != '') {
        delete = false;
        break;
      }
    }

    if (delete == true) {
      for (int i = 0; i < table.length; ++i) {
        table[i].removeAt(colIndex);
      }
    }

    return delete;
  }

  /// @brief Returns a new row without any empty strings
  ///
  /// @param row [List<String>] - a list of strings
  ///
  /// @return a copy of 'row' but remove empty cells
  static List<String> cleanRow(List<String> row) {
    List<String> cleanRow = [];
    for (int i = 0; i < row.length; ++i) {
      if (row[i] != '') {
        cleanRow.add(row[i]);
      }
    }
    return cleanRow;
  }

  /// @brief Removes the specified column from the table regardless of empty
  /// space.
  static bool removeCol(List<List<String>> table, int col) {
    for (int i = 0; i < table.length; ++i) {
      if (col < table[i].length) {
        table[i].removeAt(col);
      }
    }
    return true;
  }
}
