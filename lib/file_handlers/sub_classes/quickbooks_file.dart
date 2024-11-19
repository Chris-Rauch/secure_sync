import 'package:secure_sync/detail_record/ledger.dart';
import 'package:secure_sync/file_handlers/file_handler.dart';

class QuickbooksFile extends FileHandlers {
  QuickbooksFile(super.name, super.bytes, super.table, super.header);

  @override
  DetailRecord getRecord(List<String> row) {
    String checkNum = row[1];
    String firstPayee = row[2];
    String? secondPayee;
    double amount = double.parse(row[5]);
    DateTime issueDate = DateTime.parse(row[4]); //TODO difference between issue date and funding date
    const String blankOrVoid = 'V';
    
    return DetailRecord(
        checkNumber: checkNum,
        amount: amount,
        issueDate: issueDate,
        blankOrVoid: blankOrVoid,
        firstPayee: firstPayee,
        secondPayee: secondPayee,
        fileName: name);
        //TODO ^^
  }
  
  @override
  void trimTable() {
    List<List<String>> newTable = [];

    //trim the first col
    FileHandlers.trimCol(table, 0);

    // remove empty cells from table
    for (var row in table) {
      List<String> newRow = FileHandlers.cleanRow(row);
      if (newRow.isNotEmpty) {
        newTable.add(FileHandlers.cleanRow(row));
      }
    }
    table = newTable;
  }
  
  @override
  void format() {
    
  }
}
