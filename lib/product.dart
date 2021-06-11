/// Class  : Product
/// Author : Devin Arena
/// Date   : 6/7/2021
/// Purpose: Stores information relating to products
///          such as name, description, price, etc.
class Product {
  int id;
  String name;
  String description;
  double rating;
  /// Product constructor
  /// @param id required the product's 12 digit UPC
  /// @param name required the product's name
  /// @param description the product's description
  /// @param rating the rating of the product out of 5
  Product({required this.id, required this.name, this.description = "", this.rating = 0.0});
}