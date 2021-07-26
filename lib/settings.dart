import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchase_log/products.dart';
import 'package:purchase_log/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static Themes themes = Themes();

  static late String currency;
  static late String collectionName;
  static late String defaultSort;
  static late String theme;
  static late bool collectionMode;
  static late int themeColor;

  static Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currency = prefs.getString("currency") ?? "\$";
    collectionName = prefs.getString("collectionName") ?? "Product Log";
    defaultSort = prefs.getString("defaultSort") ?? "Added";
    theme = prefs.getString("theme") ?? "Device";
    collectionMode = prefs.getBool("collectionMode") ?? false;
    themeColor = prefs.getInt("themeColor") ?? Colors.red.value;
    Themes.init();
  }

  static Future<void> saveSetting(String setting, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) prefs.setBool(setting, value);
    if (value is String) prefs.setString(setting, value);
    if (value is int) prefs.setInt(setting, value);
    if (value is double) prefs.setDouble(setting, value);
  }
}

/// Class  : Settings
/// Author : Devin Arena
/// Date   : 7/6/2021
/// Purpose: Provides a way for users to change their preferences
///          about certain aspects of the application.
class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

/// Class  : SettingsPageState
/// Author : Devin Arena
/// Date   : 7/6/2021
/// Purpose: Contains widget and state info for SettingsPage.
class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final List<String> themes = ["Light", "Dark", "Device"];

  late TextEditingController _currencyController;
  late TextEditingController _collectionNameController;

  @override
  void initState() {
    super.initState();
    _currencyController = new TextEditingController(text: Settings.currency);
    _collectionNameController =
        new TextEditingController(text: Settings.collectionName);
  }

  @override
  void dispose() {
    super.dispose();
    _currencyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText("Settings",
            maxLines: 1, style: TextStyle(fontSize: 28)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: TextFormField(
                      controller: _currencyController,
                      maxLines: 1,
                      style: TextStyle(fontSize: 20),
                      autocorrect: false,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          labelText: "Currency Symbol",
                          labelStyle: TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1))),
                      onChanged: (newVal) {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          Settings.currency = newVal;
                          Products.currencyFormat = NumberFormat.currency(
                              locale: "en_US", symbol: Settings.currency);
                          Settings.saveSetting("currency", newVal);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Currency symbol cannot be empty.";
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: TextFormField(
                      controller: _collectionNameController,
                      maxLines: 1,
                      style: TextStyle(fontSize: 20),
                      autocorrect: false,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                          labelText: "Collection Name",
                          labelStyle: TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 1))),
                      onChanged: (newVal) {
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          Settings.collectionName = newVal;
                          Settings.saveSetting("collectionName", newVal);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Collection name cannot be empty.";
                        return null;
                      },
                    ),
                  ),
                  Divider(
                    height: 50,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AutoSizeText("Default Sorting: ",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: Settings.defaultSort,
                          items: Products.sortingMethods
                              .map<DropdownMenuItem<String>>((e) =>
                                  DropdownMenuItem<String>(
                                      value: e, child: Text(e)))
                              .toList(),
                          onChanged: (newVal) {
                            setState(() {
                              Settings.defaultSort = newVal!;
                              Settings.saveSetting(
                                  "defaultSort", Settings.defaultSort);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AutoSizeText("Theme: ",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: Settings.theme,
                          items: themes
                              .map<DropdownMenuItem<String>>((e) =>
                                  DropdownMenuItem<String>(
                                      value: e, child: Text(e)))
                              .toList(),
                          onChanged: (newVal) {
                            setState(() {
                              Settings.theme = newVal!;
                              Settings.saveSetting("theme", Settings.theme);
                              Settings.themes.setTheme(Settings.theme);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _showColorPicker,
                    child: AutoSizeText(
                      "Theme Color",
                      maxLines: 1,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Divider(
                    height: 50,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.6,
                    child: Tooltip(
                      message: "Hides all UPCs and changes lookups to by name",
                      child: CheckboxListTile(
                        value: Settings.collectionMode,
                        contentPadding: EdgeInsets.all(0),
                        title: AutoSizeText("Collection Mode",
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 20,
                                color: Themes.isDark()
                                    ? Colors.white
                                    : Colors.black)),
                        onChanged: (newVal) {
                          setState(() {
                            Settings.collectionMode = newVal!;
                            Settings.saveSetting("collectionMode", newVal);
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Color(Settings.themeColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  AutoSizeText(
                    "Collection mode hides all UPCs and changes lookups to by UPC to by name",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: _showDatabaseManager,
                      child: const AutoSizeText("Manage Database",
                          maxLines: 1, style: TextStyle(fontSize: 20))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the color picker dialog. Allows users to confirm a color
  /// change which will change the theme color throughout the entire application.
  void _showColorPicker() {
    AlertDialog dialog = AlertDialog(
      title: Text("Pick a Color", maxLines: 1),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: Color(Settings.themeColor),
          onColorChanged: (Color newVal) {
            Settings.themeColor = newVal.value;
          },
          showLabel: true,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Settings.saveSetting("themeColor", Settings.themeColor);
              Themes.init();
              Settings.themes.setTheme(Settings.theme);
            },
            child: Text("Finished", maxLines: 1))
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  /// Opens a dialog containing options for maintaining the user database.
  /// Allows users to either back up or import a new database.
  void _showDatabaseManager() {
    ElevatedButton okButton = ElevatedButton(
        child: Text("Close"),
        onPressed: () {
          Navigator.of(context).pop();
          setState(() {});
        });

    AlertDialog dialog = AlertDialog(
      title: Center(
          child: Text(
        "Manage Database",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      )),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Products.saveDB(context),
            child: const FittedBox(
              fit: BoxFit.contain,
              child: const Text("Backup",
                  maxLines: 1, style: TextStyle(fontSize: 20)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Products.importDB(context),
            child: const FittedBox(
              fit: BoxFit.contain,
              child: const Text("Import",
                  maxLines: 1, style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
      scrollable: true,
      actions: [okButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }
}
