import 'package:flutter/material.dart';
import 'package:money_manager/db/category/category_db.dart';
import 'package:money_manager/screens/transactions/total_transaction_list.dart';
import 'package:money_manager/screens/transactions/transaction_list.dart';
import '../../db/transactions/transaction_db.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    TransactionDB.instance.refresh();
    CategoryDB.instance.refreshUI();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
            controller: _tabController,
            tabs: const [Tab(text: 'TRANSACTIONS'), Tab(text: 'TOTAL')]),
        Expanded(
          child: TabBarView(controller: _tabController, children: const [
            TransactionList(),
            TotalTransactionList(),
          ]),
        )
      ],
    );
  }
}
