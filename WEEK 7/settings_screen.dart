import 'package:flutter/material.dart';
import 'preference_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedCurrency = 'KSh';
  bool _darkMode = false;
  bool _isSaving = false;

  final List<String> _currencies = [
    'KSh', 'USD', 'EUR', 'GBP', 'UGX', 'TZS'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final name = await PreferencesHelper.getName();
    final currency = await PreferencesHelper.getCurrency();
    final budget = await PreferencesHelper.getMonthlyBudget();
    final darkMode = await PreferencesHelper.getDarkMode();

    setState(() {
      _nameController.text = name;
      _selectedCurrency = currency;
      _budgetController.text =
      budget > 0 ? budget.toString() : '';
      _darkMode = darkMode;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    await PreferencesHelper.saveName(
        _nameController.text.trim());
    await PreferencesHelper.saveCurrency(_selectedCurrency);
    await PreferencesHelper.saveDarkMode(_darkMode);

    if (_budgetController.text.isNotEmpty) {
      final budget =
          double.tryParse(_budgetController.text) ?? 0.0;
      await PreferencesHelper.saveMonthlyBudget(budget);
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shared Preferences Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Settings are stored using Shared Preferences',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Display Name',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Currency',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              items: _currencies.map((c) {
                return DropdownMenuItem(
                    value: c, child: Text(c));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedCurrency = value!),
            ),
            const SizedBox(height: 20),

            const Text(
              'Monthly Budget Limit (KSh)',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 50000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wallet),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Switch(
                  value: _darkMode,
                  activeColor: Colors.green,
                  onChanged: (value) =>
                      setState(() => _darkMode = value),
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSettings,
                icon: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Settings',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}