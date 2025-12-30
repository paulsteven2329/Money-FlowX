import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final String description;
  final DateTime date;
  final TransactionType type;
  final String? note;
  final List<String>? tags;

  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.date,
    required this.type,
    this.note,
    this.tags,
  });

  @override
  List<Object?> get props => [
    id,
    amount,
    categoryId,
    description,
    date,
    type,
    note,
    tags,
  ];

  Transaction copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    TransactionType? type,
    String? note,
    List<String>? tags,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }
}

enum TransactionType { expense, income }

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }
}
