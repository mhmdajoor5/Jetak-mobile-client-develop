import 'package:location/location.dart';

import '../helpers/custom_trace.dart';
//
// class Address {
//   String? id;
//   String? description;
//   String? address;
//   double? latitude;
//   double? longitude;
//   bool? isDefault;
//   String? userId;
//
//   Address();
//
//   Address.fromJSON(Map<String, dynamic> jsonMap) {
//     try {
//       id = jsonMap['id'].toString();
//       description = jsonMap['description'] != null ? jsonMap['description'].toString() : null;
//       address = jsonMap['address'] != null ? jsonMap['address'] : null;
//       latitude = jsonMap['latitude'] != null ? jsonMap['latitude'].toDouble() : null;
//       longitude = jsonMap['longitude'] != null ? jsonMap['longitude'].toDouble() : null;
//       isDefault = jsonMap['is_default'] ?? false;
//     } catch (e) {
//       print(CustomTrace(StackTrace.current, message: e.toString()));
//     }
//   }
//
//   bool isUnknown() {
//     return latitude == null || longitude == null ;
//   }
//
//   Map toMap() {
//     var map = new Map<String, dynamic>();
//     map["id"] = id;
//     map["description"] = description;
//     map["address"] = address;
//     map["latitude"] = latitude;
//     map["longitude"] = longitude;
//     map["is_default"] = isDefault;
//     map["user_id"] = userId;
//     return map;
//   }
//
//   LocationData toLocationData() {
//     return LocationData.fromMap({
//       "latitude": latitude,
//       "longitude": longitude,
//     });
//   }
// }
class Address {
  String? id;
  String? description;
  String? address;
  double? latitude;
  double? longitude;
  bool? isDefault;
  String? userId;
  String? type;
  String? entryMethod;
  String? instructions;
  String? label;


  Address({
    this.id,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.isDefault,
    this.userId,
    this.type,
    this.entryMethod,
    this.instructions,
    this.label,
  });

  Address.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      description = jsonMap['description'] != null ? jsonMap['description'].toString() : null;
      address = jsonMap['address'] != null ? jsonMap['address'] : null;
      latitude = jsonMap['latitude'] != null ? jsonMap['latitude'].toDouble() : null;
      longitude = jsonMap['longitude'] != null ? jsonMap['longitude'].toDouble() : null;
      isDefault = jsonMap['is_default'] ?? false;
      type = jsonMap['type'];
      entryMethod = jsonMap['entryMethod'];
      instructions = jsonMap['instructions'];
      label = jsonMap['label'];
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  bool isUnknown() {
    return latitude == null || longitude == null ;
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["description"] = description;
    map["address"] = address;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["is_default"] = isDefault;
    map["user_id"] = userId;
    return map;
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
    });
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'user_id': userId,
      "type": type,
      "entryMethod": entryMethod,
      "instructions": instructions,
      "label": label,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString(),
      description: json['description'],
      address: json['address'],
      latitude: (json['latitude'] != null) ? json['latitude'].toDouble() : null,
      longitude: (json['longitude'] != null) ? json['longitude'].toDouble() : null,
      isDefault: json['is_default'] ?? false,
      userId: json['user_id'],
      type: json['type'],
      entryMethod: json['entryMethod'],
      instructions: json['instructions'],
      label: json['label'],
    );
  }

}
