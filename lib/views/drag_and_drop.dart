import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:secure_sync/file_io/third_eye_file.dart';

class DragAndDropView extends StatefulWidget {
  const DragAndDropView({super.key});

  @override
  DragAndDropViewState createState() => DragAndDropViewState();
}

class DragAndDropViewState extends State<DragAndDropView> {
  late DropzoneViewController thirdEyeController;
  late DropzoneViewController quickbooksController;

  String thirdEyeMessage = 'Drag and drop files here for Third Eye, or click ';
  String quickbooksMessage =
      'Drag and drop files here for Quickbooks, or click ';

  bool isHoveringThirdEye = false;
  bool isHoveringQuickbooks = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Secure Sync')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Third Eye Dropzone
            _buildDropZone(
              label: 'Third Eye',
              message: thirdEyeMessage,
              onDropzoneCreated: (controller) =>
                  thirdEyeController = controller,
              isHovering: isHoveringThirdEye,
              onHoverChange: (hovering) =>
                  setState(() => isHoveringThirdEye = hovering),
              onDrop: (file) async {
                final name = await thirdEyeController.getFilename(file);
                final size = await thirdEyeController.getFileSize(file);
                final mime = await thirdEyeController.getFileMIME(file);
                final data = await thirdEyeController.getFileData(file);

                setState(() {
                  thirdEyeMessage =
                      'File dropped: $name, Size: $size bytes, Type: $mime';
                });
              },
              onTap: () async {
                final file = await thirdEyeController.pickFiles();
                final name = await thirdEyeController.getFilename(file[0]);
                final size = await thirdEyeController.getFileSize(file[0]);
                final mime = await thirdEyeController.getFileMIME(file[0]);
                final data = await thirdEyeController.getFileData(file[0]);

                setState(() {
                  thirdEyeMessage =
                      'File selected: $name,\nSize: $size bytes,\nType: $mime';
                });
              },
            ),
            const SizedBox(height: 30), // Spacing between drop zones

            // Quickbooks Dropzone
            _buildDropZone(
              label: 'Quickbooks',
              message: quickbooksMessage,
              onDropzoneCreated: (controller) =>
                  quickbooksController = controller,
              isHovering: isHoveringQuickbooks,
              onHoverChange: (hovering) =>
                  setState(() => isHoveringQuickbooks = hovering),
              onDrop: (file) async {
                final name = await quickbooksController.getFilename(file);
                final size = await quickbooksController.getFileSize(file);
                final mime = await quickbooksController.getFileMIME(file);

                setState(() {
                  quickbooksMessage =
                      'File dropped: $name, Size: $size bytes, Type: $mime';
                });
              },
              onTap: () async {
                final file = await quickbooksController.pickFiles();
                final name = await quickbooksController.getFilename(file[0]);
                final size = await quickbooksController.getFileSize(file[0]);
                final mime = await quickbooksController.getFileMIME(file[0]);

                setState(() {
                  quickbooksMessage =
                      'File selected: $name, Size: $size bytes, Type: $mime';
                });
              },
            ),
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
          width: 300,
          height: 200,
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
}
