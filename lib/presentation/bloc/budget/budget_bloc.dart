import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository budgetRepository;

  BudgetBloc({required this.budgetRepository}) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<CreateBudget>(_onCreateBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
    on<UpdateBudgetSpent>(_onUpdateBudgetSpent);
  }

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      emit(BudgetLoading());
      final budgets = await budgetRepository.getAllBudgets();
      emit(BudgetLoaded(budgets));
    } catch (e) {
      emit(BudgetError('Failed to load budgets: ${e.toString()}'));
    }
  }

  Future<void> _onCreateBudget(
    CreateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await budgetRepository.createBudget(event.budget);
      emit(const BudgetOperationSuccess('Budget created successfully'));
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError('Failed to create budget: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await budgetRepository.updateBudget(event.budget);
      emit(const BudgetOperationSuccess('Budget updated successfully'));
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError('Failed to update budget: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await budgetRepository.deleteBudget(event.budgetId);
      emit(const BudgetOperationSuccess('Budget deleted successfully'));
      add(LoadBudgets());
    } catch (e) {
      emit(BudgetError('Failed to delete budget: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateBudgetSpent(
    UpdateBudgetSpent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await budgetRepository.updateBudgetSpent(event.categoryId, event.amount);
      add(LoadBudgets());
    } catch (e) {
      emit(
        BudgetError('Failed to update budget spent amount: ${e.toString()}'),
      );
    }
  }
}
