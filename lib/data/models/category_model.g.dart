// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      type: $enumDecode(_$CategoryTypeEnumMap, json['type']),
      isCustom: json['isCustom'] as bool? ?? false,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
      'type': _$CategoryTypeEnumMap[instance.type]!,
      'isCustom': instance.isCustom,
    };

const _$CategoryTypeEnumMap = {
  CategoryType.food: 'food',
  CategoryType.transport: 'transport',
  CategoryType.entertainment: 'entertainment',
  CategoryType.shopping: 'shopping',
  CategoryType.bills: 'bills',
  CategoryType.healthcare: 'healthcare',
  CategoryType.education: 'education',
  CategoryType.travel: 'travel',
  CategoryType.savings: 'savings',
  CategoryType.investment: 'investment',
  CategoryType.income: 'income',
  CategoryType.other: 'other',
};
