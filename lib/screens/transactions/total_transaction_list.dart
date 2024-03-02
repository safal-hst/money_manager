import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/db/transactions/transaction_db.dart';
import 'package:money_manager/models/transaction/transaction_model.dart';
import '../../models/category/category_model.dart';

class TotalTransactionList extends StatefulWidget {
  const TotalTransactionList({super.key});

  @override
  _TotalTransactionListState createState() => _TotalTransactionListState();
}

class _TotalTransactionListState extends State<TotalTransactionList> {
  late DateTime _startDate = DateTime.now();
  late DateTime _endDate = DateTime.now();

  @override
  void initState() {
    _loadSelectedDates();
    super.initState();
  }

  Future<void> _loadSelectedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStartDate = prefs.getString('fromDate');
    final savedEndDate = prefs.getString('toDate');

    setState(() {
      _startDate = savedStartDate != null
          ? DateTime.parse(savedStartDate)
          : DateTime.now();
      _endDate =
          savedEndDate != null ? DateTime.parse(savedEndDate) : DateTime.now();
    });
  }

  Future<void> _saveSelectedDates() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fromDate', _startDate.toIso8601String());
    prefs.setString('toDate', _endDate.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            'Select Date',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () async {
                final selectedStartDate = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: _endDate,
                );
                if (selectedStartDate != null) {
                  setState(() {
                    _startDate = selectedStartDate;
                  });
                  _saveSelectedDates();
                }
              },
              child: Text(
                'From Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}',
              ),
            ),
            const Icon(Icons.arrow_right),
            TextButton(
              onPressed: () async {
                final selectedEndDate = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now(),
                );
                if (selectedEndDate != null) {
                  setState(() {
                    _endDate = selectedEndDate;
                  });
                  _saveSelectedDates();
                }
              },
              child: Text(
                'To Date: ${DateFormat('yyyy-MM-dd').format(_endDate)}',
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height / 5),
        ValueListenableBuilder(
          valueListenable: TransactionDB.instance.transactionListNotifier,
          builder:
              (BuildContext ctx, List<TransactionModel> newList, Widget? _) {
            if (newList.isEmpty) {
              return Column(
                children: [
                  Text('Your transactions are empty !'),
                  SizedBox(height: 15),
                  CircularProgressIndicator(),
                ],
              );
            } else {
              final filteredTransactions = newList.where((transaction) {
                return transaction.date.isAfter(
                        _startDate.subtract(const Duration(days: 1))) &&
                    transaction.date
                        .isBefore(_endDate.add(const Duration(days: 1)));
              }).toList();

              final totalIncome = filteredTransactions
                  .where(
                      (transaction) => transaction.type == CategoryType.income)
                  .fold(0.0, (prev, curr) => prev + curr.amount);
              final totalExpense = filteredTransactions
                  .where(
                      (transaction) => transaction.type == CategoryType.expense)
                  .fold(0.0, (prev, curr) => prev + curr.amount);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTotalContainer(
                    label: 'Total Expense',
                    value: totalExpense,
                    color: Colors.red,
                  ),
                  _buildTotalContainer(
                    label: 'Total Income',
                    value: totalIncome,
                    color: Colors.green,
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTotalContainer({
    required String label,
    required double value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width / 2.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 20),
          Text('Rs ${value.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
