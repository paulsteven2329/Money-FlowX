import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/income.dart';
import '../../domain/entities/financial_summary.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<Budget?> getBudgetById(String id);
  Future<List<Budget>> getBudgetsByCategory(String categoryId);
  Future<void> createBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
  Future<void> updateBudgetSpent(String categoryId, double amount);
}

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<Transaction?> getTransactionById(String id);
  Future<List<Transaction>> getTransactionsByCategory(String categoryId);
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<void> createTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<double> getTotalExpensesByCategory(
    String categoryId,
    DateTime start,
    DateTime end,
  );
}

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> getDefaultCategories();
}

abstract class IncomeRepository {
  Future<List<Income>> getAllIncomes();
  Future<Income?> getIncomeById(String id);
  Future<void> createIncome(Income income);
  Future<void> updateIncome(Income income);
  Future<void> deleteIncome(String id);
  Future<double> getTotalIncome(DateTime start, DateTime end);
}

abstract class FinancialSummaryRepository {
  Future<FinancialSummary> getFinancialSummary(DateTime start, DateTime end);
  Future<List<AIInsight>> getAIInsights();
  Future<void> markInsightAsRead(String id);
}
