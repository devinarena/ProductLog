import 'package:flutter/material.dart';
import 'package:purchase_log/homepage.dart';
import 'package:purchase_log/products.dart';
import 'package:purchase_log/settings.dart';
import 'package:purchase_log/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.loadSettings();

  int loaded = await Products.loadProducts();
  print("Successfully loaded $loaded products.");

  await Products.loadCameras();

  runApp(PurchaseLog());
}

/// Class  : PurchaseLog
/// Author : Devin Arena
/// Date   : 6/7/2021
/// Purpose: Root class of the application, contains the root widget.
class PurchaseLog extends StatefulWidget {
  PurchaseLog({Key? key}) : super(key: key);

  @override
  _PurchaseLogState createState() => _PurchaseLogState();
}

class _PurchaseLogState extends State<PurchaseLog> {
  @override
  void initState() {
    super.initState();
    Settings.themes.addListener(() {
      setState(() {});
    });
  }

  /// Builds the root widget.
  ///
  /// @param context the current build context
  /// @return widget the root widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purchase Log',
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: Settings.themes.currentTheme(),
      home: HomePage(),
    );
  }
}
