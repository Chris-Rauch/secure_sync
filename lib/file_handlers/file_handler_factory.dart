import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:secure_sync/file_handlers/file_handler.dart';
import 'package:secure_sync/file_handlers/sub_classes/pf_file.dart';
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
      table = FileHandlers.convertCSVToList(bytes);
    } else {
      throw ArgumentError('Unknown file type');
    }

    // get the header from the table and return the corresponding class
    List<String> fileHeader = _getHeader(table);
    var listEquality = const ListEquality();
    if (listEquality.equals(fileHeader, headersText[0])) {
      return PfFile(name, bytes, table);
    } else if (listEquality.equals(fileHeader, headersText[1])) {
      return RegisterFile(name, bytes, table);
    } else if (listEquality.equals(fileHeader, headersText[2])) {
      return QuickbooksFile(name, bytes, table);
    } else if (listEquality.equals(fileHeader, headersText[3])) {
      return VoidChecksFile(name, bytes, table);
    } else {
      throw ArgumentError('Unknown file type');
    }
  }

  /// @brief Return the header row of the table. This is used to determine the
  /// file type. 
  /// 
  /// @param table raw file data
  /// 
  /// @return the header of the file
  static List<String> _getHeader(List<List<String>> table) {

    // loop through headerIndices. These are the only possible header locations
    for (int headerIndex in headerIndices) {
      // this is a potential header
      List<String> row =
          table[headerIndex]; //TODO protect against out of bounds error
      row = FileHandlers.cleanRow(row); // get rid of blank cells

      // check to see if row is a header
      //TODO not case sensitive
      if (headersText.contains(row)) {
        return row;
      }
    }

    return [];
  }

  // use headers to identify different file types
  static List<List<String>> headersText = [
    // Producer Fee Check Register
    [
      'CHECK #',
      'PAYEE',
      'STATUS',
      'CHECK AMOUNT',
      'FEE AMOUNT',
      'ADJ. AMT',
      'ISSUE DATE',
      'DATE PROCESSED'
    ],

    // just the normal check register
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
      'TYPE',
      'NUM',
      'DATE',
      'NAME',
      'PAID AMOUNT',
      'ORIGINAL AMOUNT',
    ],

    // VOIDED CHECKS
    [
      'PROCESSED DATE',
      'CHEQUE #',
      'PAYEE',
      'CONTRACT #',
      'FUNDING DATE',
      'AMOUNT',
      'DESCRIPTION',
      'REASON',
      'CHEQUE TYPE',
      'GROUP NAME',
      'VOID / REPLACED',
    ]
  ];
  static List<int> headerIndices = [0, 10];
}
