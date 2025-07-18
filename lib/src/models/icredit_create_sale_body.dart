import 'cart.dart';

class ICreditSaleBody {
  final String groupPrivateToken;
  final List<Item> items;
  final int saleType;
  final String? orderType;

  ICreditSaleBody({required this.groupPrivateToken, required this.items, required this.saleType,this.orderType,});

  Map<String, dynamic> toMap() {
    return {
      "GroupPrivateToken": groupPrivateToken,
      "Items": items.map((e) => e.toMap()).toList(),
      "SaleType": saleType,
      'OrderType': orderType,
    };
  }
}

class Item {
  final double unitPrice;
  final double quantity;
  final String description;

  Item({required this.unitPrice, required this.quantity, required this.description});

  Map<String, dynamic> toMap() {
    return {"UnitPrice": unitPrice, "Quantity": quantity, "Description": description};
  }

  factory Item.from(Cart cart) {
    return Item(unitPrice: cart.getFoodPrice(), quantity: cart.quantity, description: cart.id ?? '');
  }
}

List<Item> fromList(List<Cart> carts) {
  return carts.map((e) => Item.from(e)).toList();
}
