class RestaurantDetailsModel {
  final RestaurantModelInCaseDetails restaurant;
  final List<CategoryElement> categories;

  RestaurantDetailsModel({
    required this.restaurant,
    required this.categories,
  });

  factory RestaurantDetailsModel.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailsModel(
      restaurant: RestaurantModelInCaseDetails.fromJson(json["restaurant"] ?? {}),
      categories: (json["categories"] as List<dynamic>?)
          ?.map((i) => CategoryElement.fromJson(i as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "restaurant": restaurant.toJson(),
    "categories": categories.map((x) => x.toJson()).toList(),
  };
}

class CategoryElement {
  final int id;
  final String name;
  final List<Food> foods;

  CategoryElement({
    required this.id,
    required this.name,
    required this.foods,
  });

  factory CategoryElement.fromJson(Map<String, dynamic> json) {
    return CategoryElement(
      id: (json["id"] is int) ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      name: json["name"]?.toString() ?? '',
      foods: (json["foods"] as List<dynamic>?)
          ?.map((i) => Food.fromJson(i as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "foods": foods.map((x) => x.toJson()).toList(),
  };
}

class Food {
  final int id;
  final String name;
  final int price;
  final dynamic discountPrice;
  final String description;
  final dynamic ingredients;
  final int packageItemsCount;
  final dynamic weight;
  final dynamic unit;
  final bool featured;
  final bool deliverable;
  final int restaurantId;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int estimatedTime;
  final List<dynamic> customFields;
  final bool hasMedia;
  final FoodRestaurant restaurant;
  final FoodCategory category;
  final List<Media> media;

  Food({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.description,
    this.ingredients,
    required this.packageItemsCount,
    this.weight,
    this.unit,
    required this.featured,
    required this.deliverable,
    required this.restaurantId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.estimatedTime,
    required this.customFields,
    required this.hasMedia,
    required this.restaurant,
    required this.category,
    required this.media,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: (json["id"] is int) ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      name: json["name"]?.toString() ?? '',
      price: (json["price"] is int) ? json["price"] : int.tryParse(json["price"]?.toString() ?? '0') ?? 0,
      discountPrice: json["discountPrice"],
      description: json["description"]?.toString() ?? '',
      ingredients: json["ingredients"],
      packageItemsCount: (json["packageItemsCount"] is int) ? json["packageItemsCount"] : int.tryParse(json["packageItemsCount"]?.toString() ?? '1') ?? 1,
      weight: json["weight"],
      unit: json["unit"],
      featured: json["featured"]?.toString().toLowerCase() == 'true',
      deliverable: json["deliverable"]?.toString().toLowerCase() == 'true',
      restaurantId: (json["restaurantId"] is int) ? json["restaurantId"] : int.tryParse(json["restaurantId"]?.toString() ?? '0') ?? 0,
      categoryId: (json["categoryId"] is int) ? json["categoryId"] : int.tryParse(json["categoryId"]?.toString() ?? '0') ?? 0,
      createdAt: DateTime.parse(json["createdAt"]?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json["updatedAt"]?.toString() ?? DateTime.now().toString()),
      estimatedTime: (json["estimatedTime"] is int) ? json["estimatedTime"] : int.tryParse(json["estimatedTime"]?.toString() ?? '30') ?? 30,
      customFields: (json["customFields"] as List<dynamic>?)?.cast<dynamic>() ?? [],
      hasMedia: json["hasMedia"]?.toString().toLowerCase() == 'true',
      restaurant: FoodRestaurant.fromJson(json["restaurant"] ?? {}),
      category: FoodCategory.fromJson(json["category"] ?? {}),
      media: (json["media"] as List<dynamic>?)
          ?.map((i) => Media.fromJson(i as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "discountPrice": discountPrice,
    "description": description,
    "ingredients": ingredients,
    "packageItemsCount": packageItemsCount,
    "weight": weight,
    "unit": unit,
    "featured": featured,
    "deliverable": deliverable,
    "restaurantId": restaurantId,
    "categoryId": categoryId,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "estimatedTime": estimatedTime,
    "customFields": customFields,
    "hasMedia": hasMedia,
    "restaurant": restaurant.toJson(),
    "category": category.toJson(),
    "media": media.map((x) => x.toJson()).toList(),
  };
}

class FoodCategory {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<dynamic> customFields;
  final bool hasMedia;
  final List<Media> media;

  FoodCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.customFields,
    required this.hasMedia,
    required this.media,
  });

  factory FoodCategory.fromJson(Map<String, dynamic> json) {
    return FoodCategory(
      id: (json["id"] is int) ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      name: json["name"]?.toString() ?? '',
      description: json["description"]?.toString() ?? '',
      createdAt: DateTime.parse(json["createdAt"]?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json["updatedAt"]?.toString() ?? DateTime.now().toString()),
      customFields: (json["customFields"] as List<dynamic>?)?.cast<dynamic>() ?? [],
      hasMedia: json["hasMedia"]?.toString().toLowerCase() == 'true',
      media: (json["media"] as List<dynamic>?)
          ?.map((i) => Media.fromJson(i as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "customFields": customFields,
    "hasMedia": hasMedia,
    "media": media.map((x) => x.toJson()).toList(),
  };
}

class Media {
  final int id;
  final String url;
  final String thumb;

  Media({
    required this.id,
    required this.url,
    required this.thumb,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: (json["id"] is int) ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      url: json["url"]?.toString() ?? '',
      thumb: json["thumb"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "thumb": thumb,
  };
}

class FoodRestaurant {
  final int id;
  final String name;
  final int deliveryFee;
  final String address;
  final String phone;
  final int defaultTax;
  final bool availableForDelivery;
  final List<dynamic> customFields;
  final bool hasMedia;
  final dynamic rate;
  final List<Media> media;

  FoodRestaurant({
    required this.id,
    required this.name,
    required this.deliveryFee,
    required this.address,
    required this.phone,
    required this.defaultTax,
    required this.availableForDelivery,
    required this.customFields,
    required this.hasMedia,
    required this.rate,
    required this.media,
  });

  factory FoodRestaurant.fromJson(Map<String, dynamic> json) {
    return FoodRestaurant(
      id: (json["id"] is int) ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      name: json["name"]?.toString() ?? '',
      deliveryFee: (json["deliveryFee"] is int) ? json["deliveryFee"] : int.tryParse(json["deliveryFee"]?.toString() ?? '0') ?? 0,
      address: json["address"]?.toString() ?? '',
      phone: json["phone"]?.toString() ?? '',
      defaultTax: (json["defaultTax"] is int) ? json["defaultTax"] : int.tryParse(json["defaultTax"]?.toString() ?? '0') ?? 0,
      availableForDelivery: json["availableForDelivery"]?.toString().toLowerCase() == 'true',
      customFields: (json["customFields"] as List<dynamic>?)?.cast<dynamic>() ?? [],
      hasMedia: json["hasMedia"]?.toString().toLowerCase() == 'true',
      rate: json["rate"],
      media: (json["media"] as List<dynamic>?)
          ?.map((i) => Media.fromJson(i as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "deliveryFee": deliveryFee,
    "address": address,
    "phone": phone,
    "defaultTax": defaultTax,
    "availableForDelivery": availableForDelivery,
    "customFields": customFields,
    "hasMedia": hasMedia,
    "rate": rate,
    "media": media.map((x) => x.toJson()).toList(),
  };
}

class RestaurantModelInCaseDetails {
  final int id;
  final String name;
  final String description;
  final String address;
  final String latitude;
  final String longitude;
  final String phone;
  final dynamic mobile;
  final dynamic information;
  final int adminCommission;
  final int deliveryFee;
  final int deliveryRange;
  final int defaultTax;
  final bool closed;
  final bool active;
  final bool availableForDelivery;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic preparationTimeFrom;
  final dynamic preparationTimeTo;
  final List<dynamic> customFields;
  final bool hasMedia;
  final dynamic rate;
  final List<Media> media;

  RestaurantModelInCaseDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.mobile,
    required this.information,
    required this.adminCommission,
    required this.deliveryFee,
    required this.deliveryRange,
    required this.defaultTax,
    required this.closed,
    required this.active,
    required this.availableForDelivery,
    required this.createdAt,
    required this.updatedAt,
    required this.preparationTimeFrom,
    required this.preparationTimeTo,
    required this.customFields,
    required this.hasMedia,
    required this.rate,
    required this.media,
  });

  factory RestaurantModelInCaseDetails.fromJson(Map<String, dynamic> json) {
    return RestaurantModelInCaseDetails(
      id: (json["id"] is int) ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      name: json["name"]?.toString() ?? '',
      description: json["description"]?.toString() ?? '',
      address: json["address"]?.toString() ?? '',
      latitude: json["latitude"]?.toString() ?? '0.0',
      longitude: json["longitude"]?.toString() ?? '0.0',
      phone: json["phone"]?.toString() ?? '',
      mobile: json["mobile"],
      information: json["information"],
      adminCommission: (json["adminCommission"] is int) ? json["adminCommission"] : int.tryParse(json["adminCommission"]?.toString() ?? '0') ?? 0,
      deliveryFee: (json["deliveryFee"] is int) ? json["deliveryFee"] : int.tryParse(json["deliveryFee"]?.toString() ?? '0') ?? 0,
      deliveryRange: (json["deliveryRange"] is int) ? json["deliveryRange"] : int.tryParse(json["deliveryRange"]?.toString() ?? '5') ?? 5,
      defaultTax: (json["defaultTax"] is int) ? json["defaultTax"] : int.tryParse(json["defaultTax"]?.toString() ?? '0') ?? 0,
      closed: json["closed"]?.toString().toLowerCase() == 'true',
      active: json["active"]?.toString().toLowerCase() == 'true',
      availableForDelivery: json["availableForDelivery"]?.toString().toLowerCase() == 'true',
      createdAt: DateTime.parse(json["createdAt"]?.toString() ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json["updatedAt"]?.toString() ?? DateTime.now().toString()),
      preparationTimeFrom: json["preparationTimeFrom"],
      preparationTimeTo: json["preparationTimeTo"],
      customFields: (json["customFields"] as List<dynamic>?)?.cast<dynamic>() ?? [],
      hasMedia: json["hasMedia"]?.toString().toLowerCase() == 'true',
      rate: json["rate"],
      media: (json["media"] as List<dynamic>?)
          ?.map((i) => Media.fromJson(i as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    "phone": phone,
    "mobile": mobile,
    "information": information,
    "adminCommission": adminCommission,
    "deliveryFee": deliveryFee,
    "deliveryRange": deliveryRange,
    "defaultTax": defaultTax,
    "closed": closed,
    "active": active,
    "availableForDelivery": availableForDelivery,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "preparationTimeFrom": preparationTimeFrom,
    "preparationTimeTo": preparationTimeTo,
    "customFields": customFields,
    "hasMedia": hasMedia,
    "rate": rate,
    "media": media.map((x) => x.toJson()).toList(),
  };
}