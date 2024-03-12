class Product {
  String id;
  String name;
  double? price;
  double? amount;
  bool isBought;

  Product({
    required this.id,
    required this.name,
    required this.isBought,
    this.price,
    this.amount,
  });

  Product.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"],
        isBought = map["isBought"],
        price = map["price"],
        amount = map["amount"];

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "isBought": isBought,
      "price": price,
      "amount": amount,
    };
  }
}
