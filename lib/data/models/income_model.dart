import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/income.dart';

part 'income_model.g.dart';

@JsonSerializable()
class IncomeModel extends Income {
  const IncomeModel({
    required super.id,
    required super.source,
    required super.amount,
    required super.date,
    required super.frequency,
    super.isRecurring = false,
    super.description,
    super.nextOccurrence,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) =>
      _$IncomeModelFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeModelToJson(this);

  factory IncomeModel.fromEntity(Income income) {
    return IncomeModel(
      id: income.id,
      source: income.source,
      amount: income.amount,
      date: income.date,
      frequency: income.frequency,
      isRecurring: income.isRecurring,
      description: income.description,
      nextOccurrence: income.nextOccurrence,
    );
  }

  Income toEntity() {
    return Income(
      id: id,
      source: source,
      amount: amount,
      date: date,
      frequency: frequency,
      isRecurring: isRecurring,
      description: description,
      nextOccurrence: nextOccurrence,
    );
  }

  @override
  IncomeModel copyWith({
    String? id,
    String? source,
    double? amount,
    DateTime? date,
    IncomeFrequency? frequency,
    bool? isRecurring,
    String? description,
    DateTime? nextOccurrence,
  }) {
    return IncomeModel(
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
