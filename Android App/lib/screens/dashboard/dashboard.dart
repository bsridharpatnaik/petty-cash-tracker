import 'package:expense_tracker/screens/dashboard/tabs/dateWiseTab.dart';
import 'package:expense_tracker/screens/dashboard/tabs/monthlyGroupTab.dart';
import 'package:expense_tracker/widgets/transactionWidgets.dart';
import 'package:expense_tracker/widgets/notesWidgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:expense_tracker/build_config.dart';
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/handlers/createTransactionPdf.dart';
import 'package:expense_tracker/handlers/http_request_handler.dart';
import 'package:expense_tracker/models/groupedSummaryModel.dart';
import 'package:expense_tracker/models/transactionModel.dart';
import 'package:expense_tracker/models/noteModel.dart';
import 'package:expense_tracker/screens/documentationVaultScreen.dart';
import 'package:expense_tracker/screens/historyScreen.dart';
import 'package:expense_tracker/screens/login.dart';
import 'package:expense_tracker/screens/webview.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

enum Tab { calendar, month, day }
enum AppBarMenuItems { pdfExport, documentationVault, history, notes, logout }
enum TransactionTab { expenses, income }

class _DashboardState extends State<Dashboard> {
  Tab selectedTab = Tab.day;
  TransactionTab selectedTransactionTab = TransactionTab.expenses;
  DateTime selectedDate = DateTime.now();
  String formattedDate = '';
  String formattedStartDate = '';
  String formattedEndDate = '';
  TransactionResponse transactions = TransactionResponse.fromJson({});
  GroupedSummary groupedTransactions = GroupedSummary.fromJson({});
  List<Note> notes = [];
  List<String> partyList = ['Option 1', 'Option 2', 'Option 3'];
  String totalBalance = '';
  String totalIncome = '';
  String totalExpense = '';
  String CF = '';
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
    0,
  );
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  bool isLoading = true;
  DayViewTab? dayViewTabToShow;
  DayViewTab currentDayViewTab = DayViewTab.transactions;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transactionGet();
  }

  reinitializeDates(){
    startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    endDate = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      0,
    );
    selectedDate = DateTime.now();
  }

  createPdf() async {
    BuildConfig.appIsActive = true;
    try{
      await requestPermission();
      await createTransactionPdf(transactions);
    }finally{
      BuildConfig.appIsActive = false;
    }
  }

  Future<void> onRefresh() async {
    await transactionGet();
    setState(() {}); // Rebuild the UI after refreshing data
  }

  notesGet() async {
    print("📝 [DASHBOARD] notesGet called - selectedTab: $selectedTab");
    if(selectedTab == Tab.day){
      String date = DateFormat('yyyy-MM-dd').format(selectedDate);
      print("📝 [DASHBOARD] notesGet - Fetching notes for date: $date");
      Map<String, dynamic> respJson =
      await HttpRequestHandler(context).getNotesByDate(date);
      if (respJson['status'] == 200) {
        setState(() {
          NotesResponse notesResponse = NotesResponse.fromJson(respJson);
          notes = notesResponse.notes;
          print("📝 [DASHBOARD] notesGet SUCCESS - Loaded ${notes.length} notes");
        });
      } else {
        print("📝 [DASHBOARD] notesGet FAILED - Status: ${respJson['status']}");
        setState(() {
          notes = [];
        });
      }
    } else {
      print("📝 [DASHBOARD] notesGet - Not in day view, clearing notes");
      setState(() {
        notes = [];
      });
    }
  }

  void switchToDayTab(DateTime date) {
    setState(() {
      selectedTab = Tab.day;
      selectedDate = date; // Update the variable
      currentDayViewTab = DayViewTab.transactions;
      dayViewTabToShow = null; // Reset to default (transactions)
      transactionGet();
    });
  }

  // Method to go to the next date
  void goToNextDate() {
    setState(() {
      if (selectedTab == Tab.day){
        selectedDate = selectedDate.add(const Duration(days: 1)); // Subtract 1 day
      }
      if (selectedTab == Tab.month){
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month + 1,
          selectedDate.day,
        );
      }
      transactionGet();
    });
  }

  // Method to go to the previous date
  void goToPreviousDate() {
    setState(() {
      if (selectedTab == Tab.day){
        selectedDate = selectedDate.subtract(const Duration(days: 1)); // Subtract 1 day
      }
      if (selectedTab == Tab.month){
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month - 1,
          selectedDate.day,
        );
      }
      transactionGet();
    });
  }

  Future<void> openDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        transactionGet();
      });
    }
  }

  Future<void> startDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        startDate = pickedDate;
        transactionGet();
      });
    }
  }

  Future<void> endDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != startDate) {
      setState(() {
        endDate = pickedDate;
        transactionGet();
      });
    }
  }

  Future<void> openMonthPicker() async {
    final DateTime? pickedMonth = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedMonth != null && pickedMonth != selectedDate) {
      setState(() {
        selectedDate = pickedMonth;
        transactionGet();
      });
    }
  }

  partyGet() async {
    List temp = await HttpRequestHandler(context).getParty();
    if(temp.isNotEmpty){
      setState(() {
        BuildConfig.partyList = temp.map((item) => item.toString()).toList();
      });
    }
  }

  Map<String, DateTime> getMonthDateRange(String yearMonth) {
    // Parse the input string
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    // Start of the month
    final startDate = DateTime(year, month, 1);

    // End of the month: the day before the 1st of next month
    final endDate = DateTime(year, month + 1, 1).subtract(Duration(days: 1));

    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }


  transactionGet() async {
    setState(() {
      isLoading = true;
    });
    await partyGet();
    setState(() {
      partyList = BuildConfig.partyList;
    });
    if(selectedTab == Tab.day){
      String dateOrMonth = DateFormat('yyyy-MM-dd').format(selectedDate);
      Map<String, dynamic> respJson =
      await HttpRequestHandler(context).transactionGet(dateOrMonth, _searchController.text);
      if (respJson['status'] == 200) {
        setState(() {
          transactions = TransactionResponse.fromJson(respJson);
          totalBalance = transactions.balance.toString();
          totalExpense = transactions.totalExpense.toString();
          totalIncome = transactions.totalIncome.toString();
          CF = transactions.carryForward.toString();
        });
      }
      await notesGet();
    }
    if(selectedTab == Tab.month){
      String dateOrMonth = DateFormat('yyyy-MM').format(selectedDate);
      Map<String, DateTime> dateRange = getMonthDateRange(dateOrMonth);
      String start = DateFormat('yyyy-MM-dd').format(dateRange['startDate']!);
      String end = DateFormat('yyyy-MM-dd').format(dateRange['endDate']!);
      Map<String, dynamic> respJson =
      // await HttpRequestHandler(context).monthlyTransactionGet(dateOrMonth, _searchController.text);
      await HttpRequestHandler(context).dateRangeTransactionGet(start, end, _searchController.text);
      if (respJson['status'] == 200) {
        setState(() {
          groupedTransactions = GroupedSummary.fromJson(respJson);
          totalBalance = groupedTransactions.balance.toString();
          totalExpense = groupedTransactions.totalExpense.toString();
          totalIncome = groupedTransactions.totalIncome.toString();
          CF = groupedTransactions.carryForward.toString();
          notes = [];
        });
      }
    }
    if(selectedTab == Tab.calendar){
      String start = DateFormat('yyyy-MM-dd').format(startDate);
      String end = DateFormat('yyyy-MM-dd').format(endDate);
      Map<String, dynamic> respJson =
      await HttpRequestHandler(context).dateRangeTransactionGet(start, end, _searchController.text);
      if (respJson['status'] == 200) {
        setState(() {
          groupedTransactions = GroupedSummary.fromJson(respJson);
          totalBalance = groupedTransactions.balance.toString();
          totalExpense = groupedTransactions.totalExpense.toString();
          totalIncome = groupedTransactions.totalIncome.toString();
          CF = groupedTransactions.carryForward.toString();
          notes = [];
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  dateFormatter(){
    if(selectedTab == Tab.day){
      return DateFormat('dd, MMM yy E').format(selectedDate);
    }else{
      return DateFormat('MMM yy').format(selectedDate);
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Exit',
          style: TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        contentPadding: const EdgeInsets.all(10),
        content: Text(
          '   Do you want to Exit?',
          style: TextStyle(color: Colors.indigo[900]),
        ),
        actions: [
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.lightGreen),
              ),
              onPressed: () {
                Navigator.pop(context);
                if(BuildConfig.isWeb()){
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const LoginPage()));
                }else{
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => WebViewPage()));
                }
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white),
              )),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(Colors.lightGreen),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    ));
  }

  logout(){
    if(BuildConfig.isWeb()){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginPage()));
    }else{
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => WebViewPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    formattedDate = dateFormatter();
    formattedStartDate = DateFormat('dd-MM-yyyy').format(startDate);
    formattedEndDate = DateFormat('dd-MM-yyyy').format(endDate);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Constants.primaryBlue,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(
                        'assets/logo.png',
                      )),
                  const SizedBox(width: 10),
                  Text(
                    "Hi, ${BuildConfig.username}",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSearching)
                    SizedBox(
                      width: 150,
                      child: Autocomplete<String>(
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
                          _searchController.text = selection;
                          transactionGet();
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController fieldController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          _searchController = fieldController;
                          return TextField(
                            controller: fieldController,
                            focusNode: focusNode,
                            autofocus: true,
                            style: const TextStyle(
                              color: Colors.white,   // Text color
                              fontSize: 14.0,         // Text size
                            ),
                            onChanged: (val){
                              transactionGet();
                            },
                            decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: const TextStyle(color: Colors.white70), // Hint text color
                                suffixIcon: IconButton(
                                  // padding: EdgeInsets.only(top: 12),
                                  icon: const Icon(Icons.cancel, size: 20,), // Cancel icon color
                                  onPressed: () {
                                    setState(() {
                                      _isSearching = false;
                                      _searchController.clear();
                                      fieldController.clear();
                                      transactionGet();
                                    });
                                  },
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white), // Border color when not focused
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blueAccent), // Border color when focused
                                ),
                                contentPadding: const EdgeInsets.only(top: 12, left: 2)
                            ),
                          );
                        },
                      ),

                    )
                  else
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                        child: const Icon(Icons.search, color: Colors.white)
                    ),
                  const SizedBox(width: 10),
                  PopupMenuButton<AppBarMenuItems>(
                    iconColor: Colors.white,
                    position: PopupMenuPosition.under,
                    onSelected: (AppBarMenuItems item) {
                      setState(() {
                        if(item == AppBarMenuItems.history){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const HistoryScreen()));
                        }
                        if(item == AppBarMenuItems.documentationVault){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => const DocumentationVault(folderId: '',)));
                        }
                        if(item == AppBarMenuItems.logout){
                          logout();
                        }
                        if(item == AppBarMenuItems.pdfExport){
                          createPdf();
                        }
                        if(item == AppBarMenuItems.notes){
                          setState(() {
                            selectedTab = Tab.day;
                            reinitializeDates();
                            dayViewTabToShow = DayViewTab.notes;
                          });
                          transactionGet();
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<AppBarMenuItems>>[
                      const PopupMenuItem<AppBarMenuItems>(
                        value: AppBarMenuItems.pdfExport,
                        child: Text('Export to PDF'),
                      ),
                      if (!BuildConfig.webPlatform)
                        const PopupMenuItem<AppBarMenuItems>(
                          value: AppBarMenuItems.documentationVault,
                          child: Text('Documentation Vault'),
                        ),
                      const PopupMenuItem<AppBarMenuItems>(
                        value: AppBarMenuItems.history,
                        child: Text('History'),
                      ),
                      const PopupMenuItem<AppBarMenuItems>(
                        value: AppBarMenuItems.logout,
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Constants.primaryBlue,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Total Balance",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "₹$totalBalance",
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    reinitializeDates();
                                    selectedTab = Tab.day;
                                    currentDayViewTab = DayViewTab.transactions;
                                    dayViewTabToShow = null;
                                    transactionGet();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    backgroundColor: selectedTab == Tab.day
                                        ? Constants.selectedTab
                                        : Constants.secondaryBlue),
                                child: Text(
                                  "D",
                                  style: TextStyle(
                                      color: selectedTab == Tab.day
                                          ? Constants.primaryBlue
                                          : Constants.blueWhite),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    reinitializeDates();
                                    selectedTab = Tab.month;
                                    currentDayViewTab = DayViewTab.transactions;
                                    dayViewTabToShow = null;
                                    transactionGet();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    backgroundColor: selectedTab == Tab.month
                                        ? Constants.selectedTab
                                        : Constants.secondaryBlue),
                                child: Text(
                                  "M",
                                  style: TextStyle(
                                      color: selectedTab == Tab.month
                                          ? Constants.primaryBlue
                                          : Constants.blueWhite),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    reinitializeDates();
                                    selectedTab = Tab.calendar;
                                    currentDayViewTab = DayViewTab.transactions;
                                    dayViewTabToShow = null;
                                    transactionGet();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    backgroundColor: selectedTab == Tab.calendar
                                        ? Constants.selectedTab
                                        : Constants.secondaryBlue),
                                child: Text(
                                  "C",
                                  style: TextStyle(
                                      color: selectedTab == Tab.calendar
                                          ? Constants.primaryBlue
                                          : Constants.blueWhite),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Date Selector
                      if (selectedTab != Tab.calendar)
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                goToPreviousDate();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                backgroundColor: Constants.secondaryBlue,
                                minimumSize: const Size(30, 30),
                                padding: EdgeInsets.zero,
                              ),
                              child: Icon(
                                Icons.arrow_left,
                                color: Constants.blueWhite,
                              )),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  30), // Adjust the radius as needed
                              child: GestureDetector(
                                onTap: (){
                                  if(selectedTab == Tab.day){
                                    openDatePicker();
                                  }else{
                                    openMonthPicker();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  color: Constants.secondaryBlue,
                                  child: Center(
                                    child: Text(
                                      formattedDate,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                              onPressed: () {
                                goToNextDate();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                ),
                                minimumSize: const Size(30, 30),
                                padding: EdgeInsets.zero,
                                backgroundColor: Constants.secondaryBlue,
                              ),
                              child: Icon(
                                Icons.arrow_right,
                                color: Constants.blueWhite,
                              )
                          ),
                        ],
                      ),
                      if (selectedTab == Tab.calendar)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                5), // Adjust the radius as needed
                            child: GestureDetector(
                              onTap: (){
                                startDatePicker();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                color: Constants.secondaryBlue,
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text(
                                        formattedStartDate,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(width: 5,),
                                      const Icon(Icons.calendar_today, color: Colors.white, size: 15,),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                5), // Adjust the radius as needed
                            child: GestureDetector(
                              onTap: (){
                                endDatePicker();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                color: Constants.secondaryBlue,
                                child: Center(
                                  child: Row(
                                    children: [
                                      Text(
                                        formattedEndDate,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      const SizedBox(width: 5,),
                                      const Icon(Icons.calendar_today, color: Colors.white, size: 15,),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],),
                      const SizedBox(height: 20),
                      // C/F Section
                      Container(
                        color: Colors.grey,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("C/F"),
                            Text(
                              "₹$CF",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                isLoading?const Center(
                    child: Padding(
                      padding: EdgeInsets.all(100.0),
                      child: CircularProgressIndicator(),
                    )
                ):
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Card(
                                color: Constants.income10,
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child:
                                  Icon(Icons.download, color: Colors.green),
                                ),
                              ),
                              Column(
                                children: [
                                  const Text("Total Income"),
                                  Text(
                                    "₹$totalIncome",
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Card(
                                color: Constants.expense10,
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(Icons.upload, color: Colors.red),
                                ),
                              ),
                              Column(
                                children: [
                                  const Text("Total Expenses"),
                                  Text(
                                    "₹$totalExpense",
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (selectedTab == Tab.day)
                      DayWiseTab(
                        transactions: transactions, 
                        notes: notes, 
                        onRefresh: onRefresh, 
                        selectedDate: selectedDate,
                        initialTab: dayViewTabToShow ?? currentDayViewTab,
                        onTabChanged: (DayViewTab tab) {
                          setState(() {
                            currentDayViewTab = tab;
                            dayViewTabToShow = null; // Reset after initial set
                          });
                        },
                      ),
                    if (selectedTab != Tab.day)
                      SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: MonthlyGroupTab(transactions: groupedTransactions, onChangeTab: switchToDayTab,)
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Visibility(
          visible: selectedTab == Tab.day,
          child: FloatingActionButton(
            onPressed: () {
              if (currentDayViewTab == DayViewTab.notes) {
                // Add Note
                NotesWidgets(onRefresh, context).addNoteSheet(null, selectedDate);
              } else {
                // Add Transaction
                TransactionWidgets(onRefresh, context).addTransactionSheet(null, selectedDate);
              }
            },
            backgroundColor: currentDayViewTab == DayViewTab.notes 
                ? Constants.primary 
                : Colors.green,
            child: Icon(
              currentDayViewTab == DayViewTab.notes 
                  ? Icons.note_add 
                  : Icons.add,
              color: Colors.white,
            ),
            tooltip: currentDayViewTab == DayViewTab.notes 
                ? "Add Note" 
                : "Add Transaction",
          ),
        ),
      ),
    );
  }
}