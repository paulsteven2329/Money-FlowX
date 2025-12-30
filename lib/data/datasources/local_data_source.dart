import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/income_model.dart';
import '../../domain/entities/category.dart';

abstract class LocalDataSource {
  Future<List<BudgetModel>> getAllBudgets();
  Future<BudgetModel?> getBudgetById(String id);
  Future<void> saveBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);

  Future<List<TransactionModel>> getAllTransactions();
  Future<TransactionModel?> getTransactionById(String id);
  Future<void> saveTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);

  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategory(String id);

  Future<List<IncomeModel>> getAllIncomes();
  Future<IncomeModel?> getIncomeById(String id);
  Future<void> saveIncome(IncomeModel income);
  Future<void> deleteIncome(String id);

  Future<void> initializeDefaultCategories();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String _budgetsKey = 'budgets';
  static const String _transactionsKey = 'transactions';
  static const String _categoriesKey = 'categories';
  static const String _incomesKey = 'incomes';
  static const String _initializedKey = 'initialized';

  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  // Budget methods
  @override
  Future<List<BudgetModel>> getAllBudgets() async {
    final budgetsJson = sharedPreferences.getStringList(_budgetsKey) ?? [];
    return budgetsJson
        .map((json) => BudgetModel.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<BudgetModel?> getBudgetById(String id) async {
    final budgets = await getAllBudgets();
    try {
      return budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    final budgets = await getAllBudgets();
    final index = budgets.indexWhere((b) => b.id == budget.id);

    if (index != -1) {
      budgets[index] = budget;
    } else {
      budgets.add(budget);
    }

    final budgetsJson = budgets.map((b) => jsonEncode(b.toJson())).toList();
    await sharedPreferences.setStringList(_budgetsKey, budgetsJson);
  }

  @override
  Future<void> deleteBudget(String id) async {
    final budgets = await getAllBudgets();
    budgets.removeWhere((budget) => budget.id == id);
    final budgetsJson = budgets.map((b) => jsonEncode(b.toJson())).toList();
    await sharedPreferences.setStringList(_budgetsKey, budgetsJson);
  }

  // Transaction methods
  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    final transactionsJson =
        sharedPreferences.getStringList(_transactionsKey) ?? [];
    return transactionsJson
        .map((json) => TransactionModel.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    final transactions = await getAllTransactions();
    try {
      return transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    final transactions = await getAllTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);

    if (index != -1) {
      transactions[index] = transaction;
    } else {
      transactions.add(transaction);
    }

    final transactionsJson = transactions
        .map((t) => jsonEncode(t.toJson()))
        .toList();
    await sharedPreferences.setStringList(_transactionsKey, transactionsJson);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final transactions = await getAllTransactions();
    transactions.removeWhere((transaction) => transaction.id == id);
    final transactionsJson = transactions
        .map((t) => jsonEncode(t.toJson()))
        .toList();
    await sharedPreferences.setStringList(_transactionsKey, transactionsJson);
  }

  // Category methods
  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final categoriesJson =
        sharedPreferences.getStringList(_categoriesKey) ?? [];
    return categoriesJson
        .map((json) => CategoryModel.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final categories = await getAllCategories();
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    final categories = await getAllCategories();
    final index = categories.indexWhere((c) => c.id == category.id);

    if (index != -1) {
      categories[index] = category;
    } else {
      categories.add(category);
    }

    final categoriesJson = categories
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await sharedPreferences.setStringList(_categoriesKey, categoriesJson);
  }

  @override
  Future<void> deleteCategory(String id) async {
    final categories = await getAllCategories();
    categories.removeWhere((category) => category.id == id);
    final categoriesJson = categories
        .map((c) => jsonEncode(c.toJson()))
        .toList();
    await sharedPreferences.setStringList(_categoriesKey, categoriesJson);
  }

  // Income methods
  @override
  Future<List<IncomeModel>> getAllIncomes() async {
    final incomesJson = sharedPreferences.getStringList(_incomesKey) ?? [];
    return incomesJson
        .map((json) => IncomeModel.fromJson(jsonDecode(json)))
        .toList();
  }

  @override
  Future<IncomeModel?> getIncomeById(String id) async {
    final incomes = await getAllIncomes();
    try {
      return incomes.firstWhere((income) => income.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveIncome(IncomeModel income) async {
    final incomes = await getAllIncomes();
    final index = incomes.indexWhere((i) => i.id == income.id);

    if (index != -1) {
      incomes[index] = income;
    } else {
      incomes.add(income);
    }

    final incomesJson = incomes.map((i) => jsonEncode(i.toJson())).toList();
    await sharedPreferences.setStringList(_incomesKey, incomesJson);
  }

  @override
  Future<void> deleteIncome(String id) async {
    final incomes = await getAllIncomes();
    incomes.removeWhere((income) => income.id == id);
    final incomesJson = incomes.map((i) => jsonEncode(i.toJson())).toList();
    await sharedPreferences.setStringList(_incomesKey, incomesJson);
  }

  @override
  Future<void> initializeDefaultCategories() async {
    final isInitialized = sharedPreferences.getBool(_initializedKey) ?? false;
    if (isInitialized) return;

    final defaultCategories = [
      CategoryModel(
        id: 'food',
        name: 'Food & Dining',
        icon: CategoryType.food.defaultIcon,
        color: CategoryType.food.defaultColor,
        type: CategoryType.food,
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transportation',
        icon: CategoryType.transport.defaultIcon,
        color: CategoryType.transport.defaultColor,
        type: CategoryType.transport,
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        icon: CategoryType.entertainment.defaultIcon,
        color: CategoryType.entertainment.defaultColor,
        type: CategoryType.entertainment,
      ),
      CategoryModel(
        id: 'shopping',
        name: 'Shopping',
        icon: CategoryType.shopping.defaultIcon,
        color: CategoryType.shopping.defaultColor,
        type: CategoryType.shopping,
      ),
      CategoryModel(
        id: 'bills',
        name: 'Bills & Utilities',
        icon: CategoryType.bills.defaultIcon,
        color: CategoryType.bills.defaultColor,
        type: CategoryType.bills,
      ),
      CategoryModel(
        id: 'healthcare',
        name: 'Healthcare',
        icon: CategoryType.healthcare.defaultIcon,
        color: CategoryType.healthcare.defaultColor,
        type: CategoryType.healthcare,
      ),
    ];

    for (final category in defaultCategories) {
      await saveCategory(category);
    }

    await sharedPreferences.setBool(_initializedKey, true);
  }
}
