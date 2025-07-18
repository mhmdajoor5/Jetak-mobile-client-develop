class TrackingOrderModel {
  bool success;
  Data data;
  String message;

  TrackingOrderModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory TrackingOrderModel.fromJson(Map<String, dynamic> json) {
    return TrackingOrderModel(
      success: json["success"].toString().toLowerCase() == 'true',
      data: Data.fromJson(json["data"]),
      message: json["message"] ?? '',
    );
  }
}

class Data {
  List<StatusHistory> statusHistory;
  dynamic preparationTime;
  dynamic estimatedTime;
  DeliveryAddress? deliveryAddress;
  Driver? driver;

  Data({
    required this.statusHistory,
    this.preparationTime,
    this.estimatedTime,
    this.deliveryAddress,
    this.driver,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      statusHistory: (json["status_history"] as List?)
          ?.map((i) => StatusHistory.fromJson(i))
          .toList() ??
          [],
      preparationTime: json["preparation_time"],
      estimatedTime: json["estimated_time"],
      deliveryAddress: json["delivery_address"] != null
          ? DeliveryAddress.fromJson(json["delivery_address"])
          : null,
      driver: json["driver"] != null ? Driver.fromJson(json["driver"]) : null,
    );
  }
}

class DeliveryAddress {
  int id;
  String address;
  double latitude;
  double longitude;
  String description;

  DeliveryAddress({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: int.parse(json["id"].toString()),
      address: json["address"] ?? '',
      latitude: double.tryParse(json["latitude"].toString()) ?? 0.0,
      longitude: double.tryParse(json["longitude"].toString()) ?? 0.0,
      description: json["description"] ?? '',
    );
  }
}

class Driver {
  int id;
  String name;
  dynamic phone;
  String email;
  dynamic latitude;
  dynamic longitude;
  dynamic avatar;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.avatar,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: int.parse(json["id"].toString()),
      name: json["name"] ?? '',
      phone: json["phone"],
      email: json["email"] ?? '',
      latitude: json["latitude"],
      longitude: json["longitude"],
      avatar: json["avatar"],
    );
  }
}

class StatusHistory {
  int id;
  int statusId;
  String statusName;
  String notes;
  DateTime createdAt;
  String userName;

  StatusHistory({
    required this.id,
    required this.statusId,
    required this.statusName,
    required this.notes,
    required this.createdAt,
    required this.userName,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: int.parse(json["id"].toString()),
      statusId: int.parse(json["status_id"].toString()),
      statusName: json["status_name"] ?? '',
      notes: json["notes"] ?? '',
      createdAt: DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
      userName: json["user_name"] ?? '',
    );
  }
}
