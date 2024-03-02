import 'package:flutter/material.dart';
import 'package:money_manager/controller/validator.dart';
import 'package:money_manager/db/category/category_db.dart';
import 'package:money_manager/db/transactions/transaction_db.dart';
import 'package:money_manager/models/category/category_model.dart';
import 'package:money_manager/models/transaction/transaction_model.dart';
import 'package:money_manager/screens/category/category_add_popup.dart';

class AddTransactionScreen extends StatefulWidget {
  static const routeName = 'add-transaction';
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  DateTime? _selectedDate;
  CategoryType? _selectCategoryType;
  CategoryModel? _selectedCategoryModel;
  String? _categoryID;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _purposeTextEditingController = TextEditingController();
  final _amountTextEditingController = TextEditingController();

  @override
  void initState() {
    _selectCategoryType = CategoryType.income;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  validator: Validator.emptyValidate,
                  controller: _purposeTextEditingController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      hintText: 'Purpose', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  validator: Validator.emptyValidate,
                  controller: _amountTextEditingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Amount', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 15),
                TextButton.icon(
                  onPressed: () async {
                    final selectedDateTemp = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDateTemp == null) {
                      return;
                    } else {
                      print(selectedDateTemp.toString());
                      setState(() {
                        _selectedDate = selectedDateTemp;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? 'Select date'
                      : _selectedDate!.toString()),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: CategoryType.income,
                          groupValue: _selectCategoryType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectCategoryType = CategoryType.income;
                              _categoryID = null;
                            });
                          },
                        ),
                        const Text('Income')
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: CategoryType.expense,
                          groupValue: _selectCategoryType,
                          onChanged: (newValue) {
                            setState(() {
                              _selectCategoryType = CategoryType.expense;
                              _categoryID = null;
                            });
                          },
                        ),
                        const Text('Expense')
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField(
                        validator: Validator.validateDropdownValue,
                        hint: const Text('Select category'),
                        value: _categoryID,
                        items: [
                          const DropdownMenuItem(
                            value: 'add_category',
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text('Add Category'), Icon(Icons.add)],
                            ),
                          ),
                          ...(_selectCategoryType == CategoryType.income
                                  ? CategoryDB().incomeCategoryListListener
                                  : CategoryDB().expenseCategoryListListener)
                              .value
                              .map((e) {
                            return DropdownMenuItem(
                              value: e.id,
                              onTap: () {
                                _selectedCategoryModel = e;
                              },
                              child: Text(e.name),
                            );
                          }),
                        ],
                        onChanged: (selectedvalue) {
                          if (selectedvalue == 'add_category') {
                            showCategoryAddPopup(context, () {
                              // Refresh the dropdown after a new category is added
                              setState(() {});
                            });
                          } else {
                            setState(() {
                              _categoryID = selectedvalue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedDate != null) {
              addTransaction();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a date.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text(
            'Submit',
            style: TextStyle(letterSpacing: 2, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> addTransaction() async {
    final purposeText = _purposeTextEditingController.text;
    final amountText = _amountTextEditingController.text;
    if (purposeText.isEmpty) {
      return;
    }
    if (amountText.isEmpty) {
      return;
    }
    if (_categoryID == null) {
      return;
    }
    if (_selectedDate == null) {
      return;
    }
    if (_selectedCategoryModel == null) {
      return;
    }
    final parsedAmount = double.tryParse(amountText);
    if (parsedAmount == null) {
      return;
    }

    final model = TransactionModel(
      purpose: purposeText,
      amount: parsedAmount,
      date: _selectedDate!,
      type: _selectCategoryType!,
      category: _selectedCategoryModel!,
    );
    await TransactionDB.instance.addTransaction(model);
    Navigator.of(context).pop();
    TransactionDB.instance.refresh();
  }
}
