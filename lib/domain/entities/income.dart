import 'package:equatable/equatable.dart';

class Income extends Equatable {
  final String id;
  final String source;
  final double amount;
  final DateTime date;
  final IncomeFrequency frequency;
  final bool isRecurring;
  final String? description;
  final DateTime? nextOccurrence;

  const Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    required this.frequency,
    this.isRecurring = false,
    this.description,
    this.nextOccurrence,
  });

  @override
  List<Object?> get props => [
    id,
    source,
    amount,
    date,
    frequency,
    isRecurring,
    description,
    nextOccurrence,
  ];

  Income copyWith({
    String? id,
    String? source,
    double? amount,
    DateTime? date,
    IncomeFrequency? frequency,
    bool? isRecurring,
    String? description,
    DateTime? nextOccurrence,
  }) {
    return Income(
      id: id ?? this.id,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      frequency: frequency ?? this.frequency,
      isRecurring: isRecurring ?? this.isRecurring,
      description: description ?? this.description,
      nextOccurrence: nextOccurrence ?? this.nextOccurrence,
    );
  }
}

enum IncomeFrequency { oneTime, weekly, biWeekly, monthly, quarterly, yearly }

extension IncomeFrequencyExtension on IncomeFrequency {
  String get displayName {
    switch (this) {
      case IncomeFrequency.oneTime:
        return 'One Time';
      case IncomeFrequency.weekly:
        return 'Weekly';
      case IncomeFrequency.biWeekly:
        return 'Bi-Weekly';
      case IncomeFrequency.monthly:
        return 'Monthly';
      case IncomeFrequency.quarterly:
        return 'Quarterly';
      case IncomeFrequency.yearly:
        return 'Yearly';
    }
  }

  Duration get duration {
    switch (this) {
      case IncomeFrequency.oneTime:
        return Duration.zero;
      case IncomeFrequency.weekly:
        return const Duration(days: 7);
      case IncomeFrequency.biWeekly:
        return const Duration(days: 14);
      case IncomeFrequency.monthly:
        return const Duration(days: 30);
      case IncomeFrequency.quarterly:
        return const Duration(days: 91);
      case IncomeFrequency.yearly:
        return const Duration(days: 365);
    }
  }
}
