import 'package:equatable/equatable.dart';

class FinancialSummary extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final double totalBudget;
  final double totalSavings;
  final Map<String, double> categoryExpenses;
  final Map<String, double> categoryBudgets;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> topCategories;
  final double averageDailySpending;

  const FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBudget,
    required this.totalSavings,
    required this.categoryExpenses,
    required this.categoryBudgets,
    required this.startDate,
    required this.endDate,
    required this.topCategories,
    required this.averageDailySpending,
  });

  double get balance => totalIncome - totalExpenses;
  double get budgetUtilization =>
      totalBudget > 0 ? (totalExpenses / totalBudget) * 100 : 0;
  bool get isOverBudget => totalExpenses > totalBudget;

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpenses,
    totalBudget,
    totalSavings,
    categoryExpenses,
    categoryBudgets,
    startDate,
    endDate,
    topCategories,
    averageDailySpending,
  ];
}

class AIInsight extends Equatable {
  final String id;
  final String title;
  final String message;
  final InsightType type;
  final InsightPriority priority;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AIInsight({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    priority,
    createdAt,
    isRead,
    data,
  ];
}

enum InsightType {
  budgetAlert,
  spendingPattern,
  savingsSuggestion,
  categoryRecommendation,
  goalProgress,
  unusualActivity,
}

enum InsightPriority { low, medium, high, critical }
