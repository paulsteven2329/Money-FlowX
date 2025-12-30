import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/budget_repository.dart';
import '../../../domain/entities/transaction.dart';
import '../budget/budget_bloc.dart';
import '../budget/budget_event.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;
  final BudgetBloc? budgetBloc;

  TransactionBloc({required this.transactionRepository, this.budgetBloc})
    : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionsByDateRange>(_onLoadTransactionsByDateRange);
    on<LoadTransactionsByCategory>(_onLoadTransactionsByCategory);
    on<CreateTransaction>(_onCreateTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final transactions = await transactionRepository.getAllTransactions();
      transactions.sort(
        (a, b) => b.date.compareTo(a.date),
      ); // Most recent first
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTransactionsByDateRange(
    LoadTransactionsByDateRange event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final transactions = await transactionRepository
          .getTransactionsByDateRange(event.startDate, event.endDate);
      transactions.sort((a, b) => b.date.compareTo(a.date));
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTransactionsByCategory(
    LoadTransactionsByCategory event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      emit(TransactionLoading());
      final transactions = await transactionRepository
          .getTransactionsByCategory(event.categoryId);
      transactions.sort((a, b) => b.date.compareTo(a.date));
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await transactionRepository.createTransaction(event.transaction);

      // Update budget spent amount if it's an expense
      if (event.transaction.type == TransactionType.expense &&
          budgetBloc != null) {
        budgetBloc!.add(
          UpdateBudgetSpent(
            event.transaction.categoryId,
            event.transaction.amount,
          ),
        );
      }

      emit(
        const TransactionOperationSuccess('Transaction created successfully'),
      );
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError('Failed to create transaction: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await transactionRepository.updateTransaction(event.transaction);
      emit(
        const TransactionOperationSuccess('Transaction updated successfully'),
      );
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError('Failed to update transaction: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await transactionRepository.deleteTransaction(event.transactionId);
      emit(
        const TransactionOperationSuccess('Transaction deleted successfully'),
      );
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: ${e.toString()}'));
    }
  }
}
