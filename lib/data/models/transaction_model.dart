import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.categoryId,
    required super.description,
    required super.date,
    required super.type,
    super.note,
    super.tags,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      description: transaction.description,
      date: transaction.date,
      type: transaction.type,
      note: transaction.note,
      tags: transaction.tags,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      categoryId: categoryId,
      description: description,
      date: date,
      type: type,
      note: note,
      tags: tags,
    );
  }

  @override
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    TransactionType? type,
    String? note,
    List<String>? tags,
  }) {
    return TransactionModel(
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
