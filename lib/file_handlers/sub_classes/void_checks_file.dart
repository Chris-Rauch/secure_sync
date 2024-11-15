import 'package:secure_sync/detail_record/ledger.dart';
import 'package:secure_sync/file_handlers/file_handler.dart';

class VoidChecksFile extends FileHandlers {
  VoidChecksFile(super.name, super.bytes, super.table);

  @override
  DetailRecord getRecord(List<String> row) {
    // TODO: implement getRecord
    throw UnimplementedError();
  }
  
  @override
  List<List<String>> trimTable() {
    // TODO: implement trimTable
    throw UnimplementedError();
  }
  
  @override
  void format() {
    // TODO: implement format
  }
}
