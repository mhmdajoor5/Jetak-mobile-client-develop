class Nutrition {
  String id;
  String name;
  double quantity;

  Nutrition({this.id = '', this.name = '', this.quantity = 0.0});

  factory Nutrition.fromJSON(Map<String, dynamic>? jsonMap) {
    return Nutrition(id: jsonMap?['id']?.toString() ?? '', name: jsonMap?['name']?.toString() ?? '', quantity: (jsonMap?['quantity'] as num?)?.toDouble() ?? 0.0);
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is Nutrition && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
