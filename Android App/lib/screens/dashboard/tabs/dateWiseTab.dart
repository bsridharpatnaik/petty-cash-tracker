import 'package:flutter/material.dart';
import 'package:expense_tracker/models/transactionModel.dart';
import 'package:expense_tracker/models/noteModel.dart';
import 'package:expense_tracker/widgets/transactionWidgets.dart';
import 'package:expense_tracker/widgets/notesWidgets.dart';
import 'package:expense_tracker/constants.dart';
import 'package:expense_tracker/screens/dashboard/tabs/notesTab.dart';

class DayWiseTab extends StatefulWidget {
  final TransactionResponse transactions;
  final List<Note> notes;
  final Future<void> Function() onRefresh;
  final DateTime selectedDate;
  final DayViewTab? initialTab;
  final Function(DayViewTab)? onTabChanged;
  const DayWiseTab({
    required this.transactions, 
    required this.notes, 
    required this.onRefresh, 
    required this.selectedDate, 
    this.initialTab,
    this.onTabChanged,
    super.key
  });

  @override
  State<DayWiseTab> createState() => _DayWiseTabState();
}
enum DayViewTab { transactions, notes }
class _DayWiseTabState extends State<DayWiseTab> {
  late DayViewTab selectedDayViewTab;
  
  @override
  void initState() {
    super.initState();
    selectedDayViewTab = widget.initialTab ?? DayViewTab.transactions;
    // Notify parent of initial tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTabChanged?.call(selectedDayViewTab);
    });
  }
  
  @override
  void didUpdateWidget(DayWiseTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != null && widget.initialTab != oldWidget.initialTab) {
      setState(() {
        selectedDayViewTab = widget.initialTab!;
      });
      // Defer callback to avoid calling setState during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTabChanged?.call(selectedDayViewTab);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    TransactionResponse transactions = widget.transactions;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Modern Tab Bar - Always Visible at Top
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Constants.gray20,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
                  Expanded(
                    child: _buildTabButton(
                      label: "Transactions",
                      icon: Icons.account_balance_wallet,
                      isSelected: selectedDayViewTab == DayViewTab.transactions,
                      count: transactions.allTransactions.length,
                      onTap: () {
                        setState(() {
                          selectedDayViewTab = DayViewTab.transactions;
                        });
                        widget.onTabChanged?.call(DayViewTab.transactions);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      label: "Notes",
                      icon: Icons.note,
                      isSelected: selectedDayViewTab == DayViewTab.notes,
                      count: widget.notes.length,
                      onTap: () {
                        setState(() {
                          selectedDayViewTab = DayViewTab.notes;
                        });
                        widget.onTabChanged?.call(DayViewTab.notes);
                      },
                    ),
                  ),
            ],
          ),
        ),
        // Tab Content
          Padding(
            padding: const EdgeInsets.all(8.0),
          child: selectedDayViewTab == DayViewTab.transactions
              ? _buildTransactionsTab(transactions)
              : _buildNotesTab(),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Constants.selectedTab : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
              children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Constants.primaryBlue : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Constants.primaryBlue : Colors.grey[700],
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected ? Constants.primaryBlue : Colors.grey[400],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(TransactionResponse transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          "Transaction History",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
                Column(
                  children: [
                    ...List.generate(
                        transactions.allTransactions.length,
                            (index) {
                          return GestureDetector(
                  onTap: () => TransactionWidgets(widget.onRefresh, context)
                      .editTransactionSheet(transactions.allTransactions[index]),
                  child: TransactionWidgets(widget.onRefresh, context)
                      .transactionHistoryCard(transactions.allTransactions[index]),
                );
              },
            ),
            if (transactions.allTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No Transactions",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
            ),
          ),
        ],
      ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildNotesTab() {
    return NotesTab(
      notes: widget.notes,
      onRefresh: widget.onRefresh,
      selectedDate: widget.selectedDate,
    );
  }
}