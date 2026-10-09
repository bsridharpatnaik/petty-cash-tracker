import 'package:flutter/material.dart';

import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/handlers/http_request_handler.dart';
import 'package:expense_tracker/models/historyModel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<History> history = [];
  double width = 0;
  @override
  void initState() {
    // TODO: implement initState
    historyGet();
    super.initState();
  }

  historyGet() async {
    List<dynamic> respJson =
    await HttpRequestHandler(context).getHistory();
    if (respJson.isNotEmpty) {
      setState(() {
        history = respJson.map((data) => History.fromJson(data)).toList();
      });
    } else {
      print("Not Authorised");
    }
  }

  historyCard(History history){
    return Card(
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
                      width: width*0.80,
                      child: Text(
                        history.message,
                        softWrap: true,
                        style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(history.creationDate),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ...List.generate(history.length, (index){
                return historyCard(history[index]);
              })
            ],
          ),
        )
    );
  }
}
