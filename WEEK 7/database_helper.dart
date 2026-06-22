import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Income table
    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');

    // Expense table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');

    // Budget table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        limit_amount REAL NOT NULL,
        month TEXT NOT NULL
      )
    ''');

    // Goals table
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target REAL NOT NULL,
        saved REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ─── INCOME CRUD ──────────────────────────────

  Future<int> insertIncome(Map<String, dynamic> income) async {
    final db = await database;
    return await db.insert('incomes', income);
  }

  Future<List<Map<String, dynamic>>> getAllIncomes() async {
    final db = await database;
    return await db.query('incomes', orderBy: 'date DESC');
  }

  Future<int> updateIncome(Map<String, dynamic> income) async {
    final db = await database;
    return await db.update(
      'incomes',
      income,
      where: 'id = ?',
      whereArgs: [income['id']],
    );
  }

  Future<int> deleteIncome(int id) async {
    final db = await database;
    return await db.delete(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalIncome() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT SUM(amount) as total FROM incomes');
    return (result.first['total'] as double?) ?? 0.0;
  }

  // ─── EXPENSE CRUD ─────────────────────────────

  Future<int> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.insert('expenses', expense);
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  Future<int> updateExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT SUM(amount) as total FROM expenses');
    return (result.first['total'] as double?) ?? 0.0;
  }

  // ─── GOALS CRUD ───────────────────────────────

  Future<int> insertGoal(Map<String, dynamic> goal) async {
    final db = await database;
    return await db.insert('goals', goal);
  }

  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final db = await database;
    return await db.query('goals', orderBy: 'date DESC');
  }

  Future<int> updateGoal(Map<String, dynamic> goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal,
      where: 'id = ?',
      whereArgs: [goal['id']],
    );
  }

  Future<int> deleteGoal(int id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}