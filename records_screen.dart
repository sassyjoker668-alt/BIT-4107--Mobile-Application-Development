import 'package:flutter/material.dart';
import 'database_helper.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _incomes = [];
  List<Map<String, dynamic>> _expenses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final incomes = await DatabaseHelper.instance.getAllIncomes();
    final expenses = await DatabaseHelper.instance.getAllExpenses();
    setState(() {
      _incomes = incomes;
      _expenses = expenses;
    });
  }

  Future<void> _deleteIncome(int id) async {
    await DatabaseHelper.instance.deleteIncome(id);
    _loadData();
  }

  Future<void> _deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    _loadData();
  }

  void _editIncome(Map<String, dynamic> income) {
    final amountController =
    TextEditingController(text: income['amount'].toString());
    final noteController =
    TextEditingController(text: income['note'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Income'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.updateIncome({
                'id': income['id'],
                'source': income['source'],
                'amount': double.parse(amountController.text),
                'note': noteController.text,
                'date': income['date'],
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editExpense(Map<String, dynamic> expense) {
    final amountController =
    TextEditingController(text: expense['amount'].toString());
    final noteController =
    TextEditingController(text: expense['note'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.updateExpense({
                'id': expense['id'],
                'category': expense['category'],
                'amount': double.parse(amountController.text),
                'note': noteController.text,
                'date': expense['date'],
              });
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Income List
          _incomes.isEmpty
              ? const Center(child: Text('No income records yet'))
              : ListView.builder(
            itemCount: _incomes.length,
            itemBuilder: (context, index) {
              final item = _incomes[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.arrow_upward,
                        color: Colors.white),
                  ),
                  title: Text(item['source']),
                  subtitle: Text(item['note'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'KSh ${item['amount']}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue),
                        onPressed: () => _editIncome(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () =>
                            _deleteIncome(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Expense List
          _expenses.isEmpty
              ? const Center(child: Text('No expense records yet'))
              : ListView.builder(
            itemCount: _expenses.length,
            itemBuilder: (context, index) {
              final item = _expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.arrow_downward,
                        color: Colors.white),
                  ),
                  title: Text(item['category']),
                  subtitle: Text(item['note'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'KSh ${item['amount']}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue),
                        onPressed: () => _editExpense(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () =>
                            _deleteExpense(item['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}