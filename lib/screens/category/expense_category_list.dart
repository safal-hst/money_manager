import 'package:flutter/material.dart';
import 'package:money_manager/db/category/category_db.dart';

import '../../models/category/category_model.dart';

class ExpenseCategorylist extends StatelessWidget {
  const ExpenseCategorylist({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: CategoryDB().expenseCategoryListListener,
        builder: (BuildContext ctx, List<CategoryModel> newlist, Widget? _) {
          if (newlist.isEmpty) {
            return const Center(
              child: Text(
                'No expense categories added !',
                style: TextStyle(fontSize: 15.0),
              ),
            );
          } else {
            return ListView.separated(
              padding: const EdgeInsets.all(10),
              itemBuilder: (ctx, index) {
                final category = newlist[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                      onPressed: () {
                        CategoryDB.instance.deleteCategory(category.id);
                      },
                      icon: const Icon(Icons.delete)),
                );
              },
              separatorBuilder: (ctx, index) {
                return const SizedBox(height: 10);
              },
              itemCount: newlist.length,
            );
          }
        });
  }
}
