import 'package:secure_sync/detail_record/ledger.dart';
import 'package:secure_sync/file_handlers/file_handler.dart';

class RegisterFile extends FileHandlers {
  RegisterFile(super.name, super.bytes, super.table, super.header);

  @override
  DetailRecord getRecord(List<String> row) {
    if(row.length < 7) throw RangeError('Invalid index in getRecord');

    String checkNum = row[0];
    String firstPayee = row[3];
    String? secondPayee;
    double amount = double.parse(row[5]);
    DateTime issueDate = DateTime.parse(row[6]);
    String blankOrVoid = ''.padRight(5); // TODO do I care if a check is cleared, processed or other in col 7?
    
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
    int extraTopRows = 4;
    int extraBottomRows = 1;

    // remove all empty cells from table
    for (var row in table) {
      List<String> newRow = FileHandlers.cleanRow(row);
      if (newRow.isNotEmpty) {
        newTable.add(FileHandlers.cleanRow(row));
      }
    }
    table = newTable;

    // remove the first 4 rows
    table.removeRange(0, extraTopRows);

    // remove the last row
    for (int c = 0; c < extraBottomRows; ++c) {
      table.removeLast();
    }
  }
}
