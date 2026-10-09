import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/build_config.dart';
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/handlers/http_request_handler.dart';
import 'package:expense_tracker/handlers/notification_handler.dart';
import 'package:expense_tracker/models/folderModel.dart';
import 'package:expense_tracker/widgets/blobDialog.dart';

class DocumentationVault extends StatefulWidget {
  final String folderId;
  const DocumentationVault({required this.folderId, super.key});

  @override
  State<DocumentationVault> createState() => _DocumentationVaultState();
}

enum AppBarMenuItems { download, delete }

class _DocumentationVaultState extends State<DocumentationVault> {
  double width = 0;
  Folder folder = Folder.fromJson({});
  TextEditingController folderNameController = TextEditingController();
  bool kIsWeb = false;
  @override
  void initState() {
    // TODO: implement initState
    folderGet();
    super.initState();
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

  folderGet() async {
    Map<String, dynamic> respJson =
        await HttpRequestHandler(context).fileVaultGet(widget.folderId);
    if (respJson.isNotEmpty) {
      setState(() {
        folder = Folder.fromJson(respJson);
      });
    } else {
      print("Not Authorised");
    }
  }

  subFolderCard(SubFolder subFolder) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DocumentationVault(
                      folderId: subFolder.id.toString(),
                    )));
      },
      child: Card(
        child: Container(
          color: Constants.gray15,
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Constants.gray30,
                    // child:
                    // Text(transaction.transactionType == 'INCOME' ? 'I' : 'E'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: width * 0.68,
                            child: Text(
                              subFolder.name,
                              softWrap: true,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ),
                          PopupMenuButton<AppBarMenuItems>(
                            iconColor: Colors.black,
                            position: PopupMenuPosition.under,
                            onSelected: (AppBarMenuItems item) {
                              setState(() {
                                if (item == AppBarMenuItems.delete) {
                                  folderDeleteDialog(
                                      context: context,
                                      fileId: subFolder.id.toString());
                                }
                              });
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<AppBarMenuItems>>[
                              // const PopupMenuItem<AppBarMenuItems>(
                              //   value: AppBarMenuItems.download,
                              //   child: Text('Download'),
                              // ),
                              const PopupMenuItem<AppBarMenuItems>(
                                value: AppBarMenuItems.delete,
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(subFolder.itemCount.toString()),
                            if (subFolder.lastUpdateDate != null)
                              Text(subFolder.lastUpdateDate.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  fileCard(FileData file) {
    return GestureDetector(
      onTap: () async {
        Uint8List blobData = await HttpRequestHandler(context)
            .fetchVaultBlob(file.id.toString());
        showBlobDialog(context, blobData, null, file.filename);
      },
      child: Card(
        child: Container(
          color: Constants.gray15,
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Constants.gray30,
                    // child:
                    // Text(transaction.transactionType == 'INCOME' ? 'I' : 'E'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width * 0.80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: width * 0.68,
                              child: Text(
                                file.filename.toString(),
                                softWrap: true,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                            PopupMenuButton<AppBarMenuItems>(
                              iconColor: Colors.black,
                              position: PopupMenuPosition.under,
                              onSelected: (AppBarMenuItems item) async {
                                if (item == AppBarMenuItems.delete) {
                                  fileDeleteDialog(
                                      context: context,
                                      fileId: file.id.toString());
                                }
                                if (item == AppBarMenuItems.download) {
                                  Uint8List blobData =
                                      await HttpRequestHandler(context)
                                          .fetchVaultBlob(file.id.toString());
                                  await saveBlobToDownloads(
                                      blobData, file.filename);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<AppBarMenuItems>>[
                                const PopupMenuItem<AppBarMenuItems>(
                                  value: AppBarMenuItems.download,
                                  child: Text('Download'),
                                ),
                                const PopupMenuItem<AppBarMenuItems>(
                                  value: AppBarMenuItems.delete,
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: width * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(file.lastUpdateDate.toString()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _fileName;
  File? _file;
  Uint8List? _fileBytes;
  Future<void> _pickFile(StateSetter setStateModal) async {
    BuildConfig.appIsActive = true;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
        // allowedExtensions: ['jpg', 'png', 'pdf', 'docx'],
      );
      if (result != null) {
        setStateModal(() {
          _file = File(result.files.single.path!); // Store the file
          _fileName = result.files.single.name; // Store the file name
          _fileBytes = result.files.single.bytes;
        });
      } else {
        setStateModal(() {
          _file = null; // Reset if no file is selected
          _fileName = null;
          _fileBytes = null;
        });
      }
    } finally {
      BuildConfig.appIsActive = false;
    }
  }

  _pickImageFromCamera() async {
    BuildConfig.appIsActive = true;
    try {
      var image = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 60);
      if (image != null) {
        setState(() {
          _file = File(image.path);
          _fileName = path.basename(_file!.path);
        });
            } else {
        // Toaster.e(_context, message: "No image is scanned.");
      }
      return null;
    } finally {
      BuildConfig.appIsActive = false;
    }
  }

  addFolderSheet() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: const Icon(Icons.cancel_outlined),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Folder',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            ' Folder Name',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextField(
                        controller: folderNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Folder Name',
                          filled: true,
                          fillColor: Constants.gray10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add Folder',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            var body = {
                              "name": folderNameController.text,
                              "parentId": folder.id
                            };
                            var respJson = await HttpRequestHandler(context)
                                .addFolder(body);
                            if (respJson['status'] == 200) {
                              Navigator.pop(context);
                              folderGet();
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  addFileSheet() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Get width here once
        final double width = MediaQuery.of(context).size.width;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 16,
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: width, // Use the width variable
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: const Icon(Icons.cancel_outlined),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add file',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                              onTap: () {
                                _pickImageFromCamera();
                              },
                              child: const Icon(Icons.camera_alt_outlined))
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      DottedBorder(
                        options: const RectDottedBorderOptions(
                          color: Colors.grey,
                          strokeWidth: 1,
                          dashPattern: [6, 3],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            _pickFile(setStateModal);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 100,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file,
                                      size: 40, color: Colors.grey),
                                  Text(
                                    'Browse Files\nJPG, PNG, PDF, EXCEL',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Display file name and thumbnail if a file is selected
                      const SizedBox(height: 5),
                      if (_file != null) ...[ // _file is now XFile?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Conditional rendering for image thumbnail
                                if ((_fileName!.endsWith('.jpg') ||
                                    _fileName!.endsWith('.png')))
                                  if (kIsWeb) // For web, use Image.memory with bytes
                                    if (_fileBytes != null)
                                      Image.memory(
                                        _fileBytes!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    else // Fallback if bytes are null (shouldn't happen with correct _pickFile)
                                      const Icon(Icons.image_outlined, size: 50)
                                  else // For non-web, use Image.file (requires dart:io)
                                    Image.file(
                                      File(_file!.path), // Convert XFile.path to File
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: width * .73,
                                  child: Text(
                                    _fileName!,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              child: const Icon(Icons.cancel_outlined),
                              onTap: () {
                                setStateModal(() {
                                  _file = null;
                                  _fileName = null;
                                  _fileBytes = null; // Clear bytes as well
                                });
                              },
                            )
                          ],
                        ),
                      ],
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add File',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_file != null) { // Only proceed if a file is selected
                              await HttpRequestHandler(context)
                                  .vaultFileUpload(_file!, folder.id.toString());
                              Navigator.pop(context);
                              folderGet();
                            } else {
                              // Optionally show a message if no file is selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a file to upload')),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  void _handleMenuSelection(String value) {
    if (value == 'addFolder') {
      addFolderSheet();
    } else if (value == 'addFile') {
      addFileSheet();
    }
  }

  Future<void> fileDeleteDialog(
      {required BuildContext context, required String fileId}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Do you really want to delete this item? This action cannot be undone!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool deleted =
                          await HttpRequestHandler(context).deleteFiles(fileId);
                      if (deleted) {
                        Navigator.of(context).pop();
                        folderGet();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3085D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Yes, delete it!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red,
                      // side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> folderDeleteDialog(
      {required BuildContext context, required String fileId}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 10),
              const Text(
                "Are you sure?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Do you really want to delete this item? This action cannot be undone!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      bool deleted = await HttpRequestHandler(context)
                          .deleteFolder(fileId);
                      if (deleted) {
                        Navigator.of(context).pop();
                        folderGet();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3085D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Yes, delete it!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red,
                      // side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    kIsWeb = BuildConfig.isWeb();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Documentation Vault"),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            if (folder.breadcrumb.length > 1) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DocumentationVault(
                            folderId: folder
                                .breadcrumb[folder.breadcrumb.length - 2].id
                                .toString(),
                          )));
            } else {
              Navigator.pop(context); // Go back to the previous screen
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      child: const Text(
                        'Home',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DocumentationVault(
                                      folderId:
                                          folder.breadcrumb[0].id.toString(),
                                    )));
                      },
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    if (folder.breadcrumb.isNotEmpty)
                      ...List.generate(folder.breadcrumb.length - 1, (index) {
                        return GestureDetector(
                          child: Text(
                            "/ ${folder.breadcrumb[index + 1].name}",
                            style: const TextStyle(color: Colors.blue),
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DocumentationVault(
                                          folderId: folder
                                              .breadcrumb[index + 1].id
                                              .toString(),
                                        )));
                          },
                        );
                      })
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  ...List.generate(folder.subFolders.length, (index) {
                    return subFolderCard(folder.subFolders[index]);
                  }),
                  ...List.generate(folder.files.length, (index) {
                    return fileCard(folder.files[index]);
                  }),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        child: FloatingActionButton(
          onPressed: () {
            final RenderBox button = context.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            final RelativeRect position = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(button.size.bottomRight(Offset.zero),
                    ancestor: overlay),
                button.localToGlobal(button.size.bottomRight(Offset.zero),
                    ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );
            showMenu(
              context: context,
              position: position,
              items: <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 'addFolder',
                  child: Text('Add Folder'),
                ),
                const PopupMenuItem(
                  value: 'addFile',
                  child: Text('Add File'),
                ),
              ],
            ).then((value) {
              if (value != null) {
                _handleMenuSelection(value);
              }
            });
          },
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
