import 'package:intl/intl.dart';

class AppUtils {
  // Currency formatting
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('MM/dd').format(date);
  }

  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM dd').format(start)} - ${DateFormat('dd, yyyy').format(end)}';
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Percentage formatting
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // Time ago formatting
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Budget status helpers
  static String getBudgetStatusText(double spent, double budget) {
    if (spent > budget) {
      final over = spent - budget;
      return 'Over by ${formatCurrency(over)}';
    } else {
      final remaining = budget - spent;
      return '${formatCurrency(remaining)} remaining';
    }
  }

  static double calculateBudgetPercentage(double spent, double budget) {
    if (budget <= 0) return 0;
    return (spent / budget) * 100;
  }

  // Date range helpers
  static DateTime startOfMonth([DateTime? date]) {
    date ??= DateTime.now();
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth([DateTime? date]) {
    date ??= DateTime.now();
    return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime startOfWeek([DateTime? date]) {
    date ??= DateTime.now();
    final difference = date.weekday - 1;
    return date.subtract(Duration(days: difference));
  }

  static DateTime endOfWeek([DateTime? date]) {
    date ??= DateTime.now();
    final difference = 7 - date.weekday;
    return date.add(Duration(days: difference));
  }

  static DateTime startOfYear([DateTime? date]) {
    date ??= DateTime.now();
    return DateTime(date.year, 1, 1);
  }

  static DateTime endOfYear([DateTime? date]) {
    date ??= DateTime.now();
    return DateTime(date.year, 12, 31);
  }

  // Color helpers
  static String colorToHex(int colorValue) {
    return '#${colorValue.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  static int hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return int.parse(hex, radix: 16);
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidAmount(String amount) {
    try {
      final parsed = double.parse(amount);
      return parsed > 0;
    } catch (e) {
      return false;
    }
  }

  // Format currency for short display in charts
  static String formatCurrencyShort(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
