import '../../domain/entities/transaction.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/financial_summary.dart';

class AIAssistant {
  // Pattern recognition for category suggestions
  static const Map<String, List<String>> _categoryKeywords = {
    'food': [
      'restaurant',
      'cafe',
      'pizza',
      'burger',
      'coffee',
      'starbucks',
      'mcdonalds',
      'kfc',
      'grocery',
      'supermarket',
      'food',
      'dining',
      'lunch',
      'dinner',
      'breakfast',
      'snack',
      'bakery',
      'deli',
      'fast food',
    ],
    'transport': [
      'gas',
      'fuel',
      'uber',
      'lyft',
      'taxi',
      'bus',
      'train',
      'metro',
      'parking',
      'toll',
      'car',
      'automotive',
      'repair',
      'maintenance',
      'insurance',
    ],
    'shopping': [
      'amazon',
      'walmart',
      'target',
      'mall',
      'store',
      'clothes',
      'clothing',
      'shoes',
      'electronics',
      'gadget',
      'phone',
      'laptop',
      'book',
    ],
    'entertainment': [
      'movie',
      'cinema',
      'netflix',
      'spotify',
      'game',
      'gaming',
      'concert',
      'theater',
      'sports',
      'gym',
      'fitness',
      'subscription',
    ],
    'bills': [
      'electric',
      'electricity',
      'water',
      'internet',
      'wifi',
      'phone',
      'mobile',
      'rent',
      'mortgage',
      'insurance',
      'utility',
    ],
    'healthcare': [
      'doctor',
      'hospital',
      'pharmacy',
      'medicine',
      'dental',
      'clinic',
      'health',
      'medical',
      'prescription',
    ],
  };

  // Suggest category based on transaction description
  static String suggestCategory(String description, List<Category> categories) {
    final lowercaseDesc = description.toLowerCase();

    // Count matches for each category
    final categoryScores = <String, int>{};

    for (final entry in _categoryKeywords.entries) {
      final categoryType = entry.key;
      final keywords = entry.value;

      int score = 0;
      for (final keyword in keywords) {
        if (lowercaseDesc.contains(keyword)) {
          score += 2; // Exact match gets higher score
        }
        // Check for partial matches
        if (lowercaseDesc
            .split(' ')
            .any((word) => word.contains(keyword) || keyword.contains(word))) {
          score += 1;
        }
      }

      if (score > 0) {
        categoryScores[categoryType] = score;
      }
    }

    if (categoryScores.isEmpty) {
      // Return first available category if no matches
      return categories.first.id;
    }

    // Find the category with highest score
    final bestMatch = categoryScores.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    // Find corresponding category ID
    final matchedCategory = categories.firstWhere(
      (cat) => cat.type.toString().split('.').last == bestMatch.key,
      orElse: () => categories.first,
    );

    return matchedCategory.id;
  }

  // Generate budget recommendations based on spending patterns
  static List<BudgetRecommendation> generateBudgetRecommendations(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    final recommendations = <BudgetRecommendation>[];

    // Calculate average monthly spending per category
    final now = DateTime.now();
    final monthsToAnalyze = 3;
    final startDate = DateTime(now.year, now.month - monthsToAnalyze, 1);

    final recentTransactions = transactions
        .where(
          (t) => t.type == TransactionType.expense && t.date.isAfter(startDate),
        )
        .toList();

    final categorySpending = <String, List<double>>{};

    for (int i = 0; i < monthsToAnalyze; i++) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);

      for (final category in categories) {
        final monthlyExpenses = recentTransactions
            .where(
              (t) =>
                  t.categoryId == category.id &&
                  t.date.isAfter(monthStart) &&
                  t.date.isBefore(monthEnd),
            )
            .fold<double>(0.0, (sum, t) => sum + t.amount);

        categorySpending
            .putIfAbsent(category.id, () => [])
            .add(monthlyExpenses);
      }
    }

    // Generate recommendations
    for (final entry in categorySpending.entries) {
      final categoryId = entry.key;
      final monthlyAmounts = entry.value;

      if (monthlyAmounts.any((amount) => amount > 0)) {
        final averageSpending =
            monthlyAmounts.fold<double>(0.0, (a, b) => a + b) /
            monthlyAmounts.length;
        final maxSpending = monthlyAmounts.reduce((a, b) => a > b ? a : b);

        // Suggest budget with 10% buffer
        final suggestedBudget = (maxSpending * 1.1).roundToDouble();

        final category = categories.firstWhere((c) => c.id == categoryId);

        recommendations.add(
          BudgetRecommendation(
            categoryId: categoryId,
            categoryName: category.name,
            suggestedAmount: suggestedBudget,
            averageSpending: averageSpending,
            confidence: _calculateConfidence(monthlyAmounts),
            reason: _generateReasonText(averageSpending, maxSpending),
          ),
        );
      }
    }

    return recommendations
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  // Generate spending insights
  static List<AIInsight> generateInsights(
    List<Transaction> transactions,
    List<Budget> budgets,
    List<Category> categories,
  ) {
    final insights = <AIInsight>[];

    // Analyze spending patterns
    insights.addAll(_analyzeSpendingPatterns(transactions, categories));

    // Analyze budget performance
    insights.addAll(
      _analyzeBudgetPerformance(budgets, transactions, categories),
    );

    // Detect unusual activities
    insights.addAll(_detectUnusualActivities(transactions, categories));

    return insights
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  // Suggest recurring transactions
  static List<RecurringTransactionSuggestion> suggestRecurringTransactions(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    final suggestions = <RecurringTransactionSuggestion>[];

    // Group transactions by description and amount
    final transactionGroups = <String, List<Transaction>>{};

    for (final transaction in transactions) {
      final key =
          '${transaction.description.toLowerCase()}_${transaction.amount}';
      transactionGroups.putIfAbsent(key, () => []).add(transaction);
    }

    // Identify potential recurring patterns
    for (final entry in transactionGroups.entries) {
      final transactions = entry.value;

      if (transactions.length >= 3) {
        // Check for regular intervals
        transactions.sort((a, b) => a.date.compareTo(b.date));

        final intervals = <int>[];
        for (int i = 1; i < transactions.length; i++) {
          intervals.add(
            transactions[i].date.difference(transactions[i - 1].date).inDays,
          );
        }

        final avgInterval =
            intervals.fold<double>(0.0, (a, b) => a + b) / intervals.length;
        final intervalVariance =
            intervals
                .map((i) => (i - avgInterval).abs())
                .fold<double>(0.0, (a, b) => a + b) /
            intervals.length;

        // If variance is low, it's likely recurring
        if (intervalVariance < avgInterval * 0.2 && avgInterval >= 7) {
          final category = categories.firstWhere(
            (c) => c.id == transactions.first.categoryId,
          );

          suggestions.add(
            RecurringTransactionSuggestion(
              description: transactions.first.description,
              amount: transactions.first.amount,
              categoryId: transactions.first.categoryId,
              categoryName: category.name,
              intervalDays: avgInterval.round(),
              confidence: 1.0 - (intervalVariance / avgInterval),
              lastOccurrence: transactions.last.date,
            ),
          );
        }
      }
    }

    return suggestions..sort((a, b) => b.confidence.compareTo(a.confidence));
  }

  // Helper methods
  static double _calculateConfidence(List<double> amounts) {
    if (amounts.isEmpty) return 0.0;

    final average = amounts.fold<double>(0.0, (a, b) => a + b) / amounts.length;
    final variance =
        amounts
            .map((a) => (a - average).abs())
            .fold<double>(0.0, (a, b) => a + b) /
        amounts.length;

    // Higher consistency = higher confidence
    return average > 0 ? (1.0 - (variance / average)).clamp(0.0, 1.0) : 0.0;
  }

  static String _generateReasonText(double average, double max) {
    if (max > average * 1.5) {
      return 'Based on your spending pattern with some high expense months';
    } else {
      return 'Based on your consistent monthly spending pattern';
    }
  }

  static List<AIInsight> _analyzeSpendingPatterns(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    // Implementation for spending pattern analysis
    return [];
  }

  static List<AIInsight> _analyzeBudgetPerformance(
    List<Budget> budgets,
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    // Implementation for budget performance analysis
    return [];
  }

  static List<AIInsight> _detectUnusualActivities(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    // Implementation for unusual activity detection
    return [];
  }
}

// Data classes for AI recommendations
class BudgetRecommendation {
  final String categoryId;
  final String categoryName;
  final double suggestedAmount;
  final double averageSpending;
  final double confidence;
  final String reason;

  BudgetRecommendation({
    required this.categoryId,
    required this.categoryName,
    required this.suggestedAmount,
    required this.averageSpending,
    required this.confidence,
    required this.reason,
  });
}

class RecurringTransactionSuggestion {
  final String description;
  final double amount;
  final String categoryId;
  final String categoryName;
  final int intervalDays;
  final double confidence;
  final DateTime lastOccurrence;

  RecurringTransactionSuggestion({
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.intervalDays,
    required this.confidence,
    required this.lastOccurrence,
  });

  String get frequencyText {
    if (intervalDays <= 7) return 'Weekly';
    if (intervalDays <= 14) return 'Bi-weekly';
    if (intervalDays <= 31) return 'Monthly';
    if (intervalDays <= 93) return 'Quarterly';
    return 'Yearly';
  }
}
