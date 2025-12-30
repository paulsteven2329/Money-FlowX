import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_state.dart';
import '../bloc/budget/budget_event.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_state.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../bloc/transaction/transaction_state.dart';
import '../../core/widgets/budget_progress_card.dart';
import '../../core/utils/app_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';
import 'create_budget_screen.dart';
import 'edit_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budgets'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateBudgetScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, budgetState) {
          if (budgetState is BudgetLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetState is BudgetError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading budgets',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    budgetState.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BudgetBloc>().add(LoadBudgets());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (budgetState is! BudgetLoaded) {
            return const Center(child: Text('Unable to load budgets'));
          }

          if (budgetState.budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets yet',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first budget to start tracking your spending',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CreateBudgetScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Budget'),
                  ),
                ],
              ),
            );
          }

          return BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, categoryState) {
              if (categoryState is! CategoryLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              return BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, transactionState) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBudgetSummary(
                          budgetState.budgets,
                          transactionState,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget Details',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateBudgetScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Budget'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...budgetState.budgets.map((budget) {
                          final category = categoryState.categories.firstWhere(
                            (c) => c.id == budget.categoryId,
                          );

                          double spent = 0.0;
                          if (transactionState is TransactionLoaded) {
                            final currentMonth = DateTime.now();
                            final monthlyExpenses = transactionState
                                .transactions
                                .where(
                                  (t) =>
                                      t.categoryId == budget.categoryId &&
                                      t.date.year == currentMonth.year &&
                                      t.date.month == currentMonth.month &&
                                      t.type == TransactionType.expense,
                                )
                                .fold(0.0, (sum, t) => sum + t.amount);
                            spent = monthlyExpenses;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BudgetProgressCard(
                              categoryName: category.name,
                              spent: spent,
                              budget: budget.amount,
                              color: Color(AppUtils.hexToColor(category.color)),
                              onTap: () => _showBudgetDetails(
                                context,
                                budget,
                                category,
                                spent,
                              ),
                              onEdit: () => _editBudget(context, budget),
                              onDelete: () => _deleteBudget(context, budget),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateBudgetScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetSummary(
    List<dynamic> budgets,
    TransactionState transactionState,
  ) {
    double totalBudget = budgets.fold(
      0.0,
      (sum, budget) => sum + budget.amount,
    );
    double totalSpent = 0.0;

    if (transactionState is TransactionLoaded) {
      final currentMonth = DateTime.now();
      totalSpent = transactionState.transactions
          .where(
            (t) =>
                t.date.year == currentMonth.year &&
                t.date.month == currentMonth.month &&
                t.type == TransactionType.expense,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    final remaining = totalBudget - totalSpent;
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Monthly Budget Overview',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Total Budget',
                    AppUtils.formatCurrency(totalBudget),
                    BudgetColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Spent',
                    AppUtils.formatCurrency(totalSpent),
                    percentage > 80 ? BudgetColors.danger : BudgetColors.info,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Remaining',
                    AppUtils.formatCurrency(remaining),
                    remaining >= 0 ? BudgetColors.success : BudgetColors.danger,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 100
                    ? BudgetColors.danger
                    : percentage > 80
                    ? BudgetColors.warning
                    : BudgetColors.success,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppUtils.formatPercentage(percentage)} of budget used',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: percentage > 100
                    ? BudgetColors.danger
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showBudgetDetails(
    BuildContext context,
    dynamic budget,
    dynamic category,
    double spent,
  ) {
    final remaining = budget.amount - spent;
    final percentage = AppUtils.calculateBudgetPercentage(spent, budget.amount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(AppUtils.hexToColor(category.color)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.of(context).pop();
                          _editBudget(context, budget);
                        } else if (value == 'delete') {
                          Navigator.of(context).pop();
                          _deleteBudget(context, budget);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit Budget'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete Budget',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          context,
                          'Budget Amount',
                          AppUtils.formatCurrency(budget.amount),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          'Amount Spent',
                          AppUtils.formatCurrency(spent),
                          valueColor: percentage > 80
                              ? BudgetColors.danger
                              : BudgetColors.info,
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          'Remaining',
                          AppUtils.formatCurrency(remaining),
                          valueColor: remaining >= 0
                              ? BudgetColors.success
                              : BudgetColors.danger,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage > 100
                                ? BudgetColors.danger
                                : percentage > 80
                                ? BudgetColors.warning
                                : BudgetColors.success,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${AppUtils.formatPercentage(percentage)} of budget used',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (percentage > 80)
                  Card(
                    color:
                        (percentage > 100
                                ? BudgetColors.danger
                                : BudgetColors.warning)
                            .withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            percentage > 100 ? Icons.error : Icons.warning,
                            color: percentage > 100
                                ? BudgetColors.danger
                                : BudgetColors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              percentage > 100
                                  ? 'You have exceeded your budget for this category'
                                  : 'You are approaching your budget limit',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: percentage > 100
                                        ? BudgetColors.danger
                                        : BudgetColors.warning,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _editBudget(BuildContext context, dynamic budget) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EditBudgetScreen(budget: budget)),
    );
  }

  void _deleteBudget(BuildContext context, dynamic budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<BudgetBloc>().add(DeleteBudget(budget.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Budget deleted'),
                  backgroundColor: BudgetColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
