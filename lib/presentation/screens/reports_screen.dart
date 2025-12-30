import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_state.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_state.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_state.dart';
import '../../core/widgets/charts.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/utils/app_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Spending', icon: Icon(Icons.pie_chart)),
            Tab(text: 'Trends', icon: Icon(Icons.trending_up)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectMonth(),
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, transactionState) {
          if (transactionState is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transactionState is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading reports',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transactionState.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (transactionState is! TransactionLoaded) {
            return const Center(child: Text('Unable to load reports'));
          }

          if (transactionState.transactions.isEmpty) {
            return _buildEmptyState();
          }

          return BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, categoryState) {
              if (categoryState is! CategoryLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              return BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, budgetState) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(
                        transactionState.transactions,
                        categoryState.categories,
                        budgetState,
                      ),
                      _buildSpendingTab(
                        transactionState.transactions,
                        categoryState.categories,
                      ),
                      _buildTrendsTab(
                        transactionState.transactions,
                        categoryState.categories,
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No data for reports',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding transactions to see your financial reports',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    List<dynamic> transactions,
    List<dynamic> categories,
    BudgetState budgetState,
  ) {
    final monthlyTransactions = _getMonthlyTransactions(transactions);
    final monthlyIncome = monthlyTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    final monthlyExpenses = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = monthlyIncome - monthlyExpenses;

    double totalBudget = 0.0;
    if (budgetState is BudgetLoaded) {
      totalBudget = budgetState.budgets.fold(
        0.0,
        (sum, budget) => sum + budget.amount,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: BudgetColors.primary),
              const SizedBox(width: 8),
              Text(
                AppUtils.formatMonthYear(_selectedMonth),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Income',
                  value: AppUtils.formatCurrency(monthlyIncome),
                  icon: Icons.trending_up,
                  color: BudgetColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Expenses',
                  value: AppUtils.formatCurrency(monthlyExpenses),
                  icon: Icons.trending_down,
                  color: BudgetColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Balance',
                  value: AppUtils.formatCurrency(balance),
                  icon: balance >= 0 ? Icons.account_balance : Icons.warning,
                  color: balance >= 0
                      ? BudgetColors.success
                      : BudgetColors.danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'Budget',
                  value: AppUtils.formatCurrency(totalBudget),
                  subtitle: totalBudget > 0
                      ? 'vs ${AppUtils.formatCurrency(monthlyExpenses)} spent'
                      : 'Not set',
                  icon: Icons.account_balance_wallet,
                  color: BudgetColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Top Expense Categories',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildTopExpenseCategories(monthlyTransactions, categories),
          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildRecentActivity(
            monthlyTransactions.take(5).toList(),
            categories,
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTab(
    List<dynamic> transactions,
    List<dynamic> categories,
  ) {
    final monthlyTransactions = _getMonthlyTransactions(transactions);
    final expenses = monthlyTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No expenses this month',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: BudgetColors.primary),
              const SizedBox(width: 8),
              Text(
                'Spending Breakdown',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 250,
            child: SpendingPieChart(
              transactions: expenses,
              categories: categories,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Category Details',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(expenses, categories),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(List<dynamic> transactions, List<dynamic> categories) {
    final last6Months = _getLast6MonthsData(transactions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: BudgetColors.primary),
              const SizedBox(width: 8),
              Text(
                'Spending Trends',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 250,
            child: SpendingTrendsChart(monthlyData: last6Months),
          ),
          const SizedBox(height: 24),
          Text(
            'Monthly Comparison',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _buildMonthlyComparison(last6Months),
        ],
      ),
    );
  }

  Widget _buildTopExpenseCategories(
    List<dynamic> transactions,
    List<dynamic> categories,
  ) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();
    final categoryExpenses = <String, double>{};

    for (final transaction in expenses) {
      categoryExpenses[transaction.categoryId] =
          (categoryExpenses[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedCategories.take(5).map((entry) {
        final category = categories.firstWhere((c) => c.id == entry.key);
        final percentage = categoryExpenses.values.fold(
          0.0,
          (sum, amount) => sum + amount,
        );
        final categoryPercentage = percentage > 0
            ? (entry.value / percentage * 100)
            : 0.0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Color(AppUtils.hexToColor(category.color)),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(category.name)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppUtils.formatCurrency(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${categoryPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(
    List<dynamic> transactions,
    List<dynamic> categories,
  ) {
    return Column(
      children: transactions.map((transaction) {
        final category = categories.firstWhere(
          (c) => c.id == transaction.categoryId,
        );
        final isIncome = transaction.type == TransactionType.income;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(
                AppUtils.hexToColor(category.color),
              ).withOpacity(0.2),
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color: Color(AppUtils.hexToColor(category.color)),
              ),
            ),
            title: Text(transaction.description),
            subtitle: Text(
              '${category.name} • ${AppUtils.formatDate(transaction.date)}',
            ),
            trailing: Text(
              '${isIncome ? '+' : '-'}${AppUtils.formatCurrency(transaction.amount)}',
              style: TextStyle(
                color: isIncome ? BudgetColors.success : BudgetColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryBreakdown(
    List<dynamic> expenses,
    List<dynamic> categories,
  ) {
    final categoryExpenses = <String, double>{};

    for (final transaction in expenses) {
      categoryExpenses[transaction.categoryId] =
          (categoryExpenses[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final totalExpenses = categoryExpenses.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );

    return Column(
      children: categoryExpenses.entries.map((entry) {
        final category = categories.firstWhere((c) => c.id == entry.key);
        final percentage = totalExpenses > 0
            ? (entry.value / totalExpenses * 100)
            : 0.0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Color(AppUtils.hexToColor(category.color)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(category.name)),
                    Text(
                      AppUtils.formatCurrency(entry.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(AppUtils.hexToColor(category.color)),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyComparison(List<Map<String, dynamic>> monthlyData) {
    return Column(
      children: monthlyData.map((data) {
        final income = data['income'] as double;
        final expenses = data['expenses'] as double;
        final balance = income - expenses;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['month'] as String,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Income',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            AppUtils.formatCurrency(income),
                            style: const TextStyle(
                              color: BudgetColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expenses',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            AppUtils.formatCurrency(expenses),
                            style: const TextStyle(
                              color: BudgetColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            AppUtils.formatCurrency(balance),
                            style: TextStyle(
                              color: balance >= 0
                                  ? BudgetColors.success
                                  : BudgetColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<dynamic> _getMonthlyTransactions(List<dynamic> transactions) {
    return transactions
        .where(
          (t) =>
              t.date.year == _selectedMonth.year &&
              t.date.month == _selectedMonth.month,
        )
        .toList();
  }

  List<Map<String, dynamic>> _getLast6MonthsData(List<dynamic> transactions) {
    final monthlyData = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(_selectedMonth.year, _selectedMonth.month - i, 1);
      final monthTransactions = transactions
          .where(
            (t) => t.date.year == month.year && t.date.month == month.month,
          )
          .toList();

      final income = monthTransactions
          .where((t) => t.type == TransactionType.income)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expenses = monthTransactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (sum, t) => sum + t.amount);

      monthlyData.add({
        'month': AppUtils.formatMonthYear(month),
        'income': income,
        'expenses': expenses,
      });
    }

    return monthlyData;
  }

  void _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }
}
