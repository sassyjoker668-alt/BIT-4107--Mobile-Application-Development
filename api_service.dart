import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Free currency exchange rate API
  static const String _baseUrl =
      'https://api.exchangerate-api.com/v4/latest/KES';

  // GET request - fetch exchange rates
  static Future<Map<String, dynamic>> getExchangeRates() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        // Success - parse JSON response
        final data = json.decode(response.body);
        return {
          'success': true,
          'rates': data['rates'],
          'date': data['date'],
        };
      } else {
        // Server error
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Network error
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Convert KSh to another currency
  static Future<double> convertCurrency(
      double amount, String toCurrency) async {
    final result = await getExchangeRates();
    if (result['success']) {
      final rates = result['rates'];
      final rate = rates[toCurrency] ?? 1.0;
      return amount * rate;
    }
    return amount;
  }
}