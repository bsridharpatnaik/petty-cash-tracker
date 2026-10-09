class Transaction {
  final int id;
  final String date;
  final String creationDate;
  final String modificationDate;
  final String title;
  final String party;
  final int amount;
  final String transactionType;
  final String? description;
  final List<FileInfo> fileInfos;

  Transaction({
    required this.id,
    required this.date,
    required this.creationDate,
    required this.modificationDate,
    required this.title,
    required this.party,
    required this.amount,
    required this.transactionType,
    this.description,
    required this.fileInfos,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    var fileInfosFromJson = json['fileInfos'] as List? ?? [];
    List<FileInfo> fileInfosList = fileInfosFromJson.map((i) => FileInfo.fromJson(i)).toList();

    return Transaction(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      creationDate: json['creationDate'] ?? '',
      modificationDate: json['modificationDate'] ?? '',
      title: json['title'] ?? '',
      party: json['party'] ?? '',
      amount: json['amount'] ?? 0,
      transactionType: json['transactionType'] ?? '',
      description: json['description'],
      fileInfos: fileInfosList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'creationDate': creationDate,
      'modificationDate': modificationDate,
      'title': title,
      'party': party,
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'fileInfos': fileInfos.map((i) => i.toJson()).toList(),
    };
  }
}

class FileInfo {
  String fileUuid;
  String filename;
  String uploadDate;

  FileInfo({
    required this.fileUuid,
    required this.filename,
    required this.uploadDate,
  });

  factory FileInfo.fromJson(Map<String, dynamic> json) {
    return FileInfo(
      fileUuid: json['fileUuid'] ?? '',
      filename: json['filename'] ?? '',
      uploadDate: json['uploadDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileUuid': fileUuid,
      'filename': filename,
      'uploadDate': uploadDate,
    };
  }
}

class TransactionResponse {
  final Map<String, List<Transaction>> transactionsByType;
  final int carryForward;
  final int totalIncome;
  final int totalExpense;
  final int balance;
  final String username;
  final List<Transaction> allTransactions;

  TransactionResponse({
    required this.transactionsByType,
    required this.carryForward,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.username,
    required this.allTransactions,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    var transactionsByTypeFromJson = json['transactionsByType']??{
      "EXPENSE": [],
      "INCOME": []
    } as Map<String, dynamic>;
    Map<String, List<Transaction>> transactionsByType = {};

    transactionsByTypeFromJson.forEach((key, value) {
      var list = value as List;
      transactionsByType[key] = list.map((item) => Transaction.fromJson(item)).toList();
    });

    List<Transaction> allTransactions = [
      ...transactionsByType['EXPENSE'] ?? [],
      ...transactionsByType['INCOME'] ?? [],
    ];
    allTransactions.sort((a, b) => b.creationDate.compareTo(a.creationDate));

    return TransactionResponse(
      transactionsByType: transactionsByType,
      carryForward: json['carryForward']??0,
      totalIncome: json['totalIncome']??0,
      totalExpense: json['totalExpense']??0,
      balance: json['balance']??0,
      username: json['username']??'',
      allTransactions: allTransactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionsByType': transactionsByType.map((key, value) {
        return MapEntry(key, value.map((e) => e.toJson()).toList());
      }),
      'carryForward': carryForward,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'username': username,
      'allTransactions': allTransactions.map((e) => e.toJson()).toList(),
    };
  }
}

