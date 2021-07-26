import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purchase_log/product_page.dart';
import 'package:purchase_log/products.dart';
import 'package:purchase_log/settings.dart';
import 'package:purchase_log/themes.dart';

import 'product.dart';

final GlobalKey<LogPageState> globalLogPageStateKey = GlobalKey();

/// Class  : LogPage
/// Author : Devin Arena
/// Date   : 6/24/2021
/// Purpose: Find page, allows you to scan/enter UPCs and
///          view products or add new ones.
class LogPage extends StatefulWidget {
  LogPage() : super(key: globalLogPageStateKey);

  LogPageState createState() => LogPageState();
}

/// Class  : LogPageState
/// Author : Devin Arena
/// Date   : 6/24/2021
/// Purpose: Contains the widget and state info for FindPage.
class LogPageState extends State<LogPage> with AutomaticKeepAliveClientMixin {
  // use French locale number formatting for the group seperator to be a space
  final format = new NumberFormat("0,00000,00000,0", "fr-FR");

  final _searchKey = GlobalKey<FormState>();

  late List<Product> products;

  late TextEditingController _searchController;

  late String _sorting;

  @override
  void initState() {
    super.initState();
    Settings.themes.addListener(() {
      setState(() {});
    });
    _searchController = new TextEditingController();
    _sorting = Settings.defaultSort;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    products = List.from(Products.products);
    _sortItems();
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildPage()),
    );
  }

  /// Build page method, creates and returns a list of
  /// children widgets for the log page main container.
  ///
  /// @return List<Widget> page containing inputs and buttons
  List<Widget> _buildPage() {
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
                    onPressed: _search,
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
                    onPressed: _showSortMenu,
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
    for (int i = 0; i < products.length; i++) {
      Product p = products[i];
      if (_searchController.text.isNotEmpty &&
          !p.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) &&
          !p.tags.contains(_searchController.text) &&
          !p.id.toString().padLeft(12, '0').contains(_searchController.text))
        continue;
      children.add(_productWidget(p));
      if (i < products.length - 1)
        children.add(Divider(
          height: 10,
          thickness: 2,
          indent: 20,
          endIndent: 20,
        ));
    }
    return children;
  }

  void rebuild() {
    setState(() {
      _search();
    });
  }

  /// Generates a product tile for each product for the
  /// main screen that allows you to view it.
  ///
  /// @return Widget a tile containing some product information
  Widget _productWidget(Product product) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.all(8),
      constraints: BoxConstraints(
        minHeight: 90,
      ),
      decoration: BoxDecoration(
        color: Themes.containerColor(),
        border: product.favorite
            ? Border.all(width: 3, color: Color.fromRGBO(192, 0, 0, 1))
            : null,
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
            fit: FlexFit.tight,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                product.hideUPC || Settings.collectionMode
                    ? SizedBox()
                    : AutoSizeText(format.format(product.id),
                        maxLines: 1, style: TextStyle(fontSize: 14)),
                if (product.manufacturer.isNotEmpty)
                  Center(
                    child: AutoSizeText(
                      "${product.manufacturer}",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                Center(
                  child: AutoSizeText(
                    "${product.name}",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          product.description.isNotEmpty
              ? Flexible(
                  child: AutoSizeText(
                    "${product.description}",
                    maxLines: 3,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                  flex: 2,
                  fit: FlexFit.tight,
                )
              : Spacer(flex: 2),
          product.rating > 0
              ? Flexible(
                  child: RichText(
                    text: TextSpan(
                      text: "${product.rating}",
                      style: TextStyle(fontSize: 20, color: Themes.yellow()),
                      children: [
                        WidgetSpan(
                            child: Icon(Icons.star,
                                size: 24, color: Themes.yellow())),
                      ],
                    ),
                  ),
                  flex: 1,
                  fit: FlexFit.tight,
                )
              : Spacer(flex: 1),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 40),
              child: ElevatedButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(0))),
                child: Center(child: Icon(Icons.arrow_right)),
                onPressed: () async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (builder) => ProductPage(product)))
                      .then((_) {
                    setState(() {});
                  });
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
  /// search criteria, either by name or tag.
  void _search() {
    setState(() {});
  }

  /// Displays a menu to the user containing sort options,
  /// when one is selected, the page rebuilds using the specified
  /// sorting selection.
  _showSortMenu() async {
    ElevatedButton okButton = ElevatedButton(
        child: Text("Okay"),
        onPressed: () {
          Navigator.of(context).pop();
          setState(() {});
        });

    AlertDialog dialog = AlertDialog(
      title: Text("Sort By"),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: Products.sortingMethods
              .map((e) => RadioListTile<String>(
                  value: e,
                  groupValue: _sorting,
                  title: Text(
                    e,
                    maxLines: 1,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onChanged: (value) {
                    setState(() => _sorting = value!);
                  }))
              .toList(),
        );
      }),
      scrollable: true,
      actions: [okButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  /// Sorts the list of products based on the user's desired sort
  /// attribute. Called before the page is built.
  void _sortItems() {
    if (_sorting == "Added") // this is the default order, do nothing
      return;
    if (_sorting == "Name") {
      products.sort((a, b) => a.name.compareTo(b.name));
    }
    if (_sorting == "ID") {
      products.sort((a, b) => a.id - b.id);
    }
    if (_sorting == "Rating") {
      products.sort((a, b) => (b.rating - a.rating).toInt());
    }
  }

  // Keep this state alive when it isn't the focused tab
  @override
  bool get wantKeepAlive => true;
}
