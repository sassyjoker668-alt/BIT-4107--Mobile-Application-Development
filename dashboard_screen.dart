import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_income_screen.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text('My Budget'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.email ?? "User"}!',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _SummaryCard(
                  title: 'Income',
                  amount: 'KSh 0',
                  color: Colors.green,
                  icon: Icons.arrow_upward,
                ),
                const SizedBox(width: 16),
                _SummaryCard(
                  title: 'Expenses',
                  amount: 'KSh 0',
                  color: Colors.red,
                  icon: Icons.arrow_downward,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryCard(
              title: 'Savings',
              amount: 'KSh 0',
              color: Colors.blue,
              icon: Icons.savings,
              fullWidth: true,
            ),
            const SizedBox(height: 32),
            const Text(
              'Quick Actions',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.add_circle,
                  label: 'Add Income',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddIncomeScreen(),
                    ),
                  ),
                ),
                _ActionButton(
                  icon: Icons.remove_circle,
                  label: 'Add Expense',
                  color: Colors.red,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddExpenseScreen(),
                    ),
                  ),
                ),
                _ActionButton(
                  icon: Icons.bar_chart,
                  label: 'Reports',
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;
  final bool fullWidth;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: fullWidth ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: Colors.grey.shade600)),
                Text(amount,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}