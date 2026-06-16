import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _nameKey = 'user_name';
  static const String _currencyKey = 'currency';
  static const String _budgetKey = 'monthly_budget';

  // Save user name
  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  // Get user name
  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'User';
  }

  // Save currency
  static Future<void> saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  // Get currency
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? 'KSh';
  }

  // Save monthly budget limit
  static Future<void> saveMonthlyBudget(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, amount);
  }

  // Get monthly budget limit
  static Future<double> getMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_budgetKey) ?? 0.0;
  }
}