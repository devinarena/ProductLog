import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          title: AutoSizeText("Purchase Log",
              maxLines: 1, style: TextStyle(fontSize: 28)),
          centerTitle: true,
          bottom: TabBar(
            controller: _controller,
            tabs: tabs,
            labelStyle: TextStyle(fontSize: 24),
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: [FindPage(), LogPage()],
        ),
      ),
    );
  }
}
