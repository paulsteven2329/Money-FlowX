import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/income_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final LocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Budget>> getAllBudgets() async {
    final budgetModels = await localDataSource.getAllBudgets();
    return budgetModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final budgetModel = await localDataSource.getBudgetById(id);
    return budgetModel?.toEntity();
  }

  @override
  Future<List<Budget>> getBudgetsByCategory(String categoryId) async {
    final budgets = await getAllBudgets();
    return budgets.where((budget) => budget.categoryId == categoryId).toList();
  }

  @override
  Future<void> createBudget(Budget budget) async {
    final budgetModel = BudgetModel.fromEntity(budget);
    await localDataSource.saveBudget(budgetModel);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final budgetModel = BudgetModel.fromEntity(budget);
    await localDataSource.saveBudget(budgetModel);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await localDataSource.deleteBudget(id);
  }

  @override
  Future<void> updateBudgetSpent(String categoryId, double amount) async {
    final budgets = await getBudgetsByCategory(categoryId);
    for (final budget in budgets) {
      final updatedBudget = budget.copyWith(spent: budget.spent + amount);
      await updateBudget(updatedBudget);
    }
  }
}

class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final transactionModels = await localDataSource.getAllTransactions();
    return transactionModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final transactionModel = await localDataSource.getTransactionById(id);
    return transactionModel?.toEntity();
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    final transactions = await getAllTransactions();
    return transactions
        .where((transaction) => transaction.categoryId == categoryId)
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await getAllTransactions();
    return transactions.where((transaction) {
      final transactionDate = transaction.date;
      return transactionDate.isAfter(start.subtract(const Duration(days: 1))) &&
          transactionDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<void> createTransaction(Transaction transaction) async {
    final transactionModel = TransactionModel.fromEntity(transaction);
    await localDataSource.saveTransaction(transactionModel);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final transactionModel = TransactionModel.fromEntity(transaction);
    await localDataSource.saveTransaction(transactionModel);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await localDataSource.deleteTransaction(id);
  }

  @override
  Future<double> getTotalExpensesByCategory(
    String categoryId,
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await getTransactionsByDateRange(start, end);
    final categoryTransactions = transactions
        .where(
          (t) =>
              t.categoryId == categoryId && t.type == TransactionType.expense,
        )
        .toList();

    return categoryTransactions.fold<double>(
      0.0,
      (sum, transaction) => sum + transaction.amount,
    );
  }
}

class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Category>> getAllCategories() async {
    final categoryModels = await localDataSource.getAllCategories();
    return categoryModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final categoryModel = await localDataSource.getCategoryById(id);
    return categoryModel?.toEntity();
  }

  @override
  Future<void> createCategory(Category category) async {
    final categoryModel = CategoryModel.fromEntity(category);
    await localDataSource.saveCategory(categoryModel);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final categoryModel = CategoryModel.fromEntity(category);
    await localDataSource.saveCategory(categoryModel);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localDataSource.deleteCategory(id);
  }

  @override
  Future<List<Category>> getDefaultCategories() async {
    await localDataSource.initializeDefaultCategories();
    return getAllCategories();
  }
}

class IncomeRepositoryImpl implements IncomeRepository {
  final LocalDataSource localDataSource;

  IncomeRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Income>> getAllIncomes() async {
    final incomeModels = await localDataSource.getAllIncomes();
    return incomeModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Income?> getIncomeById(String id) async {
    final incomeModel = await localDataSource.getIncomeById(id);
    return incomeModel?.toEntity();
  }

  @override
  Future<void> createIncome(Income income) async {
    final incomeModel = IncomeModel.fromEntity(income);
    await localDataSource.saveIncome(incomeModel);
  }

  @override
  Future<void> updateIncome(Income income) async {
    final incomeModel = IncomeModel.fromEntity(income);
    await localDataSource.saveIncome(incomeModel);
  }

  @override
  Future<void> deleteIncome(String id) async {
    await localDataSource.deleteIncome(id);
  }

  @override
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    final incomes = await getAllIncomes();
    final filteredIncomes = incomes.where((income) {
      final incomeDate = income.date;
      return incomeDate.isAfter(start.subtract(const Duration(days: 1))) &&
          incomeDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    return filteredIncomes.fold<double>(
      0.0,
      (sum, income) => sum + income.amount,
    );
  }
}

class FinancialSummaryRepositoryImpl implements FinancialSummaryRepository {
  final TransactionRepository transactionRepository;
  final BudgetRepository budgetRepository;
  final IncomeRepository incomeRepository;
  final CategoryRepository categoryRepository;

  FinancialSummaryRepositoryImpl({
    required this.transactionRepository,
    required this.budgetRepository,
    required this.incomeRepository,
    required this.categoryRepository,
  });

  @override
  Future<FinancialSummary> getFinancialSummary(
    DateTime start,
    DateTime end,
  ) async {
    final transactions = await transactionRepository.getTransactionsByDateRange(
      start,
      end,
    );
    final budgets = await budgetRepository.getAllBudgets();
    final totalIncome = await incomeRepository.getTotalIncome(start, end);

    final expenses = transactions.where(
      (t) => t.type == TransactionType.expense,
    );
    final totalExpenses = expenses.fold<double>(
      0.0,
      (sum, t) => sum + t.amount,
    );

    final categoryExpenses = <String, double>{};
    final categoryBudgets = <String, double>{};

    for (final transaction in expenses) {
      categoryExpenses[transaction.categoryId] =
          (categoryExpenses[transaction.categoryId] ?? 0) + transaction.amount;
    }

    for (final budget in budgets) {
      categoryBudgets[budget.categoryId] = budget.amount;
    }

    final totalBudget = budgets.fold<double>(0.0, (sum, b) => sum + b.amount);
    final totalSavings = totalIncome - totalExpenses;

    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5).map((e) => e.key).toList();

    final daysDifference = end.difference(start).inDays + 1;
    final averageDailySpending = daysDifference > 0
        ? totalExpenses / daysDifference.toDouble()
        : 0.0;

    return FinancialSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalBudget: totalBudget,
      totalSavings: totalSavings,
      categoryExpenses: categoryExpenses,
      categoryBudgets: categoryBudgets,
      startDate: start,
      endDate: end,
      topCategories: topCategories,
      averageDailySpending: averageDailySpending,
    );
  }

  @override
  Future<List<AIInsight>> getAIInsights() async {
    // Placeholder for AI insights implementation
    return [];
  }

  @override
  Future<void> markInsightAsRead(String id) async {
    // Placeholder for marking insights as read
  }
}
