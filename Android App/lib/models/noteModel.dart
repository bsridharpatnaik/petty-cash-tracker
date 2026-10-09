class Note {
  final int id;
  final String date;
  final String text;
  final List<String> fileUuids;

  Note({
    required this.id,
    required this.date,
    required this.text,
    required this.fileUuids,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    // Handle both 'files' array (new API format) and 'fileUuids' array (backward compatibility)
    List<String> fileUuidsList = [];
    
    if (json['files'] != null && json['files'] is List) {
      // New API format: files is an array of objects with fileUuid and filename
      fileUuidsList = (json['files'] as List)
          .map((file) => file['fileUuid']?.toString() ?? '')
          .where((uuid) => uuid.isNotEmpty)
          .toList();
    } else if (json['fileUuids'] != null && json['fileUuids'] is List) {
      // Backward compatibility: fileUuids is a list of strings
      fileUuidsList = (json['fileUuids'] as List)
          .map((e) => e.toString())
          .toList();
    }
    
    return Note(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      text: json['text'] ?? '',
      fileUuids: fileUuidsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'text': text,
      'fileUuids': fileUuids,
    };
  }
}

class NotesResponse {
  final List<Note> notes;
  final int count;

  NotesResponse({
    required this.notes,
    required this.count,
  });

  factory NotesResponse.fromJson(Map<String, dynamic> json) {
    return NotesResponse(
      notes: (json['notes'] as List?)
          ?.map((e) => Note.fromJson(e))
          .toList() ??
          [],
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notes': notes.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

