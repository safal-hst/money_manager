import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:money_manager/db/transactions/transaction_db.dart';
import 'package:money_manager/models/category/category_model.dart';
import '../../models/transaction/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: TransactionDB.instance.transactionListNotifier,
        builder: (BuildContext ctx, List<TransactionModel> newList, Widget? _) {
          if (newList.isEmpty) {
            return const Center(
              child: Text(
                'Please add some transactions to view !',
                style: TextStyle(fontSize: 15.0),
              ),
            );
          } else {
            return ListView.separated(
                padding: const EdgeInsets.all(10),
                itemBuilder: (ctx, index) {
                  final value = newList[index];
                  return Slidable(
                    key: Key(value.id!),
                    startActionPane:
                        ActionPane(motion: const ScrollMotion(), children: [
                      SlidableAction(
                        onPressed: (ctx) {
                          TransactionDB.instance.deleteTransaction(value.id!);
                        },
                        icon: Icons.delete,
                        label: 'Delete',
                      )
                    ]),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: value.type == CategoryType.income
                            ? Colors.green
                            : Colors.red,
                        radius: 50,
                        child: Text(
                          parseDate(value.date),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      title: Text('RS ${value.amount}'),
                      subtitle: Text(value.category.name),
                    ),
                  );
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(height: 10);
                },
                itemCount: newList.length);
          }
        });
  }

  String parseDate(DateTime date) {
    final date0 = DateFormat.MMMd().format(date);
    final splittedDate = date0.split(' ');
    return '${splittedDate.last}\n${splittedDate.first}';
  }
}
