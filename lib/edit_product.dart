import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchase_log/product.dart';
import 'package:purchase_log/products.dart';
import 'package:purchase_log/settings.dart';
import 'package:purchase_log/themes.dart';

/// Class  : EditProduct
/// Author : Devin Arena
/// Date   : 6/19/2021
/// Purpose: Allows users to edit/add new products through
///          a few simple menu screens (such as to take a picture,
///          describe the product, enter a rating, etc.)
class EditProduct extends StatefulWidget {
  final Product product;
  final bool editing;
  EditProduct({Key? key, required this.product, required this.editing})
      : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

/// Class  : EditProductState
/// Author : Devin Arena
/// Date   : 6/19/2021
/// Purpose: Contains widget and state info for EditProduct.
///          All three tabs are controlled by this state.
class _EditProductState extends State<EditProduct>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _controller;

  // form info
  final _formKey = GlobalKey<FormState>();
  bool editing = false;
  late TextEditingController _nameController;
  late TextEditingController _manuController;
  late TextEditingController _descController;
  late TextEditingController _ratingController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _sourceController;
  late TextEditingController _siteController;
  late TextEditingController _tagController;
  late TextEditingController _purchaseDateController;

  late Uint8List? image;
  bool favorite = false;
  bool hideUPC = false;
  String tags = "";

  late CameraController _cameraController;
  double cameraRatio = 1;
  late ImagePicker _picker;

  late RegExp number;
  late RegExp text;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(vsync: this, length: tabs.length);
    // text editing controllers
    _nameController = new TextEditingController(text: widget.product.name);
    _manuController =
        new TextEditingController(text: widget.product.manufacturer);
    _descController =
        new TextEditingController(text: widget.product.description);
    _ratingController = new TextEditingController(
        text: widget.product.rating > 0
            ? widget.product.rating.toString()
            : null);
    _quantityController =
        new TextEditingController(text: widget.product.quantity.toString());
    _priceController = new TextEditingController(
        text:
            widget.product.price > 0 ? widget.product.price.toString() : null);
    _sourceController = new TextEditingController(text: widget.product.source);
    _siteController = new TextEditingController(text: widget.product.siteLink);
    _tagController = new TextEditingController();
    _purchaseDateController = new TextEditingController(
        text: widget.product.purchaseDate != null
            ? Products.dateFormat.format(widget.product.purchaseDate!)
            : "");
    _cameraController =
        CameraController(Products.cameras![0], ResolutionPreset.max);
    _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        cameraRatio = _cameraController.value.aspectRatio;
      });
    });
    _controller.addListener(() {
      setState(() {});
    });
    _picker = ImagePicker();
    image = widget.product.image;
    number = RegExp(r"^[0-9]+(\.[0-9]+)?$");
    text = RegExp(r"^[a-zA-Z]+$");
    favorite = widget.product.favorite;
    hideUPC = widget.product.hideUPC;
    tags = widget.product.tags;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _nameController.dispose();
    _descController.dispose();
    _ratingController.dispose();
    _cameraController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _sourceController.dispose();
    _siteController.dispose();
    _tagController.dispose();
    _purchaseDateController.dispose();
  }

  final List<Tab> tabs = [
    Tab(
        child: AutoSizeText("Picture",
            maxLines: 1, style: TextStyle(fontSize: 20))),
    Tab(
        child: AutoSizeText("General Info",
            maxLines: 1, style: TextStyle(fontSize: 20))),
    Tab(
        child: AutoSizeText("Other Info",
            maxLines: 1, style: TextStyle(fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText("Purchase Log",
              maxLines: 1, style: TextStyle(fontSize: 28)),
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 28),
          bottom: TabBar(
            controller: _controller,
            tabs: tabs,
            indicatorColor: Color(Settings.themeColor),
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            controller: _controller,
            children: [_picturePage(), _generalPage(), _otherPage()],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _fab());
  }

  /// Generates the picture page (tab 1) for editing products.
  ///
  /// @return Widget the picture page widget
  Widget _picturePage() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    double scale = cameraRatio * deviceRatio;
    if (scale < 1) scale = 1 / scale;
    if (image == null) {
      return Transform.scale(
          scale: scale, child: Center(child: CameraPreview(_cameraController)));
    } else {
      return Image.memory(image!);
    }
  }

  /// Generates the general page (tab 2) for editing products.
  ///
  /// @return Widget the picture page widget
  Widget _generalPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoSizeText("General Information",
                maxLines: 1, style: TextStyle(fontSize: 28)),
            SizedBox(height: 25),
            TextFormField(
              controller: _nameController,
              maxLines: 1,
              decoration: InputDecoration(
                  labelText: "Product Name *",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return "Product name is required";
              },
            ),
            SizedBox(height: 25),
            TextFormField(
              controller: _manuController,
              maxLines: 1,
              decoration: InputDecoration(
                  labelText: "Manufacturer",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
            ),
            SizedBox(height: 25),
            TextFormField(
              controller: _descController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
            ),
            SizedBox(height: 25),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: "Quantity",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
            ),
            SizedBox(height: 25),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: "Price",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
              validator: (val) {
                
              },
            ),
            SizedBox(height: 25),
            TextFormField(
              controller: _sourceController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  labelText: "Source",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
            ),
            SizedBox(height: 25),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: TextFormField(
                      controller: _purchaseDateController,
                      keyboardType: TextInputType.datetime,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: "Purchase Date",
                        labelStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !Products.dateFormat.digitMatcher.hasMatch(value))
                          return "Date must be in Products.dateFormat MM/DD/YYYY";
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 40),
                    child: ElevatedButton(
                      onPressed: _pickDate,
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(0)),
                      ),
                      child: Icon(Icons.date_range),
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 50,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            AutoSizeText(
              "More settings \u2794\n\u2713 to save",
              maxLines: 2,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Generates the other page (tab 3) for editing products.
  ///
  /// @return Widget the picture page widget
  Widget _otherPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoSizeText("Other Information",
                maxLines: 1, style: TextStyle(fontSize: 28)),
            SizedBox(height: 25),
            TextFormField(
              controller: _ratingController,
              maxLines: 1,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: "Rating (decimal out of 5 stars)",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
              validator: (value) {
                if (value != null && number.hasMatch(value)) {
                  double val = double.parse(value);
                  if (val >= 0 && val <= 5) return null;
                }
                if (value != null && value.isNotEmpty)
                  return "Rating must be a decimal between 0-5";
              },
            ),
            SizedBox(height: 25),
            TextFormField(
              controller: _siteController,
              maxLines: 1,
              decoration: InputDecoration(
                  labelText: "Purchase Link",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
            ),
            SizedBox(height: 25),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: CheckboxListTile(
                value: favorite,
                contentPadding: EdgeInsets.all(0),
                title: AutoSizeText("Favorite?",
                    maxLines: 1,
                    style: TextStyle(
                        color: Themes.isDark() ? Colors.white : Colors.black)),
                onChanged: (newVal) {
                  setState(() {
                    favorite = newVal!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Color(Settings.themeColor),
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: CheckboxListTile(
                value: hideUPC,
                contentPadding: EdgeInsets.all(0),
                title: AutoSizeText("Hide UPC (*)",
                    maxLines: 1,
                    style: TextStyle(
                        color: Themes.isDark() ? Colors.white : Colors.black)),
                onChanged: (newVal) {
                  setState(() {
                    hideUPC = newVal!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Color(Settings.themeColor),
              ),
            ),
            SizedBox(height: 25),
            AutoSizeText("Tags", maxLines: 1, style: TextStyle(fontSize: 20)),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _tagWidgets(),
            ),
            Divider(
              height: 50,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            AutoSizeText("All done, press \u2713 to save",
                maxLines: 1, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  /// Generates a list of row widgets containing the tag
  /// identifier and a delete button. Creates widgets using tags
  /// from tags field.
  ///
  /// @return List<Widget> the list of tags and a delete button
  List<Widget> _tagWidgets() {
    List<Widget> children = [];
    children.add(SizedBox(height: 25));
    children.add(
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: TextFormField(
                controller: _tagController,
                maxLines: 1,
                decoration: InputDecoration(
                  labelText: "Add a tag",
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 40),
            child: ElevatedButton(
              onPressed: _addTag,
              style: ButtonStyle(
                padding:
                    MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0)),
              ),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
    children.add(Divider(
      height: 50,
      thickness: 2,
      indent: 10,
      endIndent: 10,
    ));
    for (String tag in tags.split(",")) {
      if (tag.isEmpty) continue;
      children.add(
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoSizeText(tag, maxLines: 1, style: TextStyle(fontSize: 18)),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 40),
              child: ElevatedButton(
                onPressed: () {
                  _deleteTag(tag);
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(0))),
                child: Icon(Icons.delete),
              ),
            ),
          ],
        ),
      );
    }
    return children;
  }

  /// Generates and returns the floating action button based
  /// on the current tab of the tabcontroller and product image.
  ///
  /// @returns FloatingActionButton to display
  Widget _fab() {
    List<Widget> children = [];
    if (_controller.index == 0 && !_controller.indexIsChanging) {
      children.add(
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            heroTag: "btn2",
            child: Icon(image == null ? Icons.camera_alt : Icons.replay,
                color: Colors.white),
            backgroundColor: Color(Settings.themeColor),
            onPressed: () {
              if (image == null)
                _takePicture();
              else
                _retryPrompt();
            },
          ),
        ),
      );
      children.add(
        Align(
          alignment: Alignment.bottomLeft,
          child: FloatingActionButton(
            heroTag: "btn1",
            child: Icon(Icons.file_upload, color: Colors.white),
            backgroundColor: Color(Settings.themeColor),
            onPressed: () {
              _pickPicture();
            },
          ),
        ),
      );
    } else {
      children.add(
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            child: Icon(Icons.check, color: Colors.white),
            backgroundColor: Color(Settings.themeColor),
            onPressed: () {
              _submit();
            },
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: children,
      ),
    );
  }

  /// Callback when the floating action button is pressed. When the
  /// form is submitted, attempt to add the product to the database.
  void _submit() {
    if (_formKey.currentState != null && !_formKey.currentState!.validate())
      return;
    if (_nameController.text.isEmpty) return;

    widget.product.name = _nameController.text;
    widget.product.manufacturer = _manuController.text;
    widget.product.description = _descController.text;
    if (_ratingController.text.isNotEmpty)
      widget.product.rating = double.parse(_ratingController.text);
    if (_quantityController.text.isNotEmpty)
      widget.product.quantity = int.parse(_quantityController.text);
    if (_priceController.text.isNotEmpty)
      widget.product.price = double.parse(_priceController.text);
    widget.product.source = _sourceController.text;
    widget.product.siteLink = _siteController.text;
    widget.product.image = image;
    if (_purchaseDateController.text.isNotEmpty)
      widget.product.purchaseDate =
          Products.dateFormat.parse(_purchaseDateController.text);
    widget.product.favorite = favorite;
    widget.product.hideUPC = hideUPC;
    widget.product.tags = tags;
    if (widget.editing)
      Products.updateProduct(widget.product);
    else
      Products.addProduct(widget.product);

    Navigator.of(context).pop();
  }

  /// Takes a picture using the current camera. Saves the picture
  /// to the current product to later be saved in the database.
  void _takePicture() async {
    final pic = await _cameraController.takePicture();
    setState(() {
      image = File(pic.path).readAsBytesSync();
    });
  }

  void _pickPicture() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    Uint8List im = await file.readAsBytes();
    setState(() {
      image = im;
    });
  }

  /// Deletes the specified tag from the tag list
  /// and displays a message using a snackbar to
  /// the user.
  ///
  /// @param tag the tag to delete
  void _deleteTag(String tag) {
    setState(() {
      tags =
          tags.replaceAll(tags.contains(tag + "\,") ? (tag + "\,") : tag, "");
      if (tags.endsWith(",")) tags = tags.substring(0, tags.length - 1);
      print(tags);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: AutoSizeText(
        "Removed tag '$tag' from product",
        maxLines: 1,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.grey[900],
    ));
  }

  /// Adds the specified tag to the tag list
  /// and displays a message using a snackbar to
  /// the user.
  ///
  /// @param tag the tag to delete
  void _addTag() {
    String tag = _tagController.text;
    String sbText = "Added tag '$tag' to product";
    if (!text.hasMatch(tag))
      sbText = "Tags must be only letters";
    else if (tags.contains(tag))
      sbText = "Product already has tag";
    else {
      setState(() {
        if (tags.isEmpty)
          tags = tag;
        else
          tags = tags + "," + tag;
        _tagController.text = "";
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: AutoSizeText(
        sbText,
        maxLines: 1,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.grey[900],
    ));
  }

  /// Asks the user if they wish to really delete a product image,
  /// called when a user presses the retry FAB.
  void _retryPrompt() {
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
          setState(() {
            image = null;
          });
          Navigator.of(context).pop();
        });

    AlertDialog dialog = AlertDialog(
      title: Text("Really retry?"),
      content:
          Text("Are you sure you wish to delete this picture and try again?"),
      actions: [yesButton, noButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  /// Opens a date picker and updates the EditProduct state
  /// with the new selected date.
  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.product.purchaseDate != null
          ? widget.product.purchaseDate!
          : DateTime.now(),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != widget.product.purchaseDate)
      setState(() {
        widget.product.purchaseDate = picked;
        _purchaseDateController.text =
            Products.dateFormat.format(widget.product.purchaseDate!);
      });
  }

  @override
  bool get wantKeepAlive => true;
}
