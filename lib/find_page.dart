import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Class  : FindPage
/// Author : Devin Arena
/// Date   : 6/10/2021
/// Purpose: Find page, allows you to scan/enter UPCs and
///          view products or add new ones.
class FindPage extends StatefulWidget {
  _FindPageState createState() => _FindPageState();
}

/// Class  : FindPageState
/// Author : Devin Arena
/// Date   : 6/10/2021
/// Purpose: Contains the widget and state info for FindPage.
class _FindPageState extends State<FindPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey[700],
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buildPage(),
          )
        ),
      ),
    );
  }

  buildPage() {
    List<Widget> children = [];
    children.add(AutoSizeText("Lookup or Add an Item", style: TextStyle(fontSize: 28)));
    children.add(ElevatedButton(
      child: AutoSizeText("Scan Barcode", style: TextStyle(fontSize: 20)),
      onPressed: () => {},
    ));
    return children;
  }
}
