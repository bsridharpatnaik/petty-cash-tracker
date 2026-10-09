import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/build_config.dart';
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/utils/dateTimeFormatter.dart';
import 'package:expense_tracker/handlers/http_request_handler.dart';
import 'package:expense_tracker/models/transactionModel.dart';
import 'package:expense_tracker/widgets/alertDialogs.dart';
import 'package:expense_tracker/widgets/blobDialog.dart';
import 'package:camera/camera.dart';

class TransactionWidgets {
  BuildContext context;
  final Future<void> Function() onRefresh;
  TransactionWidgets(this.onRefresh, this.context);
  transactionHistoryCard(Transaction transaction, {bool webModal = false}) {
    double width = MediaQuery.of(context).size.width;
    if(webModal && width>600){
      width = 600;
    }
    return Card(
      color: transaction.transactionType == 'INCOME'
          ? Constants.income10
          : Constants.expense10,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child:
                  Text(transaction.transactionType == 'INCOME' ? 'I' : 'E'),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.party,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(
                        width: width * .55, child: Text(transaction.title)),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '₹${transaction.amount.toString()}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: transaction.transactionType == 'INCOME'
                          ? Colors.green
                          : Colors.red),
                ),
                Text(DateTimeFormatter()
                    .formatTime(transaction.modificationDate))
              ],
            ),
          ],
        ),
      ),
    );
  }

  addTransactionSheet(Transaction? transaction, DateTime selectedDate) {
    String transactionType = "income";
    TextEditingController titleController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController selectPartyController = TextEditingController();
    bool editMode = false;
    // If selectedDate is in the future, set it to current date
    DateTime now = DateTime.now();
    if (selectedDate.isAfter(now)) {
      selectedDate = now;
    }
    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    final List<String> partyList = BuildConfig.partyList;
    List<dynamic> _pickedFiles = []; // Use dynamic to store File or PlatformFile
    List<FileInfo> fileMaps = [];
    if (transaction != null) {
      titleController.text = transaction.title;
      amountController.text = transaction.amount.toString();
      selectedDate = DateTimeFormatter().parseDate(transaction.date);
      transactionType = transaction.transactionType.toLowerCase();
      editMode = true;
      fileMaps = transaction.fileInfos;
    }

    Future<void> _pickFile(StateSetter setStateModal) async {
      BuildConfig.appIsActive = true;
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.any,
          // allowedExtensions: ['jpg', 'png', 'pdf', 'docx'],
        );
        if (result != null) {
          if (BuildConfig.isWeb()) {
            setStateModal(() {
              _pickedFiles.add(result.files.single); // Store PlatformFile for web
            });
            var fileMap = await HttpRequestHandler(context).fileUploadWeb(result.files.single);
            if (fileMap != null) {
              fileMaps.add(FileInfo.fromJson(fileMap));
            }
          } else {
            File _file = File(result.files.single.path!); // Store the file
            setStateModal(() {
              _pickedFiles.add(_file); // Store dart:io.File for mobile/desktop
            });
            var fileMap = await HttpRequestHandler(context).fileUpload(_file);
            if (fileMap != null) {
              fileMaps.add(FileInfo.fromJson(fileMap));
            }
          }
        }
      } finally {
        BuildConfig.appIsActive = false;
      }
    }

    Future<void> _pickImageFromCameraWeb(StateSetter setStateModal) async {
      print("Attempting to capture image from camera (web)");
      BuildConfig.appIsActive = true;

      try {
        // Get available cameras
        final cameras = await availableCameras();
        final camera = cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        final controller = CameraController(
          camera,
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await controller.initialize();

        // Start preview in a dialog (optional - for UI)
        await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              content: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final XFile image = await controller.takePicture();
                    final bytes = await image.readAsBytes();

                    setStateModal(() {
                      _pickedFiles.add(PlatformFile(
                        name: path.basename(image.path),
                        bytes: bytes,
                        size: bytes.length,
                      ));
                    });

                    var fileMap = await HttpRequestHandler(context).fileUploadWeb(
                      PlatformFile(
                        name: path.basename(image.path),
                        bytes: bytes,
                        size: bytes.length,
                      ),
                    );
                    if (fileMap != null) {
                      fileMaps.add(FileInfo.fromJson(fileMap));
                    }

                    Navigator.of(context).pop(); // Close preview dialog
                  },
                  child: const Text("Capture"),
                ),
              ],
            );
          },
        );

        await controller.dispose();
      } catch (e) {
        print('Error capturing image from camera web: $e');
      } finally {
        BuildConfig.appIsActive = false;
      }
    }

    _pickImageFromCamera(StateSetter setStateModal) async {
      BuildConfig.appIsActive = true;
      try {
        var image = await ImagePicker()
            .pickImage(source: ImageSource.camera, imageQuality: 60);
        if (image != null) {
          setStateModal(() {
            _pickedFiles.add(File(image.path));
          });
          var fileMap =
          await HttpRequestHandler(context).fileUpload(File(image.path));
          if (fileMap != null) {
            fileMaps.add(FileInfo.fromJson(fileMap));
          }
        }
      } finally {
        BuildConfig.appIsActive = false;
      }
    }

    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width;
        if(BuildConfig.isWeb() && width>600){
          width = 600;
        }
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {

            Widget buildFileList() {
              return Column(
                children: List.generate(
                  _pickedFiles.length,
                      (index) {
                    final file = _pickedFiles[index];
                    String fileName;
                    Widget? thumbnail;

                    if (file is File) {
                      fileName = path.basename(file.path);
                      if (fileName.endsWith('.jpg') ||
                          fileName.endsWith('.png') ||
                          fileName.endsWith('.jpeg')) {
                        thumbnail = Image.file(
                          file,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      }
                    } else if (file is PlatformFile) {
                      fileName = file.name;
                      if (fileName.endsWith('.jpg') ||
                          fileName.endsWith('.png') ||
                          fileName.endsWith('.jpeg')) {
                        if (file.bytes != null) {
                          thumbnail = Image.memory(
                            file.bytes!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          );
                        }
                      }
                    } else {
                      fileName = "Unknown File";
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (thumbnail != null) thumbnail,
                              const SizedBox(width: 5),
                              SizedBox(
                                width: width * .73,
                                child: Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: const Icon(Icons.cancel_outlined),
                            onTap: () {
                              setStateModal(() {
                                _pickedFiles.removeAt(index);
                                fileMaps.removeAt(index); // Assuming 1:1 mapping
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }
            Widget buildFileMapsList() {
              return Column(
                children: List.generate(fileMaps.length, (index) {
                  final fileMap = fileMaps[index];

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: width * 0.85, // same width logic as _files
                          child: Text(
                            fileMap.filename,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setStateModal(() {
                              fileMaps.removeAt(index);
                            });
                          },
                          child: const Icon(Icons.cancel_outlined),
                        ),
                      ],
                    ),
                  );
                }),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      editMode ? "Update" : 'Add',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Radio(
                              value: "income",
                              groupValue: transactionType,
                              onChanged: (value) {
                                setStateModal(() {
                                  transactionType =
                                  value!; // Update the selected value
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            const Text('Income'),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Radio(
                              value: "expense",
                              groupValue: transactionType,
                              onChanged: (value) {
                                setStateModal(() {
                                  transactionType =
                                  value!; // Update the selected value
                                });
                              },
                              activeColor: Colors.green,
                            ),
                            const Text('Expense'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Title',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
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
                    const SizedBox(height: 16),
                    const Text(
                      'Amount',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Amount',
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
                    const SizedBox(height: 16),
                    const Text(
                      'Date',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      readOnly: true,
                      controller: dateController,
                      decoration: InputDecoration(
                        hintText: 'Date',
                        filled: true,
                        fillColor: Constants.gray10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                      ),
                      onTap: () async {
                        selectedDate = (await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        ))!;
                        setStateModal(() {
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(selectedDate);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Party',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return partyList;
                        }
                        return partyList.where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        selectPartyController.text = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController fieldController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        if (transaction != null) {
                          fieldController.text = transaction.party;
                        }
                        selectPartyController = fieldController;
                        return TextField(
                          controller: fieldController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Select...',
                            filled: true,
                            fillColor: Constants.gray10,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upload Document',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                            onTap: () async {
                              if (BuildConfig.isWeb()) {
                                await _pickImageFromCameraWeb(setStateModal);
                              } else {
                                await _pickImageFromCamera(setStateModal);
                              }
                            },
                            child: const Icon(Icons.camera_alt_outlined))
                      ],
                    ),
                    const SizedBox(height: 8),
                    DottedBorder(
                      options: RectDottedBorderOptions(
                        color: Colors.grey,
                        strokeWidth: 1,
                        dashPattern: const [6, 3],
                      ),
                      child: GestureDetector(
                        onTap: () async {
                          if (BuildConfig.isWeb()) {
                            await _pickFile(setStateModal);
                          } else {
                            await _pickFile(setStateModal);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, size: 40, color: Colors.grey),
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
                    // DottedBorder(
                    //   color: Colors.grey,
                    //   strokeWidth: 1,
                    //   dashPattern: const [6, 3],
                    //   child: GestureDetector(
                    //     onTap: () async {
                    //       if (BuildConfig.isWeb()) {
                    //         await _pickImageFromCameraWeb(setStateModal);
                    //       } else {
                    //         await _pickImageFromCamera(setStateModal);
                    //       }
                    //     },
                    //     child: Container(
                    //       width: double.infinity,
                    //       height: 100,
                    //       color: Colors.grey[200],
                    //       child: const Center(
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                    //             Text(
                    //               'Capture from Camera\nJPG, PNG',
                    //               textAlign: TextAlign.center,
                    //               style: TextStyle(color: Colors.grey),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 5),
                    if (_pickedFiles.isNotEmpty) buildFileList(),
                    if (fileMaps.isNotEmpty) buildFileMapsList(),
                    const SizedBox(height: 16),
                    if (!editMode)
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
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (titleController.text.isEmpty) {
                              BotToast.showText(text: "Enter Title");
                              return;
                            }

                            if (amountController.text.isEmpty ||
                                int.tryParse(amountController.text) == null) {
                              BotToast.showText(
                                  text: "Please enter a valid amount");
                              return;
                            }

                            if (selectPartyController.text.isEmpty) {
                              BotToast.showText(
                                  text: "Party selection cannot be empty");
                              return;
                            }

                            if (transactionType.isEmpty) {
                              BotToast.showText(
                                  text: "Transaction type cannot be empty");
                              return;
                            }

                            if (selectedDate == null) {
                              BotToast.showText(text: "Please select a date");
                              return;
                            }

                            var body = {
                              "title": titleController.text,
                              "party": selectPartyController.text,
                              "amount": int.parse(amountController.text),
                              "transactionType": transactionType.toUpperCase(),
                              "date": DateFormat('dd-MM-yyyy')
                                  .format(selectedDate),
                              "files": fileMaps
                            };
                            var respJson = await HttpRequestHandler(context)
                                .postTransaction(body);
                            if (respJson['status'] == 201) {
                              Navigator.pop(context);
                              onRefresh();
                            }
                          },
                        ),
                      ),
                    if (editMode)
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
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (titleController.text.isEmpty) {
                              BotToast.showText(text: "Enter Title");
                              return;
                            }

                            if (amountController.text.isEmpty ||
                                int.tryParse(amountController.text) == null) {
                              BotToast.showText(
                                  text: "Please enter a valid amount");
                              return;
                            }

                            if (selectPartyController.text.isEmpty) {
                              BotToast.showText(
                                  text: "Party selection cannot be empty");
                              return;
                            }

                            if (transactionType.isEmpty) {
                              BotToast.showText(
                                  text: "Transaction type cannot be empty");
                              return;
                            }
                            if (selectedDate == null) {
                              BotToast.showText(text: "Please select a date");
                              return;
                            }
                            var body = {
                              "title": titleController.text,
                              "party": selectPartyController.text,
                              "amount": int.parse(amountController.text),
                              "transactionType": transactionType.toUpperCase(),
                              "date": DateFormat('dd-MM-yyyy')
                                  .format(selectedDate),
                              "files": fileMaps
                            };
                            var respJson = await HttpRequestHandler(context)
                                .updateTransaction(
                                body, transaction!.id.toString());
                            if (respJson['status'] == 200) {
                              Navigator.pop(context);
                              onRefresh();
                            }
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  editTransactionSheet(Transaction transaction) {
    double width = MediaQuery.of(context).size.width;
    if(BuildConfig.isWeb() && width>600){
      width = 600;
    }
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Transaction History',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                child: const Icon(Icons.create_outlined),
                                onTap: () {
                                  Navigator.pop(context);
                                  addTransactionSheet(
                                      transaction, DateTime.now());
                                },
                              ),
                              GestureDetector(
                                child: const Icon(Icons.delete_outline),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await AlertDialogs.showConfirmationDialog(
                                      context: context,
                                      transactionId: transaction.id.toString());
                                  onRefresh();
                                },
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      transactionHistoryCard(transaction, webModal: true),
                      const SizedBox(
                        height: 10,
                      ),
                      if (transaction.fileInfos.isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: transaction.fileInfos.map((fileInfo) {
                            return GestureDetector(
                              onTap: () async {
                                Uint8List blobData =
                                await HttpRequestHandler(context)
                                    .fetchBlob(fileInfo.fileUuid);
                                showBlobDialog(
                                    context, blobData, null, fileInfo.filename);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0), // Add spacing between rows
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        SizedBox(
                                          width: width * .9,
                                          child: Text(
                                            fileInfo.filename,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }
}