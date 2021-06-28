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
  String description;
  int quantity;
  double price;
  String source;
  String siteLink;
  double rating;
  bool favorite;
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
      this.description = "",
      this.quantity = 0,
      this.price = 0.0,
      this.source = "",
      this.rating = 0.0,
      this.siteLink = "",
      this.favorite = false,
      this.tags = ""});

  @override
  String toString() {
    return "ID: $id\n" +
        "Name: $name\n" +
        "Description: $description\n" +
        "Quantity: $quantity\n" +
        "Price: $price\n" +
        "Source: $source\n" +
        "Rating: $rating\n" +
        "Site Link: $siteLink\n" +
        "Favorite: $favorite\n" +
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
      "DESCRIPTION": description,
      "QUANTITY": quantity,
      "PRICE": price,
      "SOURCE": source,
      "IMAGE": image == null ? null : base64Encode(image!),
      "RATING": rating,
      "SITELINK": siteLink,
      "FAVORITE": favorite,
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
    String description = row["DESCRIPTION"];
    int quantity = row["QUANTITY"];
    double price = row["PRICE"];
    String source = row["SOURCE"];
    Uint8List? image =
        row["IMAGE"] != null ? Base64Decoder().convert(row["IMAGE"]) : null;
    double rating = row["RATING"];
    String siteLink = row["SITELINK"];
    bool favorite = row["FAVORITE"];
    String tags = row["TAGS"];

    return new Product(
        id: id,
        name: name,
        description: description,
        image: image,
        quantity: quantity,
        price: price,
        source: source,
        rating: rating,
        siteLink: siteLink,
        favorite: favorite,
        tags: tags);
  }
}
