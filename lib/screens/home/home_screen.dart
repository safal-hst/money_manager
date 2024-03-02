import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager/screens/add_transaction/add_transaction_screen.dart';
import 'package:money_manager/screens/category/category_add_popup.dart';
import 'package:money_manager/screens/category/category_screen.dart';
import 'package:money_manager/screens/home/widgets/bottom_navigation.dart';

import '../transactions/transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pages = const [
    TransactionScreen(),
    CategoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        return await showDialog(
            context: (context),
            builder: (context) => AlertDialog(
                  title: const Text("Exit App ?"),
                  content: const Text('Do you want to exit from the app ?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => SystemNavigator.pop(),
                      child: const Text('Yes'),
                    ),
                  ],
                ));
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('MONEY MANAGER'),
          centerTitle: true,
          leading: const Icon(Icons.account_balance_wallet_rounded),
        ),
        bottomNavigationBar: const MoneyManagerBottomNavigation(),
        body: SafeArea(
            child: ValueListenableBuilder(
          valueListenable: HomeScreen.selectedIndexNotifier,
          builder: (BuildContext context, int updatedIndex, _) {
            return _pages[updatedIndex];
          },
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (HomeScreen.selectedIndexNotifier.value == 0) {
              print('Add Transaction');
              Navigator.of(context).pushNamed(AddTransactionScreen.routeName);
            } else {
              print('Add Category');
              showCategoryAddPopup(context, () {
                setState(() {});
              });
            }
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
