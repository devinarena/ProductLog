import 'package:flutter/material.dart';
import 'package:purchase_log/homepage.dart';
import 'package:purchase_log/products.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  int loaded = await Products.loadProducts();
  print("Successfully loaded $loaded products.");

  await Products.loadCameras();

  runApp(PurchaseLog());
}

/// Class  : PurchaseLog
/// Author : Devin Arena
/// Date   : 6/7/2021
/// Purpose: Root class of the application, contains the root widget.
class PurchaseLog extends StatelessWidget {
  /// Builds the root widget.
  ///
  /// @param context the current build context
  /// @return widget the root widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purchase Log',
      theme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          primarySwatch: Colors.red,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      home: HomePage(),
    );
  }
}
