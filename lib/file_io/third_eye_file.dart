/// This file defines and implements classes for handling different file types.
/// For example, when the user uploads a Third Eye file vice a Quickbooks file,
/// they will need to be handled differently. All file implementations will
/// store the files as List<list<String>>
library files_handlers;

import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:logging/logging.dart';



abstract class FileHandlers {
  FileHandlers(this.bytes) {
    table = _handleFile();
  }

  List<List<String>> _handleFile();

  late final List<List<String>>? table;
  final Uint8List bytes;
}

class ThirdEyeFile extends FileHandlers {
  ThirdEyeFile(super.filePath);

  @override
  List<List<String>> _handleFile() {
    _log.info('Handle Third Eye Excel');
    // variables
    List<List<String>> table = List.empty(growable: true);
    Sheet sheet;

    // open and read the excel file as bytes
    Uint8List bytes = file.readAsBytesSync();
    Excel excel = Excel.decodeBytes(bytes);
    String? sheetName = excel.getDefaultSheet();
    if (sheetName == null) {
      throw (ArgumentError("Unsupported file selection"));
    } else {
      sheet = excel[sheetName];
    }
    print('b');

    // grab the header. Starts in row 7
    List<Data?> tableHeader = sheet.row(6);
    print('c');
    // grab table info
    List<List<Data?>> tableData = List.empty(growable: true);
    for (int i = 9; i < sheet.maxRows; ++i) {
      List<Data?> row = sheet.row(i);
      tableData.add(row);
    }
    print('d');

    // trim columns A, I, M and N. These are blank cells
    for (int i = tableHeader.length; i > 0; --i) {
      if ((i == 1) ||
          (i == 2) ||
          (i == 6) ||
          (i == 7) ||
          (i == 10) ||
          (i == 13)) {
        tableHeader.removeAt(i);
        tableData.removeAt(i);
      }
    }
    return table;
  }

  final _log = Logger('File Input: Third Eye');
}

class QuickbooksFile extends FileHandlers {
  QuickbooksFile(super.filePath);

  @override
  List<List<String>> _handleFile() {
    // TODO: implement _handleExcelFile
    List<List<String>> table = List.empty(growable: true);
    return table;
  }

  final _log = Logger('File Input: Quick Books');
}
