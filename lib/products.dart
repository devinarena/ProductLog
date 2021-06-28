import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:purchase_log/product.dart';
import 'package:sqflite/sqflite.dart';

/// Class  : Products
/// Author : Devin Arena
/// Date   : 6/18/2021
/// Purpose: Products will be stored in a database.
///          This class handles database CRUD operations.
class Products {
  // list of all products created
  static List<Product> products = [];

  // camera used to take pictures
  static List<CameraDescription>? cameras;

  // database information
  static final _dbName = "productlog.db";
  static final _dbVersion = 1;

  static final _productTable = "products";

  // private constructor
  Products._privateConstructor();
  static final _instance = Products._privateConstructor();

  // database instance
  static Database? _db;

  // external getter for database object
  Future<Database> get db async {
    if (_db != null) return _db!;

    // Directory documents = await getApplicationDocumentsDirectory();
    // String path = join(documents.path, _dbName);
    // deleteDatabase(path);

    _db = await _initDatabase();
    return _db!;
  }

  /// Initializes the database if it has not been already
  ///
  /// @return Future<Database> the created database object
  Future<Database> _initDatabase() async {
    Directory documents = await getApplicationDocumentsDirectory();
    String path = join(documents.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  /// Callback that executes once the database is created.
  ///
  /// @param db Database the current database
  /// @param version Integer the version number
  Future _onCreate(Database db, int version) async {
    print("Creating table");
    await db.execute(
        """create table $_productTable(ID INTEGER PRIMARY KEY NOT NULL, 
        NAME TEXT NOT NULL, DESCRIPTION TEXT, QUANTITY INTEGER, PRICE DOUBLE,
        SOURCE TEXT, IMAGE BLOB, RATING DOUBLE, SITELINK TEXT, FAVORITE BOOL,
        TAGS TEXT)""");
  }

  /// Initially load the products into the product list to be
  /// displayed in the log tab and to utilize when searching
  /// for a product using its barcode/UPC.
  ///
  /// @return Integer the number of products loaded from the database
  static Future<int> loadProducts() async {
    Database db = await _instance.db;

    // iterate over every row in the db and add a corresponding product
    for (Map<String, dynamic> row in await db.query(_productTable)) {
      products.add(Product.deserialize(row));
    }

    products.add(new Product(
        id: 073390014636,
        name: "Mentos Gum",
        description:
            "Yummy gummy. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        rating: 4.5,
        quantity: 1,
        price: 3.99,
        source: "Publix",
        siteLink: "https://www.google.com/",
        favorite: true,
        tags: "food,candy"));

    // return the number of products added
    return products.length;
  }

  /// Adds a product to the database, simply serializes and inserts.
  ///
  /// @param product Product the product to add to the database
  static void _addProductDB(Product product) async {
    Database db = await _instance.db;

    int id = await db.insert(_productTable, product.serialize());
    print("Added product with id $id to db");
  }

  /// Deletes a product from the database based on its ID.
  ///
  /// @param product Product the product to remove from the database
  static void _deleteProductDB(Product product) async {
    Database db = await _instance.db;

    int id = await db
        .delete(_productTable, where: "ID = ?", whereArgs: [product.id]);
    print("Deleted product with id $id from db");
  }

  /// Updates a product in the database given a new product.
  ///
  /// @param product Product the product to replace in DB (changes based on ID)
  static void _updateProduct(Product product) async {
    Database db = await _instance.db;

    int rows = await db.update(_productTable, product.serialize(),
        where: "ID = ?", whereArgs: [product.id]);
    print("Updated $rows rows in db");
  }

  /// Looks a product up based on its Universal Product Code.
  ///
  /// @param upc Integer the 12 digit Universal Product Code
  /// @return a corresponding product or null
  static Product? lookup(int upc) {
    Product? found;
    products.forEach((product) {
      if (product.id == upc) {
        found = product;
        return;
      }
    });
    return found;
  }

  /// Adds the given product to the local database.
  /// Allows products to be saved persistently.
  ///
  /// @param product Product the product to add to the database
  static void addProduct(Product product) {
    _addProductDB(product);
    products.add(product);
  }

  /// Deletes a given product from the local database.
  ///
  /// @param product Product the product to remove from the database
  static void deleteProduct(Product product) {
    _deleteProductDB(product);
    products.remove(product);
  }

  /// Update method wrapper, simply updates the product in the database.
  ///
  /// @param product Product the product to update
  static void updateProduct(Product product) {
    _updateProduct(product);
  }

  /// Loads the cameras to be used to take pictures of products
  static Future<void> loadCameras() async {
    cameras = await availableCameras();
  }

  /// Cleanup any resources.
  static void dispose() {
    products.clear();
    cameras!.clear();
    if (_db != null) _db!.close();
  }
}
