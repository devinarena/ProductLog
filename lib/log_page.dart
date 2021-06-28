import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purchase_log/product_page.dart';
import 'package:purchase_log/products.dart';

import 'product.dart';

/// Class  : LogPage
/// Author : Devin Arena
/// Date   : 6/24/2021
/// Purpose: Find page, allows you to scan/enter UPCs and
///          view products or add new ones.
class LogPage extends StatefulWidget {
  LogPage({Key? key}) : super(key: key);

  _LogPageState createState() => _LogPageState();
}

/// Class  : LogPageState
/// Author : Devin Arena
/// Date   : 6/24/2021
/// Purpose: Contains the widget and state info for FindPage.
class _LogPageState extends State<LogPage> with AutomaticKeepAliveClientMixin {
  // use French locale number formatting for the group seperator to be a space
  final format = new NumberFormat("0,00000,00000,0", "fr-FR");

  final _searchKey = GlobalKey<FormState>();

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: buildPage()),
    );
  }

  /// Build page method, creates and returns a list of
  /// children widgets for the log page main container.
  ///
  /// @return List<Widget> page containing inputs and buttons
  List<Widget> buildPage() {
    List<Widget> children = [];
    children.add(
      Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _searchKey,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: TextFormField(
                    controller: _searchController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: "Search by name or tag",
                      labelStyle: TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(0)),
                    ),
                    child: Icon(Icons.search),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(0)),
                    ),
                    child: Icon(Icons.sort),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    for (int i = 0; i < Products.products.length; i++) {
      Product p = Products.products[i];
      if (_searchController.text.isNotEmpty &&
          !p.name.contains(_searchController.text) &&
          !p.tags.contains(_searchController.text)) continue;
      children.add(productWidget(p));
      if (i < Products.products.length - 1)
        children.add(Divider(
          height: 10,
          thickness: 2,
          indent: 20,
          endIndent: 20,
        ));
    }
    return children;
  }

  /// Generates a product tile for each product for the
  /// main screen that allows you to view it.
  ///
  /// @return Widget a tile containing some product information
  Widget productWidget(Product product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.all(10),
      constraints: BoxConstraints(
        minHeight: 90,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  format.format(product.id),
                  maxLines: 1,
                  style: TextStyle(fontSize: 14),
                ),
                Center(
                  child: AutoSizeText(
                    "${product.name}",
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              "${product.description}",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
            flex: 2,
            fit: FlexFit.loose,
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                text: "${product.rating}",
                style: TextStyle(fontSize: 20, color: Colors.yellow[500]),
                children: [
                  WidgetSpan(
                      child: Icon(Icons.star,
                          size: 24, color: Colors.yellow[300])),
                ],
              ),
            ),
            flex: 2,
            fit: FlexFit.loose,
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 40),
              child: ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(0))),
                child: Center(child: Icon(Icons.arrow_right)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => ProductPage(product)));
                },
              ),
            ),
            flex: 1,
            fit: FlexFit.loose,
          ),
        ],
      ),
    );
  }

  /// Rebuilds the page to show only widgets that match the
  /// search criteria, either by name or TODO: tag.
  void search() {}

  // Keep this state alive when it isn't the focused tab
  @override
  bool get wantKeepAlive => true;
}
