import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:purchase_log/product.dart';
import 'package:purchase_log/settings.dart';
import 'package:purchase_log/test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:string_similarity/string_similarity.dart';

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

  // other information
  static List<String> sortingMethods = ["Added", "Name", "ID", "Rating"];

  // database information
  static final dbName = "productlog.db";
  static final _dbVersion = 1;

  static final _productTable = "products";

  // collection statistics
  static int numProducts = 0;
  static int totalProducts = 0;
  static int numFavorites = 0;
  static double collectionCost = 0;
  static double mostExpensive = 0;
  static double leastExpensive = double.infinity;
  static double averageCost = 0;
  static double bestRating = 0;
  static double worstRating = 5.1;
  static double averageRating = 0;

  // formatting
  static final dateFormat = new DateFormat("MM/dd/yyyy");
  // use French locale number formatting for the group seperator to be a space
  static final upcFormat = new NumberFormat("0,00000,00000,0", "fr-FR");
  // for currency
  static NumberFormat currencyFormat =
      NumberFormat.currency(locale: "en_US", symbol: Settings.currency);

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
    String path = join(documents.path, dbName);
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
        NAME TEXT NOT NULL, MANUFACTURER TEXT, DESCRIPTION TEXT, QUANTITY INTEGER, 
        PRICE DOUBLE, SOURCE TEXT, IMAGE BLOB, RATING DOUBLE, SITELINK TEXT, FAVORITE BOOL,
        HIDE_UPC BOOL, PURCHASE_DATE TEXT, TAGS TEXT)""");
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
      print(products.last);
    }

    products.add(new Product(
        id: 073390014636,
        image: base64.decode(mentosGum),
        name: "Minty Gum",
        manufacturer: "Mentos",
        description:
            "Yummy gummy. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        rating: 4.5,
        quantity: 1,
        price: 3.99,
        source: "Publix",
        siteLink: "https://www.google.com/",
        favorite: true,
        hideUPC: false,
        purchaseDate: DateTime.now(),
        tags: "food,candy"));

    // update product stats
    updateStats();

    // return the number of products added
    return products.length;
  }

  /// Adds a product to the database, simply serializes and inserts.
  ///
  /// @param product Product the product to add to the database
  static void _addProductDB(Product product) async {
    Database db = await _instance.db;

    late Map<String, dynamic> serialized;
    if (product.id >= 0)
      serialized = product.serialize();
    else
      serialized = product.serializeWithoutID();
    int id = await db.insert(_productTable, serialized);
    product.id = id;
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

  /// Allows users to backup their database file.
  static void saveDB(BuildContext context) async {
    Directory documents = await getApplicationDocumentsDirectory();
    String path = join(documents.path, Products.dbName);
    final params = SaveFileDialogParams(sourceFilePath: path);
    final filePath = await FlutterFileDialog.saveFile(params: params);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: AutoSizeText(
        "Saved file $filePath successfully!",
        maxLines: 2,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
      backgroundColor: Colors.grey[900],
    ));
  }

  static void importDB(BuildContext context) async {
    final params = OpenFileDialogParams();
    final filePath = await FlutterFileDialog.pickFile(params: params);
    if (filePath == null) return;
    if (!filePath.endsWith(".db")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const AutoSizeText(
          "Failed to load file. It may be corrupted or the incorrect format.",
          maxLines: 2,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ));
      return;
    }

    Database db = await openDatabase(filePath);
    int amount = 0;
    // iterate over every row in the db and add a corresponding product
    for (Map<String, dynamic> row in await db.query(_productTable)) {
      products.add(Product.deserialize(row));
      print(products.last);
      amount++;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: AutoSizeText(
        "Successfully imported $amount products.",
        maxLines: 2,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
      backgroundColor: Colors.grey[900],
    ));
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

  /// Looks a product up based on its name. Returns the closest match.
  ///
  /// @param name String the product name or name fragment
  /// @return the product with the closest match to name
  static Product search(String name) {
    List<String> names = products.map<String>((e) => e.name).toList();
    return products[name.bestMatch(names).bestMatchIndex];
  }

  /// Adds the given product to the local database.
  /// Allows products to be saved persistently.
  ///
  /// @param product Product the product to add to the database
  static void addProduct(Product product) {
    _addProductDB(product);
    products.add(product);
    updateStats();
  }

  /// Deletes a given product from the local database.
  ///
  /// @param product Product the product to remove from the database
  static void deleteProduct(Product product) {
    _deleteProductDB(product);
    products.remove(product);
    updateStats();
  }

  /// Update method wrapper, simply updates the product in the database.
  ///
  /// @param product Product the product to update
  static void updateProduct(Product product) {
    _updateProduct(product);
    updateStats();
  }

  /// Updates the collection statistics.
  static void updateStats() {
    numProducts = products.length;
    int rated = 0;
    int costed = 0;
    averageRating = 0;
    collectionCost = 0;
    for (Product p in products) {
      totalProducts += min(p.quantity, 1);
      if (p.favorite) numFavorites++;
      if (p.price > 0) {
        collectionCost += p.price;
        if (p.price > mostExpensive) mostExpensive = p.price;
        if (p.price < leastExpensive) leastExpensive = p.price;
        costed++;
      }
      if (p.rating > bestRating) bestRating = p.rating;
      if (p.rating > 0 && p.rating < worstRating) worstRating = p.rating;
      if (p.rating > 0) {
        averageRating += p.rating;
        rated++;
      }
    }
    averageCost = collectionCost / costed;
    averageRating /= rated;
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
