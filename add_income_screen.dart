import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedSource = 'Salary';
  bool _isLoading = false;

  final List<String> _sources = [
    'Salary',
    'Business',
    'Freelance',
    'Side Hustle',
    'Allowance',
    'Other',
  ];

  Future<void> _saveIncome() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('incomes')
        .add({
      'source': _selectedSource,
      'amount': double.parse(_amountController.text),
      'note': _noteController.text,
      'date': DateTime.now().toIso8601String(),
    });

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Income added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Income'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSource,
              decoration: const InputDecoration(
                labelText: 'Income Source',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.source),
              ),
              items: _sources.map((source) {
                return DropdownMenuItem(
                  value: source,
                  child: Text(source),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedSource = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (KSh)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                    color: Colors.white)
                    : const Text('Save Income',
                    style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}