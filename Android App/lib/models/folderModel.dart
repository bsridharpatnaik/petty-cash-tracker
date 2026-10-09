class Folder {
  int id;
  String name;
  int parentFolderId;
  List<SubFolder> subFolders;
  List<FileData> files;
  List<Breadcrumb> breadcrumb;
  String username;

  Folder({
    required this.id,
    required this.name,
    required this.parentFolderId,
    required this.subFolders,
    required this.files,
    required this.breadcrumb,
    required this.username,
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      name: json['name'] ?? '', // Default to empty string if 'name' is null
      parentFolderId: json['parentFolderId'] ?? 0, // Default to 0 if 'parentFolderId' is null
      subFolders: (json['subFolders'] as List?)
          ?.map((subFolderJson) => SubFolder.fromJson(subFolderJson))
          .toList() ??
          [], // Default to empty list if 'subFolders' is null
      files: (json['files'] as List?)
          ?.map((fileJson) => FileData.fromJson(fileJson))
          .toList() ??
          [], // Default to empty list if 'files' is null
      breadcrumb: (json['breadcrumb'] as List?)
          ?.map((breadcrumbJson) => Breadcrumb.fromJson(breadcrumbJson))
          .toList() ??
          [], // Default to empty list if 'breadcrumb' is null
      username: json['username'] ?? '', // Default to empty string if 'username' is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentFolderId': parentFolderId,
      'subFolders': subFolders.map((subFolder) => subFolder.toJson()).toList(),
      'files': files.map((file) => file.toJson()).toList(),
      'breadcrumb': breadcrumb.map((breadcrumb) => breadcrumb.toJson()).toList(),
      'username': username,
    };
  }
}

class SubFolder {
  int id;
  String name;
  int itemCount;
  String? lastUpdateDate;

  SubFolder({
    required this.id,
    required this.name,
    required this.itemCount,
    this.lastUpdateDate,
  });

  factory SubFolder.fromJson(Map<String, dynamic> json) {
    return SubFolder(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      name: json['name'] ?? '', // Default to empty string if 'name' is null
      itemCount: json['itemCount'] ?? 0, // Default to 0 if 'itemCount' is null
      lastUpdateDate: json['lastUpdateDate'], // No default value needed for this field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemCount': itemCount,
      'lastUpdateDate': lastUpdateDate,
    };
  }
}

class FileData {
  int id;
  String filename;
  double sizeMB;
  String? lastUpdateDate;

  FileData({
    required this.id,
    required this.filename,
    required this.sizeMB,
    this.lastUpdateDate,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      filename: json['filename'] ?? '', // Default to empty string if 'filename' is null
      sizeMB: json['sizeMB']?.toDouble() ?? 0.0, // Default to 0.0 if 'sizeMB' is null
      lastUpdateDate: json['lastUpdateDate'], // No default value needed for this field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'sizeMB': sizeMB,
      'lastUpdateDate': lastUpdateDate,
    };
  }
}

class Breadcrumb {
  int id;
  String name;

  Breadcrumb({
    required this.id,
    required this.name,
  });

  factory Breadcrumb.fromJson(Map<String, dynamic> json) {
    return Breadcrumb(
      id: json['id'] ?? 0, // Default to 0 if 'id' is null
      name: json['name'] ?? '', // Default to empty string if 'name' is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
