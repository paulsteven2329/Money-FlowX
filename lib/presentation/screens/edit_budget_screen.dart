import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/budget/budget_event.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_state.dart';
import '../../domain/entities/budget.dart';
import '../../core/utils/app_utils.dart';
import '../../core/theme/app_theme.dart';

class EditBudgetScreen extends StatefulWidget {
  final dynamic budget;

  const EditBudgetScreen({super.key, required this.budget});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.budget.amount.toString(),
    );
    _selectedCategoryId = widget.budget.categoryId;
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
        title: const Text('Edit Budget'),
        actions: [
          TextButton(
            onPressed: _saveBudget,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is! CategoryLoaded) {
            return const Center(child: Text('Unable to load categories'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategorySelector(state.categories),
                  const SizedBox(height: 24),
                  _buildAmountField(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          );
        },
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
          initialValue: _selectedCategoryId,
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
              _selectedCategoryId = value!;
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '0.00',
            prefixIcon: Icon(Icons.account_balance_wallet),
            prefixText: '\$ ',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a budget amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveBudget,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Update Budget',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _saveBudget() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedBudget = Budget(
        id: widget.budget.id,
        categoryId: _selectedCategoryId,
        amount: double.parse(_amountController.text),
        spent: widget.budget.spent,
        startDate: widget.budget.startDate,
        endDate: widget.budget.endDate,
        period: widget.budget.period,
        isActive: widget.budget.isActive,
        alerts: widget.budget.alerts,
      );

      context.read<BudgetBloc>().add(UpdateBudget(updatedBudget));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget updated successfully!'),
          backgroundColor: BudgetColors.success,
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
