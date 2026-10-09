class History {
  final int id;
  final String message;
  final String creationDate;
  final String historyType;
  final int? foreignKey;

  History({
    required this.id,
    required this.message,
    required this.creationDate,
    required this.historyType,
    this.foreignKey,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'],
      message: json['message'],
      creationDate: json['creationDate'],
      historyType: json['historyType'],
      foreignKey: json['foreignKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'creationDate': creationDate,
      'historyType': historyType,
      'foreignKey': foreignKey,
    };
  }
}
