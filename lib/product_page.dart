import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purchase_log/edit_product.dart';
import 'package:purchase_log/product.dart';
import 'package:purchase_log/products.dart';
import 'package:purchase_log/settings.dart';
import 'package:purchase_log/themes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:checkdigit/checkdigit.dart';

class ProductPage extends StatefulWidget {
  final Product _product;

  ProductPage(this._product, {Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late final String _fullName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!widget._product.hideUPC &&
          !upcA.validate(widget._product.id.toString().padLeft(12, '0')))
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: AutoSizeText(
            "UPC is not valid and cannot generate a barcode (to stop seeing this, check 'Hide UPC' under other info)",
            maxLines: 3,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          backgroundColor: Colors.grey[900],
        ));
    });
    _fullName = (widget._product.manufacturer.isNotEmpty
            ? widget._product.manufacturer + " "
            : "") +
        widget._product.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.containerColor(),
      appBar: AppBar(
        title: AutoSizeText("$_fullName",
            maxLines: 1, style: TextStyle(fontSize: 28)),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                // just open EditProduct page and update when it closes
                await Navigator.push(
                    context,
                    (MaterialPageRoute(
                        builder: (builder) => EditProduct(
                            product: widget._product, editing: true))));
                setState(() {});
              },
              icon: Icon(Icons.edit, color: Colors.white)),
          IconButton(
              onPressed: deletePrompt,
              icon: Icon(Icons.delete, color: Themes.isDark() ? Colors.red : Colors.white)),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buildPage(),
        ),
      ),
    );
  }

  /// Builds the product's page based on what information is provided.
  ///
  /// @return List<Widget> the product page
  List<Widget> buildPage() {
    List<Widget> page = [];
    if (widget._product.image != null) {
      page.add(FractionallySizedBox(
          widthFactor: 0.8,
          child: Container(
            child: Image.memory(widget._product.image!),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 3,
                    color: widget._product.favorite
                        ? Color.fromRGBO(192, 0, 0, 1)
                        : Colors.black)),
          )));
    }
    page.add(SizedBox(height: 20));
    if (widget._product.manufacturer.isNotEmpty)
      page.add(AutoSizeText("${widget._product.manufacturer}",
          maxLines: 1,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
    page.add(AutoSizeText("${widget._product.name}",
        maxLines: 2,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)));
    page.add(SizedBox(height: 20));
    if (widget._product.description.isNotEmpty) {
      page.add(AutoSizeText("${widget._product.description}",
          maxLines: null, style: TextStyle(fontSize: 20)));
      page.add(SizedBox(height: 20));
    }
    if (widget._product.quantity > 0 || widget._product.price > 0) {
      page.add(Divider(
          thickness: 3,
          height: 40,
          indent: 50,
          endIndent: 50,
          color: Colors.grey[400]));
      page.add(AutoSizeText("Purchase Details",
          maxLines: 1,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)));
      page.add(SizedBox(height: 20));
    }
    if (widget._product.purchaseDate != null) {
      page.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText("First Purchase",
              maxLines: 1,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          AutoSizeText(
              DateFormat("MM/dd/yyyy").format(widget._product.purchaseDate!),
              maxLines: 1,
              style: TextStyle(fontSize: 20)),
        ],
      ));
    }
    if (widget._product.source.isNotEmpty) {
      page.add(SizedBox(height: 20));
      page.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText("Source",
              maxLines: 1,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          AutoSizeText(widget._product.source,
              maxLines: 1, style: TextStyle(fontSize: 20)),
        ],
      ));
    }
    if (widget._product.quantity > 0) {
      page.add(SizedBox(height: 20));
      page.add(Divider(thickness: 1, height: 0, color: Colors.grey[600]));
      page.add(SizedBox(height: 20));
      page.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText("Quantity",
              maxLines: 1,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          AutoSizeText(widget._product.quantity.toString(),
              maxLines: 1, style: TextStyle(fontSize: 20)),
        ],
      ));
      page.add(SizedBox(height: 20));
    }
    if (widget._product.price > 0) {
      page.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText("Price",
              maxLines: 1,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          AutoSizeText(Products.currencyFormat.format(widget._product.price),
              maxLines: 1, style: TextStyle(fontSize: 20)),
        ],
      ));
      page.add(SizedBox(height: 20));
    }
    if (widget._product.quantity > 0 && widget._product.price > 0) {
      page.add(Divider(thickness: 1, height: 0, color: Colors.grey[600]));
      page.add(SizedBox(height: 20));
      page.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoSizeText("Total",
              maxLines: 1,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          AutoSizeText(Products.currencyFormat.format(widget._product.price),
              maxLines: 1, style: TextStyle(fontSize: 20)),
        ],
      ));
    }
    page.add(SizedBox(height: 10));
    page.add(Divider(
        thickness: 3,
        height: 40,
        indent: 50,
        endIndent: 50,
        color: Colors.grey[400]));
    if (widget._product.rating > 0) {
      page.add(
        RichText(
          text: TextSpan(
            text: "${widget._product.rating}",
            style: TextStyle(fontSize: 28, color: Themes.yellow()),
            children: [
              WidgetSpan(
                  child: Icon(Icons.star, size: 36, color: Themes.yellow())),
            ],
          ),
        ),
      );
      page.add(SizedBox(height: 20));
    }
    page.add(Icon(
      widget._product.favorite ? Icons.favorite : Icons.favorite_border,
      color: Colors.red,
      size: 64,
    ));
    page.add(SizedBox(height: 20));
    if (widget._product.siteLink.isNotEmpty) {
      page.add(ElevatedButton(
          style: ButtonStyle(
              padding:
                  MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10))),
          child: AutoSizeText("Visit Site", style: TextStyle(fontSize: 24)),
          onPressed: sitePrompt));
      page.add(SizedBox(height: 20));
    }
    if (widget._product.tags.isNotEmpty) {
      List<String> tags = widget._product.tags.split(",");
      page.add(AutoSizeText("Tags",
          maxLines: 1,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline)));
      page.add(SizedBox(height: 20));
      for (int i = 0; i < tags.length; i += 5) {
        page.add(Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (index) {
            if (i + index >= tags.length) return null;
            return AutoSizeText(
              tags[i + index],
              maxLines: 1,
              style: TextStyle(fontSize: 18),
            );
          }).where((element) => element != null).toList().cast(),
        ));
      }
      page.add(SizedBox(height: 20));
    }
    if (widget._product.hideUPC || Settings.collectionMode) return page;
    if (!upcA.validate(widget._product.id.toString().padLeft(12, '0'))) {
      return page;
    }
    page.add(Divider(
        thickness: 3,
        height: 0,
        indent: 50,
        endIndent: 50,
        color: Colors.grey[400]));
    page.add(SizedBox(height: 20));
    page.add(AutoSizeText("UPC",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
    page.add(
      Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(5)),
        child: BarcodeWidget(
          barcode: Barcode.upcA(),
          data: widget._product.id.toString().padLeft(12, '0'),
          color: Colors.black,
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
    return page;
  }

  /// Asks the user if they wish to really delete a product,
  /// called when a user presses the delete button in the top bar.
  void deletePrompt() {
    ElevatedButton noButton = ElevatedButton(
        child: Text("No"),
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color?>(Colors.grey[600])),
        onPressed: () {
          Navigator.of(context).pop();
        });
    ElevatedButton yesButton = ElevatedButton(
        child: Text("Yes"),
        onPressed: () {
          Products.deleteProduct(widget._product);
          Navigator.popUntil(context, (route) => route.isFirst);
        });

    AlertDialog dialog = AlertDialog(
      title: Text("Really delete?"),
      content: Text("Are you sure you wish to delete $_fullName?"),
      actions: [yesButton, noButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  /// Asks the user for confirmation if they really wish to visit a site or not.
  /// If the user selects yes, a web browser will automatically open and
  /// take them to the site.
  void sitePrompt() {
    ElevatedButton noButton = ElevatedButton(
        child: Text("No"),
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color?>(Colors.grey[600])),
        onPressed: () {
          Navigator.of(context).pop();
        });
    ElevatedButton yesButton = ElevatedButton(
        child: Text("Yes"),
        onPressed: () {
          _openPage();
        });

    AlertDialog dialog = AlertDialog(
      title: Text("Visit Site?"),
      content: Text("This will take you to:\n${widget._product.siteLink}"),
      actions: [yesButton, noButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  /// Opens the link associated with the product.
  void _openPage() async {
    String url = widget._product.siteLink;
    if (url.contains("https://")) {
      url = url.substring(8);
    }
    if (await canLaunch("https://$url")) {
      await launch("https://$url");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: AutoSizeText(
          "$url is a bad link, cannot open.",
          maxLines: 1,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ));
    }
  }
}
