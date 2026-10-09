import 'package:flutter/material.dart';
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/models/groupedSummaryModel.dart';
import 'package:expense_tracker/models/transactionModel.dart';
import 'package:expense_tracker/utils/dateTimeFormatter.dart';

class MonthlyGroupTab extends StatefulWidget {
  final GroupedSummary transactions;
  final Function(DateTime date) onChangeTab;

  const MonthlyGroupTab({required this.transactions, required this.onChangeTab, super.key});

  @override
  State<MonthlyGroupTab> createState() => _DayWiseTabState();
}
enum TransactionTab { expenses, income }
class _DayWiseTabState extends State<MonthlyGroupTab> {
  TransactionTab selectedTransactionTab = TransactionTab.expenses;
  late double width;
  @override
  Widget build(BuildContext context) {
    GroupedSummary transactions = widget.transactions;
    width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List.generate(transactions.dailySummaries.length, (index){
                  return GestureDetector(
                    onTap: () => widget.onChangeTab(DateTimeFormatter().parseDate(transactions.dailySummaries[index].date)),
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    5),
                                child: Container(
                                  color: Constants.gray20,
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(transactions.dailySummaries[index].date),
                                      Text("C/F\t\t\t₹${transactions.dailySummaries[index].carryForward.toString()}"),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: width*.45,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Income',
                                              style:
                                              TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              "₹${transactions.dailySummaries[index].totalIncome.toString()}",
                                              style:
                                              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ...List.generate(transactions.dailySummaries[index].incomeTransactions.length, (incomeIndex){
                                        return transactionHistoryCard(transactions.dailySummaries[index].incomeTransactions[incomeIndex]);
                                      })
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: width*.45,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Expenses',
                                              style:
                                              TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              "₹${transactions.dailySummaries[index].totalExpense.toString()}",
                                              style:
                                              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ...List.generate(transactions.dailySummaries[index].expenseTransactions.length, (incomeIndex){
                                        return transactionHistoryCard(transactions.dailySummaries[index].expenseTransactions[incomeIndex]);
                                      })
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Text("Balance", style: TextStyle(fontSize: 16),),
                                  const SizedBox(width: 8,),
                                  Text("₹${transactions.dailySummaries[index].balance.toString()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                                ],
                              ),
                              const SizedBox(height: 10,),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
  transactionHistoryCard(Transaction transaction) {
    return Card(
      child: Container(
        color: Constants.gray10,
        padding: const EdgeInsets.all(10),
        width: width * .45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partyParser(transaction.party),
                      style:
                      const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    Text(titleParser(transaction.title),style:
                    const TextStyle(fontSize: 10,),),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '₹${transaction.amount.toString()}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.green),
                ),
                // Text(DateTimeFormatter()
                //     .formatTime(transaction.modificationDate))
              ],
            ),
          ],
        ),
      ),
    );
  }

  String titleParser(String title) {
    if (title.length > 20) {
      return '${title.substring(0, 20)}...';
    } else {
      return title;
    }
  }

  String partyParser(String title) {
    if (title.length > 15) {
      return '${title.substring(0, 15)}...';
    } else {
      return title;
    }
  }
}