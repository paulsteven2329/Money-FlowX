import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_event.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_state.dart';
import '../../domain/entities/budget.dart';
import '../../core/utils/app_utils.dart';
import '../../core/ai/ai_assistant.dart';

class CreateBudgetScreen extends StatefulWidget {
  const CreateBudgetScreen({super.key});

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _startDate = DateTime.now();
  bool _showAiRecommendations = false;
  List<BudgetRecommendation> _aiRecommendations = [];

  @override
  void initState() {
    super.initState();
    _generateAiRecommendations();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Budget'),
        actions: [
          IconButton(
            icon: Icon(
              _showAiRecommendations
                  ? Icons.lightbulb
                  : Icons.lightbulb_outline,
              color: _showAiRecommendations ? Colors.amber : null,
            ),
            onPressed: () {
              setState(() {
                _showAiRecommendations = !_showAiRecommendations;
              });
            },
            tooltip: 'AI Recommendations',
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, categoryState) {
          if (categoryState is CategoryLoaded) {
            return _buildForm(context, categoryState.categories);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _createBudget,
                child: const Text('Create Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<dynamic> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showAiRecommendations && _aiRecommendations.isNotEmpty) ...[
              _buildAiRecommendationsSection(),
              const SizedBox(height: 24),
            ],
            _buildCategorySelector(categories),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 24),
            _buildBudgetTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecommendationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Text(
                'AI Budget Recommendations',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.amber[800]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Based on your spending history:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.amber[700]),
          ),
          const SizedBox(height: 8),
          ...(_aiRecommendations
              .take(3)
              .map(
                (recommendation) => _buildRecommendationCard(recommendation),
              )),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BudgetRecommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[300]!),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategoryId = recommendation.categoryId;
            _amountController.text = recommendation.suggestedAmount
                .toStringAsFixed(0);
          });
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.categoryName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppUtils.formatCurrency(recommendation.suggestedAmount),
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.green),
                  ),
                  Text(
                    recommendation.reason,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(recommendation.confidence * 100).toInt()}% confidence',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(List<dynamic> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            hintText: 'Select a category to budget for',
            prefixIcon: Icon(Icons.category),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category.id,
              child: Row(
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
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Amount', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            labelText: 'Amount',
            hintText: '0.00',
            prefixText: '\$',
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a budget amount';
            }
            if (!AppUtils.isValidAmount(value)) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Period', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        DropdownButtonFormField<BudgetPeriod>(
          value: _selectedPeriod,
          decoration: const InputDecoration(
            hintText: 'Select budget period',
            prefixIcon: Icon(Icons.calendar_today),
          ),
          items: BudgetPeriod.values.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(period.displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPeriod = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Start Date', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _startDate = date;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              hintText: 'Select start date',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(AppUtils.formatDate(_startDate)),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Budgeting Tips',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Start with essential categories like food and transportation\n'
            '• Aim to keep total expenses under 80% of your income\n'
            '• Review and adjust your budgets monthly\n'
            '• Leave room for unexpected expenses',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.blue[600]),
          ),
        ],
      ),
    );
  }

  void _generateAiRecommendations() {
    // This would normally use transaction data
    // For now, we'll simulate some recommendations
    setState(() {
      _aiRecommendations = [
        BudgetRecommendation(
          categoryId: 'food',
          categoryName: 'Food & Dining',
          suggestedAmount: 400.0,
          averageSpending: 380.0,
          confidence: 0.85,
          reason: 'Based on your consistent monthly spending',
        ),
        BudgetRecommendation(
          categoryId: 'transport',
          categoryName: 'Transportation',
          suggestedAmount: 200.0,
          averageSpending: 180.0,
          confidence: 0.78,
          reason: 'Based on your recent travel patterns',
        ),
      ];
    });
  }

  void _createBudget() {
    if (_formKey.currentState!.validate()) {
      final endDate = _calculateEndDate(_startDate, _selectedPeriod);

      final budget = Budget(
        id: const Uuid().v4(),
        categoryId: _selectedCategoryId!,
        amount: double.parse(_amountController.text),
        spent: 0.0,
        startDate: _startDate,
        endDate: endDate,
        period: _selectedPeriod,
        isActive: true,
        alerts: [],
      );

      context.read<BudgetBloc>().add(CreateBudget(budget));
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget created successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  DateTime _calculateEndDate(DateTime startDate, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return startDate.add(const Duration(days: 1));
      case BudgetPeriod.weekly:
        return startDate.add(const Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case BudgetPeriod.yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
    }
  }
}
