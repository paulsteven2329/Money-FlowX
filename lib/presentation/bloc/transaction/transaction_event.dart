import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class LoadTransactionsByDateRange extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransactionsByDateRange(this.startDate, this.endDate);

  @override
  List<Object> get props => [startDate, endDate];
}

class LoadTransactionsByCategory extends TransactionEvent {
  final String categoryId;

  const LoadTransactionsByCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class CreateTransaction extends TransactionEvent {
  final Transaction transaction;

  const CreateTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class DeleteTransaction extends TransactionEvent {
  final String transactionId;

  const DeleteTransaction(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}
