import 'package:intl/intl.dart';
import 'dart:html' as html;

class DetailRecord {
  DetailRecord(
      {this.recordCode,
      this.accountNumber,
      required this.checkNumber,
      required this.amount,
      required this.issueDate,
      required this.blankOrVoid,
      required this.firstPayee,
      required this.secondPayee,
      required this.fileName});

  String formatRecord() {
    final code = ''.padLeft(2, ' ');
    final accNum = ''.padLeft(12, ' ');
    final chckNum = checkNumber.trim().padLeft(10, '0');
    final amt = amount.toStringAsFixed(2).padLeft(12, '0');
    final date = DateFormat('MMddyyyy').format(issueDate);
    final bOrV = blankOrVoid.trim().padLeft(1, ' ');
    final payee1 = firstPayee.trim().padLeft(40).substring(0, 40);
    final payee2 = ''.padLeft(40).substring(0, 40);

    return "$code $accNum $chckNum $amt $date $bOrV $payee1 $payee2 $filler";
  }

  String? recordCode;
  String? accountNumber;
  final String checkNumber;
  final double amount;
  final DateTime issueDate;
  final String blankOrVoid;
  final String firstPayee;
  String? secondPayee;
  String fileName;
  final String filler = ' '.padRight(20);
}

class Ledger {
  Ledger();

  String getDetailRecords() {
    String detailRecords = '';
    for (var i = 0; i < _totalRecord.length; i++) {
      var record = _totalRecord[i];
      detailRecords += record.formatRecord();
      if (i != _totalRecord.length - 1) {
        detailRecords += '\n';
      }
    }
    return detailRecords;
  }

  /// @brief returns a summary of all the detail records
  /// @return 
  String getTotalRecord() {
    final recordCode = ''.padLeft(2);
    final accNum = ''.padLeft(12);
    final totalRecords = _totalRecord.length.toString().padLeft(10, '0');
    final totalAmt = getTotalAmount().toStringAsFixed(2).padLeft(12, '0');
    final filler = ''.padLeft(109);

    return "$recordCode $accNum $totalRecords $totalAmt $filler";
  }

  /// @brief Adds a single record to the the ledger. Keeps a list of files that
  /// have been processed
  /// @param record - The record to be added to the ledger
  void addRecord(DetailRecord record) {
    _totalRecord.add(record);

    if (!_files.contains(record.fileName)) {
      _files.add(record.fileName);
    }
  }

  /// @brief Adds a list of records to the ledger. Keeps a list of files that
  /// have been processed
  /// @param records - The list of records to be added to the ledger
  void addAllRecords(List<DetailRecord> records) {
    _totalRecord.addAll(records);

    for (var record in records) {
      if (!_files.contains(record.fileName)) {
        _files.add(record.fileName);
      }
    }
  }

  void download() {
    // get the txt file contents
    String content = getDetailRecords();
    content += '\n';
    content += getTotalRecord();

    // Create a blob from the content
    final blob = html.Blob([content]);

    // Create an anchor element
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'positive_pay.txt'; // Set the file name for the download

    // Programmatically trigger a click on the anchor element
    anchor.click();

    // Clean up the URL object to avoid memory leaks
    html.Url.revokeObjectUrl(url);
  }

  /// @brief Adds the total Record.sum attributes in the list
  /// @return the sum, as a double, of all amounts
  double getTotalAmount() {
    return _totalRecord.fold(0, (sum, record) => sum + record.amount);
  }

  /// @brief print to console for debug
  void printLedger() {
    for (var record in _totalRecord) {
      printRecord(record);
    }
    // ignore: avoid_print
    print('Num Records: ${_totalRecord.length}');
  }

  /// @brief print to console for debug
  void printRecord(DetailRecord record) {
    // ignore: avoid_print
    print(
        "Record Code: ${record.recordCode}\nAccount Number: ${record.accountNumber}\nCheck Number: ${record.checkNumber}\nAmount: ${record.amount.toString()}\nIssue Date: ${record.issueDate}\nBlank/Void: ${record.blankOrVoid}\nFirst Payee: ${record.firstPayee}\nSecond Payee: ${record.secondPayee}\n");
  }

  /// @brief Converts the ledger (List<DetailRecord>) into a table (List<List<String>>)
  List<List<String>> get table {
    List<List<String>> table = [];
    for (var record in _totalRecord) {
      table.add([
        ''.padLeft(2),
        ''.padLeft(12),
        record.checkNumber,
        record.amount.toString(),
        record.issueDate.toString(),
        record.blankOrVoid,
        record.firstPayee,
        ''.padLeft(40)
      ]);
    }
    return table;
  }

  final List<DetailRecord> _totalRecord = [];
  final List<String> _files = [];
}
