import 'package:expense_tracker/models/transactionModel.dart';

class GroupedSummary {
  int carryForward;
  int totalIncome;
  int totalExpense;
  int balance;
  List<DailySummary> dailySummaries;

  GroupedSummary({
    required this.carryForward,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.dailySummaries,
  });

  factory GroupedSummary.fromJson(Map<String, dynamic> json) {
    return GroupedSummary(
      carryForward: (json['carryForward'] ?? 0.0).toInt(),
      totalIncome: (json['totalIncome'] ?? 0.0).toInt(),
      totalExpense: (json['totalExpense'] ?? 0.0).toInt(),
      balance: (json['balance'] ?? 0.0).toInt(),
      dailySummaries: (json['dailySummaries'] as List?)
          ?.map((e) => DailySummary.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carryForward': carryForward,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'dailySummaries': dailySummaries.map((e) => e.toJson()).toList(),
    };
  }
}

class DailySummary {
  String date;
  int carryForward;
  int totalIncome;
  int totalExpense;
  List<Transaction> incomeTransactions;
  List<Transaction> expenseTransactions;
  int balance;

  DailySummary({
    required this.date,
    required this.carryForward,
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.balance,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'] ?? '',
      carryForward: (json['carryForward'] ?? 0).toInt(),
      totalIncome: (json['totalIncome'] ?? 0).toInt(),
      totalExpense: (json['totalExpense'] ?? 0).toInt(),
      incomeTransactions: (json['incomeTransactions'] as List?)
          ?.map((e) => Transaction.fromJson(e))
          .toList() ??
          [],
      expenseTransactions: (json['expenseTransactions'] as List?)
          ?.map((e) => Transaction.fromJson(e))
          .toList() ??
          [],
      balance: (json['balance'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'carryForward': carryForward,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'incomeTransactions':
      incomeTransactions.map((e) => e.toJson()).toList(),
      'expenseTransactions':
      expenseTransactions.map((e) => e.toJson()).toList(),
      'balance': balance,
    };
  }
}
