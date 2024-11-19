import 'package:intl/intl.dart';

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

  String? recordCode;
  String? accountNumber;
  final String checkNumber;
  final double amount;
  final DateTime issueDate;
  final String blankOrVoid;
  final String firstPayee;
  String? secondPayee;
  String fileName;
  final String filler = ''.padRight(20);

  

  String toFormattedString() {
    final date = DateFormat('MMddyyyy').format(issueDate);
    return "$recordCode $accountNumber $checkNumber $amount $date $blankOrVoid $firstPayee $secondPayee $filler";
  }
}

class Ledger {
  Ledger();

  /// @brief Adds a single record to the the ledger
  void addRecord(DetailRecord record) {
    _totalRecord.add(record);
  }

  /// @brief Adds a list of records to the ledger
  void addAllRecords(List<DetailRecord> records) {
    _totalRecord.addAll(records);
  }

  void download() {
    //TODO Create a function that creates a file and triggers a download in the browser
    throw UnimplementedError();
  }

  /// @brief Returns the total amount of all records
  double getTotalAmount() {
    return _totalRecord.fold(0, (sum, record) => sum + record.amount);
  }

  void printLedger() {
    for (var record in _totalRecord) {
      printRecord(record);
    }
    // ignore: avoid_print
    print('Num Records: ${_totalRecord.length}');
  }

  void printRecord(DetailRecord record) {
    // ignore: avoid_print
    print(
        "Record Code: ${record.recordCode}\nAccount Number: ${record.accountNumber}\nCheck Number: ${record.checkNumber}\nAmount: ${record.amount.toString()}\nIssue Date: ${record.issueDate}\nBlank/Void: ${record.blankOrVoid}\nFirst Payee: ${record.firstPayee}\nSecond Payee: ${record.secondPayee}\n");
  }

  final List<DetailRecord> _totalRecord = [];
}
