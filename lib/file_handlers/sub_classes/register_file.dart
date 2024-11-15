import 'package:secure_sync/detail_record/ledger.dart';
import 'package:secure_sync/file_handlers/file_handler.dart';
import 'package:intl/intl.dart';

class RegisterFile extends FileHandlers {
  RegisterFile(super.name, super.bytes, super.table);

  @override
  DetailRecord getRecord(List<String> row) {
    String checkNum = row[0];
    String firstPayee = row[3];
    String? secondPayee;
    double amount = double.parse(row[5]);
    DateTime issueDate = DateFormat('MM/dd/yyy').parse(row[6]);
    String blankOrVoid = '';
    return DetailRecord(
        checkNumber: checkNum,
        amount: amount,
        issueDate: issueDate,
        blankOrVoid: blankOrVoid,
        firstPayee: firstPayee,
        secondPayee: secondPayee,
        fileName: name);
  }

  @override
  void trimTable() {
    List<List<String>> newTable = [];
    for (var row in table) {
      newTable.add(FileHandlers.cleanRow(row));
    }
    table = newTable;
  }

  @override
  void format() {
    int extraTopRows = 9;
    table.removeRange(0, extraTopRows);
  }
}
