import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:secure_sync/detail_record/ledger.dart';
//import 'package:secure_sync/error_handling/logging.dart';
import 'package:secure_sync/file_handlers/file_handler_factory.dart';

class DragAndDropView extends StatefulWidget {
  const DragAndDropView({super.key});

  @override
  DragAndDropViewState createState() => DragAndDropViewState();
}

class DragAndDropViewState extends State<DragAndDropView> {
  late DropzoneViewController thirdEyeController;

  String dropBoxMessage = 'Drag and drop files here, or click ';

  bool isHoveringThirdEye = false;
  bool isHoveringQuickbooks = false;

  Ledger ledger = Ledger();
  List<String> rows = [];
  List<List<String>> table = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Secure Sync')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // File Dropzone
            _buildDropZone(
              label: 'Add Check Register',
              message: dropBoxMessage,
              onDropzoneCreated: (controller) =>
                  thirdEyeController = controller,
              isHovering: isHoveringThirdEye,
              onHoverChange: (hovering) =>
                  setState(() => isHoveringThirdEye = hovering),
              onDrop: (file) async {
                final name = await thirdEyeController.getFilename(file);
                //final size = await thirdEyeController.getFileSize(file);
                //final mime = await thirdEyeController.getFileMIME(file);
                final data = await thirdEyeController.getFileData(file);
                handleFileDrop(name, data, ledger);

                setState(() {
                  _addRow(name);
                });
              },
              onTap: () async {
                final file = await thirdEyeController.pickFiles();
                final name = await thirdEyeController.getFilename(file[0]);
                //final size = await thirdEyeController.getFileSize(file[0]);
                //final mime = await thirdEyeController.getFileMIME(file[0]);
                final data = await thirdEyeController.getFileData(file[0]);
                handleFileDrop(name, data, ledger);

                setState(() {
                  dropBoxMessage = name;
                });
              },
            ), // _buildDropZone
            _buildFileDisplay(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      ledger.download();
                    },
                    child: const Text('Download'),
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone({
    required String label,
    required String message,
    required ValueChanged<DropzoneViewController> onDropzoneCreated,
    required bool isHovering,
    required ValueChanged<bool> onHoverChange,
    required Future<void> Function(dynamic file) onDrop,
    required Future<void> Function() onTap,
  }) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
        SizedBox(
          width: 400,
          height: 300,
          child: Stack(
            children: [
              DropzoneView(
                onCreated: onDropzoneCreated,
                onDropFile: onDrop,
                onHover: () => onHoverChange(true),
                onLeave: () => onHoverChange(false),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isHovering ? Colors.teal.shade50 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isHovering ? Colors.teal : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: message,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'here',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = onTap,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileDisplay() {
    return Column(
      children: [
        SizedBox(
          height: 300,
          width: 300,
          child: ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      rows[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () => _removeRow(index),
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTable(List<List<String>> table) {
    table = [
      ['Str1', 'Str2', 'Str3']
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Allow horizontal scrolling
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical, // Allow vertical scrolling
        child: Table(
          border: TableBorder.all(),
          children: table.map<TableRow>((row) {
            return TableRow(
              children: row.map<Widget>((cell) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(cell),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Method to add a new row
  void _addRow(String fileName) {
    setState(() {
      rows.add(fileName);
    });
  }

  // Method to remove a row
  void _removeRow(int index) {
    setState(() {
      rows.removeAt(index);
    });
  }
}

void handleFileDrop(String fileName, Uint8List fileBytes, Ledger ledger) {
  try {
    final reader = FileHandlerFactory.createReader(fileName, fileBytes);
    reader.trimTable();
    ledger.addAllRecords(reader.getRecords());
    //ledger.download();
    //print(ledger.getDetailRecords());
    //print(ledger.getTotalRecord());
  } catch (e) {
    //logger.severe(e);
    // ignore: avoid_print
    print(e);
  }
}
