import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_state.dart';
import '../bloc/budget/budget_event.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_state.dart';
import '../bloc/transaction/transaction_event.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_state.dart';
import '../bloc/category/category_event.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/budget_progress_card.dart';
import '../../core/widgets/transaction_tile.dart';
import '../../core/widgets/charts.dart';
import '../../core/utils/app_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';
import 'add_transaction_screen.dart';
import 'create_budget_screen.dart';
import 'edit_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyFlowX Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<BudgetBloc>().add(LoadBudgets());
          context.read<TransactionBloc>().add(LoadTransactions());
          context.read<CategoryBloc>().add(LoadCategories());
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreetingSection(context),
                    const SizedBox(height: 24),
                    _buildStatsSection(context),
                    const SizedBox(height: 24),
                    _buildBudgetOverview(context),
                    const SizedBox(height: 24),
                    _buildExpenseChart(context),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s your financial overview',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          final now = DateTime.now();
          final startOfMonth = AppUtils.startOfMonth(now);
          final endOfMonth = AppUtils.endOfMonth(now);

          final monthlyTransactions = state.transactions.where((t) {
            return t.date.isAfter(
                  startOfMonth.subtract(const Duration(days: 1)),
                ) &&
                t.date.isBefore(endOfMonth.add(const Duration(days: 1)));
          }).toList();

          final monthlyExpenses = monthlyTransactions
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, t) => sum + t.amount);

          final monthlyIncome = monthlyTransactions
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, t) => sum + t.amount);

          return Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'This Month Income',
                  value: AppUtils.formatCurrency(monthlyIncome),
                  icon: Icons.trending_up,
                  color: BudgetColors.success,
                  backgroundColor: BudgetColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'This Month Expenses',
                  value: AppUtils.formatCurrency(monthlyExpenses),
                  icon: Icons.trending_down,
                  color: BudgetColors.danger,
                  backgroundColor: BudgetColors.danger,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBudgetOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to budget screen
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, budgetState) {
            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) {
                if (budgetState is BudgetLoaded &&
                    categoryState is CategoryLoaded) {
                  if (budgetState.budgets.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No budgets set up yet',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first budget to start tracking your spending',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateBudgetScreen(),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                            child: const Text('Create Budget'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: budgetState.budgets.take(3).map((budget) {
                      final category = categoryState.categories.firstWhere(
                        (c) => c.id == budget.categoryId,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BudgetProgressCard(
                          categoryName: category.name,
                          spent: budget.spent,
                          budget: budget.amount,
                          color: Color(AppUtils.hexToColor(category.color)),
                          onTap: () {
                            // TODO: Navigate to budget details
                          },
                        ),
                      );
                    }).toList(),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpenseChart(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, transactionState) {
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            if (transactionState is TransactionLoaded &&
                categoryState is CategoryLoaded) {
              final now = DateTime.now();
              final startOfMonth = AppUtils.startOfMonth(now);

              final monthlyExpenses = transactionState.transactions
                  .where(
                    (t) =>
                        t.type == TransactionType.expense &&
                        t.date.isAfter(
                          startOfMonth.subtract(const Duration(days: 1)),
                        ),
                  )
                  .toList();

              if (monthlyExpenses.isEmpty) {
                return const SizedBox.shrink();
              }

              final categoryExpenses = <String, double>{};
              final categoryColors = <String, Color>{};

              for (final transaction in monthlyExpenses) {
                final category = categoryState.categories.firstWhere(
                  (c) => c.id == transaction.categoryId,
                );
                categoryExpenses[category.name] =
                    (categoryExpenses[category.name] ?? 0) + transaction.amount;
                categoryColors[category.name] = Color(
                  AppUtils.hexToColor(category.color),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month\'s Spending',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ExpenseChart(
                        categoryData: categoryExpenses,
                        categoryColors: categoryColors,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to transactions screen
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, transactionState) {
            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) {
                if (transactionState is TransactionLoaded &&
                    categoryState is CategoryLoaded) {
                  final recentTransactions = transactionState.transactions
                      .take(5)
                      .toList();

                  if (recentTransactions.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first transaction to get started',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: recentTransactions.map((transaction) {
                      final category = categoryState.categories.firstWhere(
                        (c) => c.id == transaction.categoryId,
                      );
                      return TransactionTile(
                        transaction: transaction,
                        category: category,
                        onTap: () {
                          // TODO: Navigate to transaction details
                        },
                        onEdit: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditTransactionScreen(
                                transaction: transaction,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          context.read<TransactionBloc>().add(
                            DeleteTransaction(transaction.id),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction deleted'),
                              backgroundColor: BudgetColors.success,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ],
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
