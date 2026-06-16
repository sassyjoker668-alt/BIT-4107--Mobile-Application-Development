import 'package:flutter/material.dart';
import 'api_service.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final _amountController = TextEditingController();
  String _selectedCurrency = 'USD';
  double? _convertedAmount;
  bool _isLoading = false;
  String _lastUpdated = '';
  Map<String, dynamic> _rates = {};

  final List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'UGX', 'TZS', 'ZAR', 'NGN', 'INR'
  ];

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() => _isLoading = true);

    final result = await ApiService.getExchangeRates();

    if (result['success']) {
      setState(() {
        _rates = result['rates'];
        _lastUpdated = result['date'];
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _convert() async {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final amount = double.parse(_amountController.text);
    final converted = await ApiService.convertCurrency(
        amount, _selectedCurrency);

    setState(() {
      _convertedAmount = converted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRates,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Status Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _rates.isEmpty
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _rates.isEmpty
                      ? Colors.red.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _rates.isEmpty ? Icons.wifi_off : Icons.wifi,
                    color: _rates.isEmpty ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _rates.isEmpty
                        ? 'Fetching rates...'
                        : 'Live rates updated: $_lastUpdated',
                    style: TextStyle(
                      color: _rates.isEmpty
                          ? Colors.red
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount Input
            const Text('Amount in KSh',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 5000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),

            // Currency Dropdown
            const Text('Convert To',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_exchange),
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedCurrency = value!),
            ),
            const SizedBox(height: 24),

            // Convert Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _convert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                    color: Colors.white)
                    : const Text('Convert',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),

            // Result
            if (_convertedAmount != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Converted Amount',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_selectedCurrency ${_convertedAmount!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'KSh ${_amountController.text} → $_selectedCurrency',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Live Rates Table
            if (_rates.isNotEmpty) ...[
              const Text('Live Exchange Rates (from KSh)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: _currencies.map((currency) {
                    final rate = _rates[currency] ?? 0.0;
                    return ListTile(
                      leading: const Icon(Icons.currency_exchange,
                          color: Colors.green),
                      title: Text(currency),
                      trailing: Text(
                        rate.toStringAsFixed(4),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}