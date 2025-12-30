// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BudgetModel _$BudgetModelFromJson(Map<String, dynamic> json) => BudgetModel(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String,
  amount: (json['amount'] as num).toDouble(),
  spent: (json['spent'] as num).toDouble(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  period: $enumDecode(_$BudgetPeriodEnumMap, json['period']),
  isActive: json['isActive'] as bool? ?? true,
  alerts: (json['alerts'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$BudgetModelToJson(BudgetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'amount': instance.amount,
      'spent': instance.spent,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'period': _$BudgetPeriodEnumMap[instance.period]!,
      'isActive': instance.isActive,
      'alerts': instance.alerts,
    };

const _$BudgetPeriodEnumMap = {
  BudgetPeriod.daily: 'daily',
  BudgetPeriod.weekly: 'weekly',
  BudgetPeriod.monthly: 'monthly',
  BudgetPeriod.yearly: 'yearly',
};
