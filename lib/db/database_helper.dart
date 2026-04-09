import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_mastery/models/product.model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('products.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        title TEXT,
        price REAL,
        description TEXT,
        category TEXT,
        image TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY,
        title TEXT,
        price REAL,
        image TEXT,
        quantity INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT
      )
    ''');
  }

  Future<void> insertProducts(List<Product> products) async {
    final db = await instance.database;
    final batch = db.batch();

    batch.delete('products');

    for (var product in products) {
      batch.insert('products', product.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Product>> getLocalProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<void> addToCart(Product product) async {
    final db = await instance.database;

    final List<Map<String, dynamic>> existing = await db.query(
      'cart',
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (existing.isNotEmpty) {
      int newQty = (existing.first['quantity'] as int) + 1;
      await db.update(
        'cart',
        {'quantity': newQty},
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } else {
      await db.insert('cart', {
        'id': product.id,
        'title': product.title,
        'price': product.price,
        'image': product.image,
        'quantity': 1,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await instance.database;
    return await db.query('cart');
  }

  Future<void> removeFromCart(int id) async {
    final db = await instance.database;
    await db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCartQuantity(int id, int quantity) async {
    final db = await instance.database;
    if (quantity <= 0) {
      await removeFromCart(id);
    } else {
      await db.update(
        'cart',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> clearCart() async {
    final db = await instance.database;
    await db.delete('cart');
  }

  Future<void> saveUserToLocal(String name, String email) async {
    final db = await instance.database;
    await db.insert('users', {'name': name, 'email': email});
  }

  Future<Map<String, dynamic>?> getLocalUser() async {
    final db = await instance.database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }
}
