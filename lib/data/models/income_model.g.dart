// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncomeModel _$IncomeModelFromJson(Map<String, dynamic> json) => IncomeModel(
  id: json['id'] as String,
  source: json['source'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  frequency: $enumDecode(_$IncomeFrequencyEnumMap, json['frequency']),
  isRecurring: json['isRecurring'] as bool? ?? false,
  description: json['description'] as String?,
  nextOccurrence: json['nextOccurrence'] == null
      ? null
      : DateTime.parse(json['nextOccurrence'] as String),
);

Map<String, dynamic> _$IncomeModelToJson(IncomeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source': instance.source,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'frequency': _$IncomeFrequencyEnumMap[instance.frequency]!,
      'isRecurring': instance.isRecurring,
      'description': instance.description,
      'nextOccurrence': instance.nextOccurrence?.toIso8601String(),
    };

const _$IncomeFrequencyEnumMap = {
  IncomeFrequency.oneTime: 'oneTime',
  IncomeFrequency.weekly: 'weekly',
  IncomeFrequency.biWeekly: 'biWeekly',
  IncomeFrequency.monthly: 'monthly',
  IncomeFrequency.quarterly: 'quarterly',
  IncomeFrequency.yearly: 'yearly',
};
