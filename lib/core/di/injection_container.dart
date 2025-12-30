import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local_data_source.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../presentation/bloc/budget/budget_bloc.dart';
import '../../presentation/bloc/transaction/transaction_bloc.dart';
import '../../presentation/bloc/category/category_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Data sources
  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<FinancialSummaryRepository>(
    () => FinancialSummaryRepositoryImpl(
      transactionRepository: sl(),
      budgetRepository: sl(),
      incomeRepository: sl(),
      categoryRepository: sl(),
    ),
  );

  // Blocs
  sl.registerFactory(() => BudgetBloc(budgetRepository: sl()));
  sl.registerFactory(
    () => TransactionBloc(transactionRepository: sl(), budgetBloc: sl()),
  );
  sl.registerFactory(() => CategoryBloc(categoryRepository: sl()));
}
