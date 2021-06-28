import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purchase_log/edit_product.dart';
import 'package:purchase_log/product.dart';
import 'package:purchase_log/products.dart';

class ProductPage extends StatefulWidget {
  final Product _product;

  ProductPage(this._product, {Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // use French locale number formatting for the group seperator to be a space
  final format = new NumberFormat("0,00000,00000,0", "fr-FR");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: AutoSizeText("${widget._product.name}",
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
              icon: Icon(Icons.delete, color: Colors.red)),
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

  List<Widget> buildPage() {
    List<Widget> page = [];
    if (widget._product.image != null) {
      page.add(FractionallySizedBox(
          widthFactor: 0.8,
          child: Container(
            child: Image.memory(widget._product.image!),
            decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.black)),
          )));
    }
    page.add(SizedBox(height: 20));
    page.add(AutoSizeText("${widget._product.name}",
        maxLines: 2,
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)));
    page.add(SizedBox(height: 20));
    if (widget._product.description.isNotEmpty) {
      page.add(AutoSizeText("${widget._product.description}",
          maxLines: null, style: TextStyle(fontSize: 20)));
      page.add(SizedBox(height: 20));
    }
    if (widget._product.source.isNotEmpty) {
      page.add(AutoSizeText("Source: ${widget._product.source}",
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
    if (widget._product.quantity > 0) {
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
          AutoSizeText(widget._product.price.toString(),
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
          AutoSizeText(
              (widget._product.quantity * widget._product.price).toString(),
              maxLines: 1,
              style: TextStyle(fontSize: 20)),
        ],
      ));
      page.add(SizedBox(height: 10));
    }
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
            style: TextStyle(fontSize: 28, color: Colors.yellow[500]),
            children: [
              WidgetSpan(
                  child: Icon(Icons.star, size: 36, color: Colors.yellow[300])),
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
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
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
      content: Text("Are you sure you wish to delete ${widget._product.name}?"),
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
          Products.deleteProduct(widget._product);
          Navigator.popUntil(context, (route) => route.isFirst);
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
}
