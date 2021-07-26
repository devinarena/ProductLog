import 'dart:convert';
import 'dart:typed_data';

/// Class  : Product
/// Author : Devin Arena
/// Date   : 6/7/2021
/// Purpose: Stores information relating to products
///          such as name, description, price, etc.
class Product {
  int id;
  Uint8List? image;
  String name;
  String manufacturer;
  String description;
  int quantity;
  double price;
  String source;
  String siteLink;
  double rating;
  bool favorite;
  bool hideUPC;
  DateTime? purchaseDate;
  String tags;

  /// Product constructor
  /// @param id required the product's 12 digit UPC
  /// @param name required the product's name
  /// @param description the product's description
  /// @param rating the rating of the product out of 5
  Product(
      {required this.id,
      this.image,
      this.name = "",
      this.manufacturer = "",
      this.description = "",
      this.quantity = 0,
      this.price = 0.0,
      this.source = "",
      this.rating = 0.0,
      this.siteLink = "",
      this.favorite = false,
      this.hideUPC = false,
      this.purchaseDate,
      this.tags = ""});

  @override
  String toString() {
    return "ID: $id\n" +
        "Name: $name\n" +
        "Manufacturer: $manufacturer\n" +
        "Description: $description\n" +
        "Quantity: $quantity\n" +
        "Price: $price\n" +
        "Source: $source\n" +
        "Rating: $rating\n" +
        "Site Link: $siteLink\n" +
        "Favorite: $favorite\n" +
        "Hide UPC: $hideUPC\n" +
        "Purchase Date: $purchaseDate\n" +
        "Tags: $tags\n" +
        "Image: $image\n";
  }

  /// Serializes a product to be stored in the database.
  /// Converts all fields to a map of keys and values.
  ///
  /// @return Map<String, dynamic> list of fields as key, value pairs for a database
  Map<String, dynamic> serialize() {
    return {
      "ID": id,
      "NAME": name,
      "MANUFACTURER": manufacturer,
      "DESCRIPTION": description,
      "QUANTITY": quantity,
      "PRICE": price,
      "SOURCE": source,
      "IMAGE": image == null ? null : base64Encode(image!),
      "RATING": rating,
      "SITELINK": siteLink,
      "FAVORITE": favorite ? 1 : 0,
      "HIDE_UPC": hideUPC ? 1 : 0,
      "PURCHASE_DATE":
          purchaseDate != null ? purchaseDate!.toIso8601String() : null,
      "TAGS": tags,
    };
  }

  /// Serializes a product to be stored in the database WITHOUT its ID.
  /// Allows for the database to automatically assign the product an ID.
  /// Called when a user adds a product instead of using a UPC.
  ///
  /// @return Map<String, dynamic> list of fields as key, value pairs for a database
  Map<String, dynamic> serializeWithoutID() {
    return {
      "NAME": name,
      "MANUFACTURER": manufacturer,
      "DESCRIPTION": description,
      "QUANTITY": quantity,
      "PRICE": price,
      "SOURCE": source,
      "IMAGE": image == null ? null : base64Encode(image!),
      "RATING": rating,
      "SITELINK": siteLink,
      "FAVORITE": favorite ? 1 : 0,
      "HIDE_UPC": hideUPC ? 1 : 0,
      "PURCHASE_DATE":
          purchaseDate != null ? purchaseDate!.toIso8601String() : null,
      "TAGS": tags,
    };
  }

  /// Deserializes a row from a database into a product object.
  /// Reads all necessary values and assigns them to the corresponding
  /// class fields before returning a created Product object.
  ///
  /// @returns Product the deserialized product
  static Product deserialize(Map<String, dynamic> row) {
    int id = row["ID"];
    String name = row["NAME"];
    String manufacturer = row["MANUFACTURER"];
    String description = row["DESCRIPTION"];
    int quantity = row["QUANTITY"];
    double price = row["PRICE"];
    String source = row["SOURCE"];
    Uint8List? image =
        row["IMAGE"] != null ? Base64Decoder().convert(row["IMAGE"]) : null;
    double rating = row["RATING"];
    String siteLink = row["SITELINK"];
    bool favorite = row["FAVORITE"] == 1;
    bool hideUPC = row["HIDE_UPC"] == 1;
    DateTime? purchaseDate = row["PURCHASE_DATE"] != null
        ? DateTime.tryParse(row["PURCHASE_DATE"])
        : null;
    String tags = row["TAGS"];

    return new Product(
        id: id,
        name: name,
        manufacturer: manufacturer,
        description: description,
        image: image,
        quantity: quantity,
        price: price,
        source: source,
        rating: rating,
        siteLink: siteLink,
        favorite: favorite,
        hideUPC: hideUPC,
        purchaseDate: purchaseDate,
        tags: tags);
  }
}
