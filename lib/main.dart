import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'presentation/bloc/budget/budget_bloc.dart';
import 'presentation/bloc/transaction/transaction_bloc.dart';
import 'presentation/bloc/category/category_bloc.dart';
import 'presentation/bloc/category/category_event.dart';
import 'presentation/bloc/budget/budget_event.dart';
import 'presentation/bloc/transaction/transaction_event.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MoneyFlowXApp());
}

class MoneyFlowXApp extends StatelessWidget {
  const MoneyFlowXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryBloc>(
          create: (_) => di.sl<CategoryBloc>()..add(LoadDefaultCategories()),
        ),
        BlocProvider<BudgetBloc>(
          create: (_) => di.sl<BudgetBloc>()..add(LoadBudgets()),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) =>
              di.sl<TransactionBloc>()..add(LoadTransactions()),
        ),
      ],
      child: MaterialApp(
        title: 'MoneyFlowX',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
