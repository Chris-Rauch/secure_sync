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
    return "$recordCode $accountNumber $checkNumber $amount $issueDate $blankOrVoid $firstPayee $secondPayee $filler";
  }
}

class Ledger {
  Ledger();

  void addRecord(DetailRecord record) {
    _totalRecord.add(record);
  }

  void addRecords(List<DetailRecord> records) {
    _totalRecord.addAll(records);
  }

  // Method to get the total amount for all records
  double getTotalAmount() {
    return _totalRecord.fold(0, (sum, record) => sum + record.amount);
  }

  List<DetailRecord> _totalRecord = [];
}
