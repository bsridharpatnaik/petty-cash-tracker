import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:expense_tracker/build_config.dart';
import 'package:expense_tracker/handlers/notification_handler.dart';
import 'package:expense_tracker/widgets/excelRenderer.dart';

String? inferMimeType(Uint8List blobData) {
  if (blobData.length > 4) {
    // Check for JPEG (FFD8)
    if (blobData[0] == 0xFF && blobData[1] == 0xD8) {
      return 'image/jpeg';
    }
    // Check for PNG (89504E47)
    if (blobData[0] == 0x89 &&
        blobData[1] == 0x50 &&
        blobData[2] == 0x4E &&
        blobData[3] == 0x47) {
      return 'image/png';
    }
    // Check for PDF (25504446)
    if (blobData[0] == 0x25 &&
        blobData[1] == 0x50 &&
        blobData[2] == 0x44 &&
        blobData[3] == 0x46) {
      return 'application/pdf';
    }
    // Check for Excel (XLSX) - XLSX files start with "504B0304" (PK\x03\x04)
    if (blobData[0] == 0x50 &&
        blobData[1] == 0x4B &&
        blobData[2] == 0x03 &&
        blobData[3] == 0x04) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
  }
  return null; // Unknown type
}

Future<void> saveBlobToDownloads(Uint8List blobData, String fileName) async {
  try {
    Directory? targetDirectory;

    if (Platform.isAndroid) {
      // Check and request storage permission if needed
      if (await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {
        targetDirectory = Directory('/storage/emulated/0/Download');
      } else {
        print('Storage permission denied. Cannot save file.');
        return;
      }
    } else if (Platform.isIOS) {
      targetDirectory = await getApplicationDocumentsDirectory();
    }

    if (targetDirectory == null) {
      print('Failed to get target directory.');
      return;
    }

    // Generate a unique file name if needed
    String filePath = '${targetDirectory.path}/$fileName';
    File file = File(filePath);
    int counter = 1;
    while (file.existsSync()) {
      final nameWithoutExtension = fileName.split('.').first;
      final extension = fileName.contains('.') ? '.${fileName.split('.').last}' : '';
      filePath = '${targetDirectory.path}/$nameWithoutExtension($counter)$extension';
      file = File(filePath);
      counter++;
    }

    // Write the file
    await file.writeAsBytes(blobData);
    print('File saved at: $filePath');

    // Open share sheet on iOS to let the user move it to Downloads
    if (Platform.isIOS) {
      await Share.shareXFiles([XFile(filePath)]);
      NotificationHandler.showDefault("File successfully downloaded.");
    }else{
      NotificationHandler.showDefault("File successfully downloaded in downloads folder.");
    }
  } catch (e) {
    print('Error saving file: $e');
    NotificationHandler.showError('Error saving File: $e');
  }
}

Future<void> requestManageExternalStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    print('Storage permission granted');
  } else {
    print('Storage permission denied, opening app settings...');
    await openAppSettings();
  }
}

Future<void> requestPermission() async {
  if (Platform.isAndroid) {
    // Android 30+ needs manageExternalStorage, else use storage permission
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied, opening app settings...');
      await openAppSettings();
    }
  }
  // else if (Platform.isIOS) {
  //   // iOS needs photo library permission
  //   if (await Permission.photos.request().isGranted) {
  //     print('Photo library access granted');
  //   } else {
  //     print('Photo library access denied, opening app settings...');
  //     await openAppSettings();
  //   }
  // }
}

void showBlobDialog(
    BuildContext context, Uint8List blobData, String? mimeType, String fileName) {
  mimeType ??= inferMimeType(blobData) ?? 'application/octet-stream';
  Widget content;
  if (mimeType.startsWith('image/')) {
    content = Image.memory(blobData); // Display Image
  } else if (mimeType == 'application/pdf') {
    content = SfPdfViewer.memory(blobData); // Add PDF viewer
  } else if (mimeType == 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') {
    content = ExcelFileRenderer(blobData: blobData);
  } else {
    content = const Center(child: Text("File preview not supported."));
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: content),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      BuildConfig.appIsActive = true;
                      try{
                        await requestPermission();
                        await saveBlobToDownloads(blobData, fileName);
                      }finally{
                        BuildConfig.appIsActive = false;
                      }
                    },
                    child: const Text("Download"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Close"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
