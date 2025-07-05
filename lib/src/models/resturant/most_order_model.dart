class MostOrderModel {
  int id;
  String name;
  int price;
  String? description;
  int packageItemsCount;
  bool featured;
  bool deliverable;
  int estimatedTime;
  int ordersCount;
  bool hasMedia;

  factory MostOrderModel.fromJson(Map<String, dynamic> json) {
    return MostOrderModel(
      id: json["id"] as int,
      name: json["name"] as String,
      price: json["price"] as int,
      description: json["description"] as String?,
      packageItemsCount: json["package_items_count"] as int,
      featured: json["featured"] as bool,
      deliverable: json["deliverable"] as bool,
      estimatedTime: json["estimated_time"] as int,
      ordersCount: json["orders_count"] as int,
      hasMedia: json["has_media"] as bool,
    );
  }

  MostOrderModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.packageItemsCount,
    required this.featured,
    required this.deliverable,
    required this.estimatedTime,
    required this.ordersCount,
    required this.hasMedia,
  });
}