import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:secure_sync/file_handlers/file_handler.dart';
import 'package:secure_sync/file_handlers/sub_classes/quickbooks_file.dart';
import 'package:secure_sync/file_handlers/sub_classes/register_file.dart';
import 'package:secure_sync/file_handlers/sub_classes/void_checks_file.dart';

/// @brief This class is responsible for choosing the correct inherited class to
/// read the user input file
class FileHandlerFactory {
  /// @brief Reads the input file and determines the correct class needed to
  /// handle the file specific formating.
  ///
  /// @param name - the file name
  /// @param bytes - the file encoded as unsigned 8 bit integers
  ///
  /// @return the correct class to handle the file format. The returned class
  /// will hold the file as a List<List<String>>
  static FileHandlers createReader(String name, Uint8List bytes) {
    List<List<String>> table;

    // handle the correct file extension and load the data into the table
    if (name.endsWith('.xlsx')) {
      table = FileHandlers.convertExcelToList(bytes);
    } else if (name.endsWith('.csv')) {
      table = FileHandlers.convertDelimFileToList(bytes, ',');
    } else {
      throw ArgumentError('This file type is not supported');
    }

    // get the header from the table and return the corresponding class
    List<String> fileHeader = _getHeader(table);
    if (listEquality.equals(fileHeader, headersText[0])) {
      return RegisterFile(name, bytes, table, fileHeader);
    } else if (listEquality.equals(fileHeader, headersText[1])) {
      return RegisterFile(name, bytes, table, fileHeader);
    } else if (listEquality.equals(fileHeader, headersText[2])) {
      return QuickbooksFile(name, bytes, table, fileHeader);
    } else if (listEquality.equals(fileHeader, headersText[3])) {
      return VoidChecksFile(name, bytes, table, fileHeader);
    } else {
      throw ArgumentError('Unknown file type');
    }
  }

  /// @brief Return the header row of the table. This is used to determine the
  /// file type.
  ///
  /// @param table raw file data
  ///
  /// @return the header row of the file as a List<String>. Empty list if not
  /// found
  static List<String> _getHeader(List<List<String>> table) {
    List<String> row = [];
    // loop through headerIndices. These are the only possible header locations
    for (int headerIndex in headerIndices) {
      // this is a potential header
      if (headerIndex < table.length) {
        row = table[headerIndex];
        row = FileHandlers.cleanRow(row); // get rid of blank cells
      }

      // check to see if row is a header
      for (var header in headersText) {
        if (listEquality.equals(header, row)) {
          return row;
        }
      }
    }

    return row;
  }

  // class used to compare headers (List<String>)
  static const listEquality = ListEquality();

  // use headers to identify different file types
  static const List<List<String>> headersText = [
    // Producer Fee Check Register
    [
      'Check #',
      'Description',
      'Contract #',
      'Payee',
      'Payee Code',
      'Check Amount',
      'Issue Date',
      'Status',
      'Date Processed',
    ],

    // standard check register
    [
      'CHECK #',
      'DESCRIPTION',
      'CONTRACT #',
      'PAYEE',
      'PAYEE CODE',
      'CHECK AMOUNT',
      'ISSUE DATE',
      'STATUS',
      'DATE PROCESSED',
    ],

    // QUICK BOOKS
    [
      'Type',
      'Num',
      'Date',
      'Name',
      'Paid Amount',
      'Original Amount',
    ],

    // VOIDED CHECKS
    [
      'Processed Date',
      'Cheque #',
      'Payee',
      'Contract #',
      'Funding Date',
      'Amount',
      'Description',
      'Reason',
      'Cheque Type',
      'Group Name',
      'Void / Replaced',
    ]
  ];
  static const List<int> headerIndices = [0, 9];
}
