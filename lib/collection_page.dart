import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchase_log/edit_product.dart';
import 'package:purchase_log/product_page.dart';
import 'package:purchase_log/products.dart';
import 'package:purchase_log/themes.dart';

import 'product.dart';

/// Class  : CollectionPage
/// Author : Devin Arena
/// Date   : 6/10/2021
/// Purpose: Collection page, a modified find page that instead allows
///          adding products and searching by name.
class CollectionPage extends StatefulWidget {
  CollectionPage({Key? key}) : super(key: key);

  _CollectionPageState createState() => _CollectionPageState();
}

/// Class  : FindPageState
/// Author : Devin Arena
/// Date   : 6/10/2021
/// Purpose: Contains the widget and state info for FindPage.
class _CollectionPageState extends State<CollectionPage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;

  /// Override method to initialize the upcController
  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController();
  }

  /// Override method to dispose the upcController
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height - 168,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
                color: Themes.containerColor(),
                borderRadius: BorderRadius.circular(20)),
            child: Container(
              margin: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: buildPage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build page method, creates and returns a list of
  /// children widgets for the find page main container.
  ///
  /// @return List<Widget> page containing inputs and buttons
  List<Widget> buildPage() {
    List<Widget> children = [];
    // title
    children.add(AutoSizeText("Lookup or Add an Item",
        maxLines: 1, style: TextStyle(fontSize: 28)));
    children.add(SizedBox(height: 20));
    // barcode button
    children.add(ElevatedButton.icon(
      icon: Icon(
        Icons.add,
        color: Colors.white,
      ),
      label: AutoSizeText("Add Product", style: TextStyle(fontSize: 24)),
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(Size(225, 0)),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10.0))),
      onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (builder) =>
                  EditProduct(product: new Product(id: -1), editing: false))),
    ));
    children
        .add(Divider(height: 75.0, thickness: 3.0, indent: 50, endIndent: 50));
    // UPC form
    children.add(Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: "Product Name",
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1))),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Name cannot be empty";
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            label: AutoSizeText("Lookup Item", style: TextStyle(fontSize: 24)),
            style: ButtonStyle(
                minimumSize: MaterialStateProperty.all<Size>(Size(225, 0)),
                padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.all(10.0))),
            onPressed: () {
              tryLookup();
            },
          )
        ],
      ),
    ));
    return children;
  }

  /// First ensures a proper UPC has been entered, if its <12 numbers
  /// a prompt asks if the user would like to correct this, before
  /// finally attempting to find a product from the entered UPC.
  Future<void> tryLookup() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate())
      return;
    Product target = Products.search(_nameController.text);
    // otherwise, show the product page to the user
    await Navigator.push(context,
        MaterialPageRoute(builder: (builder) => ProductPage(target))).then((_) {
      setState(() {});
    });
  }

  @override
  bool get wantKeepAlive => true;
}
