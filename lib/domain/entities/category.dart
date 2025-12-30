import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;
  final CategoryType type;
  final bool isCustom;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isCustom = false,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type, isCustom];
}

enum CategoryType {
  food,
  transport,
  entertainment,
  shopping,
  bills,
  healthcare,
  education,
  travel,
  savings,
  investment,
  income,
  other,
}

extension CategoryTypeExtension on CategoryType {
  String get displayName {
    switch (this) {
      case CategoryType.food:
        return 'Food & Dining';
      case CategoryType.transport:
        return 'Transportation';
      case CategoryType.entertainment:
        return 'Entertainment';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.bills:
        return 'Bills & Utilities';
      case CategoryType.healthcare:
        return 'Healthcare';
      case CategoryType.education:
        return 'Education';
      case CategoryType.travel:
        return 'Travel';
      case CategoryType.savings:
        return 'Savings';
      case CategoryType.investment:
        return 'Investment';
      case CategoryType.income:
        return 'Income';
      case CategoryType.other:
        return 'Other';
    }
  }

  String get defaultIcon {
    switch (this) {
      case CategoryType.food:
        return 'restaurant';
      case CategoryType.transport:
        return 'directions_car';
      case CategoryType.entertainment:
        return 'movie';
      case CategoryType.shopping:
        return 'shopping_bag';
      case CategoryType.bills:
        return 'receipt';
      case CategoryType.healthcare:
        return 'local_hospital';
      case CategoryType.education:
        return 'school';
      case CategoryType.travel:
        return 'flight';
      case CategoryType.savings:
        return 'savings';
      case CategoryType.investment:
        return 'trending_up';
      case CategoryType.income:
        return 'attach_money';
      case CategoryType.other:
        return 'category';
    }
  }

  String get defaultColor {
    switch (this) {
      case CategoryType.food:
        return '#FF6B6B';
      case CategoryType.transport:
        return '#4ECDC4';
      case CategoryType.entertainment:
        return '#45B7D1';
      case CategoryType.shopping:
        return '#96CEB4';
      case CategoryType.bills:
        return '#FECA57';
      case CategoryType.healthcare:
        return '#FF9FF3';
      case CategoryType.education:
        return '#54A0FF';
      case CategoryType.travel:
        return '#5F27CD';
      case CategoryType.savings:
        return '#00D2D3';
      case CategoryType.investment:
        return '#FF9F43';
      case CategoryType.income:
        return '#2ED573';
      case CategoryType.other:
        return '#A4B0BE';
    }
  }
}
