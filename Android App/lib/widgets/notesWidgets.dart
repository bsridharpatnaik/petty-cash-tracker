import 'dart:io';
import 'dart:typed_data';
import 'package:bot_toast/bot_toast.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:expense_tracker/build_config.dart';
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/handlers/http_request_handler.dart';
import 'package:expense_tracker/models/noteModel.dart';
import 'package:expense_tracker/models/transactionModel.dart';
import 'package:expense_tracker/widgets/blobDialog.dart';
import 'package:camera/camera.dart';

class NotesWidgets {
  BuildContext context;
  final Future<void> Function() onRefresh;
  NotesWidgets(this.onRefresh, this.context);

  noteCard(Note note, {bool webModal = false}) {
    double width = MediaQuery.of(context).size.width;
    if(webModal && width>600){
      width = 600;
    }
    
    // Parse date for better formatting
    final noteDate = DateFormat('yyyy-MM-dd').parse(note.date);
    final formattedDate = DateFormat('dd MMM yyyy').format(noteDate);
    final dayOfWeek = DateFormat('EEE').format(noteDate);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: width,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with date badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Constants.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayOfWeek.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Constants.primaryBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd').format(noteDate),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Constants.primaryBlue,
                            ),
                          ),
                          Text(
                            DateFormat('MMM').format(noteDate),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Constants.primaryBlue.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Note text
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: note.fileUuids.isNotEmpty ? 40 : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.text,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // File attachment pin indicator - top right
            if (note.fileUuids.isNotEmpty)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // Capture the widget's context before showing bottom sheet
                    final widgetContext = this.context;
                    showModalBottomSheet(
                      context: widgetContext,
                      backgroundColor: Colors.transparent,
                      builder: (bottomSheetContext) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file,
                                      color: Constants.primaryBlue,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Attachments (${note.fileUuids.length})',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Constants.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => Navigator.pop(bottomSheetContext),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...note.fileUuids.map((fileUuid) {
                              return GestureDetector(
                                onTap: () async {
                                  // Close bottom sheet first
                                  Navigator.pop(bottomSheetContext);
                                  // Use widget's context for async operations
                                  Uint8List blobData =
                                  await HttpRequestHandler(widgetContext)
                                      .fetchBlob(fileUuid);
                                  // Check if context is still valid before showing dialog
                                  if (widgetContext.mounted) {
                                    showBlobDialog(
                                        widgetContext, blobData, null, 'file_$fileUuid');
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Constants.gray10,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Constants.gray30,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Constants.primaryBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.insert_drive_file,
                                          color: Constants.primaryBlue,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'file_$fileUuid',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tap to view',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey[400],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Constants.primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Constants.primaryBlue.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${note.fileUuids.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
            ),
        );
  }

  addNoteSheet(Note? note, DateTime selectedDate) {
    TextEditingController textController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    bool editMode = false;
    List<FileInfo> fileMaps = [];
    List<dynamic> _pickedFiles = [];

    if (note != null) {
      textController.text = note.text;
      selectedDate = DateFormat('yyyy-MM-dd').parse(note.date);
      editMode = true;
      // Convert fileUuids to FileInfo objects for display
      fileMaps = note.fileUuids.map((uuid) => FileInfo(
        fileUuid: uuid,
        filename: 'file_$uuid',
        uploadDate: '',
      )).toList();
    }

    dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);

    Future<void> _pickFile(StateSetter setStateModal) async {
      BuildConfig.appIsActive = true;
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.any,
        );
        if (result != null) {
          if (BuildConfig.isWeb()) {
            setStateModal(() {
              _pickedFiles.add(result.files.single);
            });
            var fileMap = await HttpRequestHandler(context).fileUploadWeb(result.files.single);
            if (fileMap != null) {
              fileMaps.add(FileInfo.fromJson(fileMap));
            }
          } else {
            File _file = File(result.files.single.path!);
            setStateModal(() {
              _pickedFiles.add(_file);
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
      BuildConfig.appIsActive = true;
      try {
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

                    Navigator.of(context).pop();
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
                                fileMaps.removeAt(index);
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
                          width: width * 0.85,
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
                      editMode ? "Update Note" : 'Add Note',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
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
                      'Note Text',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: textController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Enter your note...',
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
                          await _pickFile(setStateModal);
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
                            'Add Note',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            print("📝 [NOTES UI] Add Note button pressed");
                            if (textController.text.isEmpty) {
                              print("📝 [NOTES UI] Add Note validation failed: Empty text");
                              BotToast.showText(text: "Enter note text");
                              return;
                            }

                            if (selectedDate == null) {
                              print("📝 [NOTES UI] Add Note validation failed: No date selected");
                              BotToast.showText(text: "Please select a date");
                              return;
                            }

                            var body = {
                              "date": DateFormat('yyyy-MM-dd').format(selectedDate),
                              "text": textController.text,
                              "files": fileMaps.map((f) => {
                                "fileUuid": f.fileUuid,
                                "filename": f.filename,
                              }).toList(),
                            };
                            print("📝 [NOTES UI] Add Note - Preparing request body:");
                            print("📝 [NOTES UI]   Date: ${body['date']}");
                            print("📝 [NOTES UI]   Text: ${body['text']}");
                            print("📝 [NOTES UI]   Files: ${body['files']}");
                            var respJson = await HttpRequestHandler(context)
                                .createNote(body);
                            if (respJson['status'] == 201) {
                              print("📝 [NOTES UI] Add Note SUCCESS - Closing sheet and refreshing");
                              Navigator.pop(context);
                              onRefresh();
                            } else {
                              print("📝 [NOTES UI] Add Note FAILED - Status: ${respJson['status']}");
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
                            'Update Note',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            print("📝 [NOTES UI] Update Note button pressed for note ID: ${note!.id}");
                            if (textController.text.isEmpty) {
                              print("📝 [NOTES UI] Update Note validation failed: Empty text");
                              BotToast.showText(text: "Enter note text");
                              return;
                            }

                            var body = {
                              "text": textController.text,
                              "files": fileMaps.map((f) => {
                                "fileUuid": f.fileUuid,
                                "filename": f.filename,
                              }).toList(),
                            };
                            print("📝 [NOTES UI] Update Note - Preparing request body:");
                            print("📝 [NOTES UI]   Note ID: ${note.id}");
                            print("📝 [NOTES UI]   Text: ${body['text']}");
                            print("📝 [NOTES UI]   Files: ${body['files']}");
                            var respJson = await HttpRequestHandler(context)
                                .updateNote(body, note.id.toString());
                            if (respJson['status'] == 200) {
                              print("📝 [NOTES UI] Update Note SUCCESS - Closing sheet and refreshing");
                              Navigator.pop(context);
                              onRefresh();
                            } else {
                              print("📝 [NOTES UI] Update Note FAILED - Status: ${respJson['status']}");
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

  editNoteSheet(Note note) {
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
                            'Note Details',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                child: const Icon(Icons.create_outlined),
                                onTap: () {
                                  Navigator.pop(context);
                                  addNoteSheet(
                                      note, DateFormat('yyyy-MM-dd').parse(note.date));
                                },
                              ),
                              GestureDetector(
                                child: const Icon(Icons.delete_outline),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                                              'Do you really want to delete this note? This action cannot be undone!',
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
                                                    print("📝 [NOTES UI] Delete Note button pressed for note ID: ${note.id}");
                                                    bool deleted = await HttpRequestHandler(context)
                                                        .deleteNote(note.id.toString());
                                                    if(deleted){
                                                      print("📝 [NOTES UI] Delete Note SUCCESS - Closing dialog and refreshing");
                                                      Navigator.of(context).pop();
                                                      onRefresh();
                                                    } else {
                                                      print("📝 [NOTES UI] Delete Note FAILED");
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF3085D6),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text("Yes, delete it!",
                                                    style: TextStyle(
                                                      color: Colors.white
                                                    ),),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  style: OutlinedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        color: Colors.white
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      noteCard(note, webModal: true),
                      const SizedBox(
                        height: 10,
                      ),
                      if (note.fileUuids.isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: note.fileUuids.map((fileUuid) {
                            return GestureDetector(
                              onTap: () async {
                                // Store context before async operation
                                final currentContext = context;
                                Uint8List blobData =
                                await HttpRequestHandler(currentContext)
                                    .fetchBlob(fileUuid);
                                // Check if context is still valid before showing dialog
                                if (currentContext.mounted) {
                                  showBlobDialog(
                                      currentContext, blobData, null, 'file_$fileUuid');
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0),
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
                                            'file_$fileUuid',
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

