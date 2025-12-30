import 'package:equatable/equatable.dart';
import '../../../domain/entities/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class CreateBudget extends BudgetEvent {
  final Budget budget;

  const CreateBudget(this.budget);

  @override
  List<Object> get props => [budget];
}

class UpdateBudget extends BudgetEvent {
  final Budget budget;

  const UpdateBudget(this.budget);

  @override
  List<Object> get props => [budget];
}

class DeleteBudget extends BudgetEvent {
  final String budgetId;

  const DeleteBudget(this.budgetId);

  @override
  List<Object> get props => [budgetId];
}

class UpdateBudgetSpent extends BudgetEvent {
  final String categoryId;
  final double amount;

  const UpdateBudgetSpent(this.categoryId, this.amount);

  @override
  List<Object> get props => [categoryId, amount];
}
