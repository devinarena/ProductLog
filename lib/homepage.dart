import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchase_log/collection_page.dart';
import 'package:purchase_log/edit_product.dart';
import 'package:purchase_log/product.dart';
import 'package:purchase_log/products.dart';
import 'package:purchase_log/settings.dart';
import 'package:purchase_log/themes.dart';

import 'find_page.dart';
import 'log_page.dart';

/// Class  : HomePage
/// Author : Devin Arena
/// Date   : 6/7/2021
/// Purpose: Home page for the application, contains tabs
///          for logging and viewing purchases.
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

/// Class  : HomePageState
/// Author : Devin Arena
/// Date   : 6/7/2021
/// Purpose: Contains state information for the homepage.
class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  final LogPage logPage = LogPage();

  // A list of every tab.
  final List<Tab> tabs = <Tab>[
    Tab(text: 'Find'),
    Tab(text: 'Log'),
  ];

  /// Simply to init the tabcontroller for the home page.
  @override
  void initState() {
    super.initState();
    _controller = new TabController(vsync: this, length: tabs.length);
    _controller.addListener(() {
      setState(() {});
    });
  }

  /// Dispose of the tabcontroller.
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  /// Creates the home page widget.
  ///
  /// @param context current BuildContext
  /// @return the homepage widget
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: AutoSizeText(Settings.collectionName,
              maxLines: 1, style: TextStyle(fontSize: 28)),
          centerTitle: true,
          bottom: TabBar(
            controller: _controller,
            tabs: tabs,
            labelStyle: TextStyle(fontSize: 24),
            indicatorColor: Color(Settings.themeColor),
          ),
          actions: [
            IconButton(
              onPressed: () async => await Navigator.push(context,
                      MaterialPageRoute(builder: (builder) => SettingsPage()))
                  .then((_) {
                setState(() {});
              }),
              icon: Icon(Icons.settings),
            )
          ],
        ),
        body: TabBarView(
          controller: _controller,
          children: [
            Settings.collectionMode
                ? CollectionPage()
                : FindPage(
                    updateHomepage: _gotoLogPage,
                    updateLogPage: () {
                      if (globalLogPageStateKey.currentState != null)
                        globalLogPageStateKey.currentState!.rebuild();
                    },
                  ),
            logPage
          ],
        ),
        floatingActionButton: _fab(),
      ),
    );
  }

  /// Moves the current tab to the log page. Does this when a product is
  /// directly searched for so values get updated and for ease of use.
  void _gotoLogPage() {
    _controller.index = 1;
  }

  /// Creates the floating action button widget, on the first tab its
  /// an add button to add a new product. The second page its a button
  /// to display collection statistics.
  FloatingActionButton _fab() {
    if (_controller.index == 0 && !_controller.indexIsChanging) {
      return FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) =>
                    EditProduct(product: Product(id: -1), editing: false))),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(Settings.themeColor),
      );
    }
    return FloatingActionButton(
      onPressed: showStatistics,
      child: Icon(Icons.bar_chart, color: Colors.white),
      backgroundColor: Color(Settings.themeColor),
    );
  }

  /// Opens the statistics dialog to allow users to view their collection statistics.
  void showStatistics() {
    ElevatedButton okButton = ElevatedButton(
        child: Text("Close"),
        onPressed: () {
          Navigator.of(context).pop();
          setState(() {});
        });

    AlertDialog dialog = AlertDialog(
      title: Center(
          child: Text(
        "Collection Statistics",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      )),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          stat("Unique Products", Products.numProducts.toString()),
          stat("Total Products", Products.totalProducts.toString()),
          stat("Favorites", Products.numFavorites.toString()),
          stat("Total Cost",
              Products.currencyFormat.format(Products.collectionCost)),
          stat("Average Cost",
              Products.currencyFormat.format(Products.averageCost)),
          stat("Most Expensive",
              Products.currencyFormat.format(Products.mostExpensive)),
          stat("Least Expensive",
              Products.currencyFormat.format(Products.mostExpensive)),
          customStat(
            "Best Rating",
            RichText(
              text: TextSpan(
                text: Products.bestRating.toString(),
                style: TextStyle(color: Themes.yellow()),
                children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.star, color: Themes.yellow())),
                ],
              ),
            ),
          ),
          customStat(
            "Worst Rating",
            RichText(
              text: TextSpan(
                text: Products.worstRating.toString(),
                style: TextStyle(color: Themes.yellow()),
                children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.star, color: Themes.yellow())),
                ],
              ),
            ),
          ),
          customStat(
            "Average Rating",
            RichText(
              text: TextSpan(
                text: Products.averageRating.toString(),
                style: TextStyle(color: Themes.yellow()),
                children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.star, color: Themes.yellow())),
                ],
              ),
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

  /// Builds a statistic widget to show a statistic in the dialog.
  ///
  /// @param name the name of the statistic
  /// @param value the value of the statistic
  /// @return Row widget containing stat text
  Row stat(String name, String value) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 25,
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.fitHeight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Text(
                  name,
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        Spacer(),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 25,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: Text(
                  value,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Builds a statistic widget to show a statistic in the dialog.
/// Uses a custom child for the statistic value.
///
/// @param name the name of the statistic
/// @param value the value widget of the statistic
/// @return Row widget containing stat text
Row customStat(String name, Widget value) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        flex: 5,
        child: SizedBox(
          height: 25,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.fitHeight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Text(
                name,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
      Spacer(),
      Expanded(
        flex: 2,
        child: SizedBox(
          height: 25,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.centerRight,
            child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0), child: value),
          ),
        ),
      ),
    ],
  );
}
