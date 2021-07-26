import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:purchase_log/edit_product.dart';
import 'package:purchase_log/product_page.dart';
import 'package:purchase_log/products.dart';
import 'package:purchase_log/themes.dart';

import 'product.dart';

/// Class  : FindPage
/// Author : Devin Arena
/// Date   : 6/10/2021
/// Purpose: Find page, allows you to scan/enter UPCs and
///          view products or add new ones.
class FindPage extends StatefulWidget {
  final Function() updateHomepage;
  final Function() updateLogPage;
  FindPage(
      {Key? key, required this.updateHomepage, required this.updateLogPage})
      : super(key: key);

  _FindPageState createState() => _FindPageState();
}

/// Class  : FindPageState
/// Author : Devin Arena
/// Date   : 6/10/2021
/// Purpose: Contains the widget and state info for FindPage.
class _FindPageState extends State<FindPage>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final RegExp upcRegex = RegExp(r'^[0-9]{1,12}$');
  TextEditingController? _upcController;

  /// Override method to initialize the upcController
  @override
  void initState() {
    super.initState();
    _upcController = new TextEditingController();
  }

  /// Override method to dispose the upcController
  @override
  void dispose() {
    super.dispose();
    _upcController!.dispose();
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
                children: buildPage(),
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
        Icons.qr_code_scanner,
        color: Colors.white,
      ),
      label: AutoSizeText("Scan Barcode", style: TextStyle(fontSize: 24)),
      style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(Size(225, 0)),
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10.0))),
      onPressed: () {
        openScanner();
      },
    ));
    children
        .add(Divider(height: 75.0, thickness: 3.0, indent: 50, endIndent: 50));
    // UPC form
    children.add(Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _upcController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: "(~12) digit UPC",
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1))),
            validator: (value) {
              if (value == null ||
                  value.length > 12 ||
                  !upcRegex.hasMatch(value))
                return "UPC must be between 1 and 12 numbers.";
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
            onPressed: () async {
              await tryLookup();
            },
          )
        ],
      ),
    ));
    return children;
  }

  /// Opens the barcode scanner to allow
  /// users to scan their desired barcode.
  void openScanner() async {
    // utilize the barcode scanner package
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#cc6666', 'Cancel', true, ScanMode.BARCODE);
      for (int i = 0; i < 100; i++) print(barcodeScanRes);
    } on PlatformException {
      // if it fails, do not continue
      return;
    }

    // this method is async, so if the user closes the scanner
    // while this function is running, do not conitnue
    if (!mounted) return;

    // update the state to change the text of the UPC box to our found barcode
    if (barcodeScanRes != "-1") {
      setState(() {
        _upcController!.text = barcodeScanRes;
        tryLookup();
      });
    }
  }

  /// First ensures a proper UPC has been entered, if its <12 numbers
  /// a prompt asks if the user would like to correct this, before
  /// finally attempting to find a product from the entered UPC.
  Future<void> tryLookup() async {
    // if a invalid UPC is entered, do nothing yet
    if (!_formKey.currentState!.validate()) return;
    // attempt to find the target
    await findProduct().then((value) {
      if (!value) {
        if (_upcController!.text.length < 12)
          showUPCShortDialog();
        else
          showCreateDialog();
      }
    });
  }

  /// Looks up and returns a product if found.
  /// Uses the value from the UPC text field.
  ///
  /// @param context BuildContext the current context to push to
  /// @return bool if the product was found or not
  Future<bool> findProduct() async {
    Product? target = Products.lookup(int.parse(_upcController!.text));
    // if a product doesn't exist, ask to create
    if (target == null) {
      return false;
    }
    widget.updateHomepage();
    // otherwise, show the product page to the user
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (builder) => ProductPage(target)))
        .then((_) {
      widget.updateLogPage();
    });
    return true;
  }

  /// Displays a dialog asking the user if they would like to create a
  /// product, called when a UPC is looked up that has no corresponding
  /// entry in the current database.
  ///
  /// @param context BuildContext the context to use
  void showCreateDialog() {
    ElevatedButton noButton = ElevatedButton(
        child: Text("No"),
        onPressed: () {
          Navigator.of(context).pop();
        });
    ElevatedButton yesButton = ElevatedButton(
        child: Text("Yes"),
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => EditProduct(
                      product: Product(id: int.parse(_upcController!.text)),
                      editing: false)));
        });

    AlertDialog dialog = AlertDialog(
      title: Text("Product Not Found"),
      content: Text("Would you like to add this product?"),
      actions: [yesButton, noButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  /// Displays a dialog telling the user the UPC they entered is
  /// less than 12 characters and asks if they would like to convert
  /// the entered UPC to 12 characters in length.
  ///
  /// @param context BuildContext the context to use
  void showUPCShortDialog() {
    ElevatedButton noButton = ElevatedButton(
        child: Text("No"),
        onPressed: () {
          Navigator.of(context).pop();
          showCreateDialog();
        });
    ElevatedButton yesButton = ElevatedButton(
        child: Text("Yes"),
        onPressed: () {
          setState(() {
            _upcController!.text = _upcController!.text.padLeft(12, '0');
          });
          Navigator.of(context).pop();
          showCreateDialog();
        });

    AlertDialog dialog = AlertDialog(
      title: Text("UPC Too Short"),
      content: Text(
          "The entered UPC is shorter than 12 numbers, do you want to convert to a standard 12 digit UPC?"),
      actions: [yesButton, noButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  @override
  bool get wantKeepAlive => true;
}
