import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_manager/models/category/category_model.dart';
import 'package:money_manager/models/transaction/transaction_model.dart';
import 'package:money_manager/screens/add_transaction/add_transaction_screen.dart';
import 'package:money_manager/screens/home/home_screen.dart';

import 'controller/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CategoryTypeAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Manager',
      home: const HomeScreen(),
      theme: CustomTheme.lightTheme(context),
      routes: {
        AddTransactionScreen.routeName: (ctx) => const AddTransactionScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
