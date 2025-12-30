import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String categoryId;
  final double amount;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPeriod period;
  final bool isActive;
  final List<String>? alerts;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.spent,
    required this.startDate,
    required this.endDate,
    required this.period,
    this.isActive = true,
    this.alerts,
  });

  double get remaining => amount - spent;
  double get percentage => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;
  bool get isNearLimit => percentage >= 80 && percentage < 100;

  @override
  List<Object?> get props => [
    id,
    categoryId,
    amount,
    spent,
    startDate,
    endDate,
    period,
    isActive,
    alerts,
  ];

  Budget copyWith({
    String? id,
    String? categoryId,
    double? amount,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPeriod? period,
    bool? isActive,
    List<String>? alerts,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      period: period ?? this.period,
      isActive: isActive ?? this.isActive,
      alerts: alerts ?? this.alerts,
    );
  }
}

enum BudgetPeriod { daily, weekly, monthly, yearly }

extension BudgetPeriodExtension on BudgetPeriod {
  String get displayName {
    switch (this) {
      case BudgetPeriod.daily:
        return 'Daily';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
    }
  }

  int get durationInDays {
    switch (this) {
      case BudgetPeriod.daily:
        return 1;
      case BudgetPeriod.weekly:
        return 7;
      case BudgetPeriod.monthly:
        return 30;
      case BudgetPeriod.yearly:
        return 365;
    }
  }
}
