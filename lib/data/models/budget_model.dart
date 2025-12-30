import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    required super.spent,
    required super.startDate,
    required super.endDate,
    required super.period,
    super.isActive = true,
    super.alerts,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      categoryId: budget.categoryId,
      amount: budget.amount,
      spent: budget.spent,
      startDate: budget.startDate,
      endDate: budget.endDate,
      period: budget.period,
      isActive: budget.isActive,
      alerts: budget.alerts,
    );
  }

  Budget toEntity() {
    return Budget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      spent: spent,
      startDate: startDate,
      endDate: endDate,
      period: period,
      isActive: isActive,
      alerts: alerts,
    );
  }

  @override
  BudgetModel copyWith({
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
    return BudgetModel(
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
