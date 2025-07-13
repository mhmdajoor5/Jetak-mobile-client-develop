import '../models/media.dart';
import 'custom_fields.dart';

enum UserState { available, away, busy }

class User {
  String? id;
  String? name;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? apiToken;
  String? deviceToken;
  String? phone;
  String? verificationId;
  String? address;
  String? bio;
  Media? image;
  CustomFields? customFields;
  bool? auth;

  bool get verifiedPhone => customFields?.phone != null && customFields?.verifiedPhone?.value == "1";

  User();

  factory User.fromJSON(Map<String, dynamic>? jsonMap) {
    final user = User();
    try {
      user.id = jsonMap?['id']?.toString();
      user.name = jsonMap?['name']?.toString() ?? '';
      user.email = jsonMap?['email']?.toString() ?? '';
      user.firstName = jsonMap?['name']?.toString() ?? '';
      user.lastName = jsonMap?['name']?.toString() ?? '';
      user.apiToken = jsonMap?['api_token']?.toString();
      user.deviceToken = jsonMap?['device_token']?.toString();

      try {
        user.phone = jsonMap?['custom_fields']?['phone']?['view']?.toString() ?? '';
      } catch (_) {
        user.phone = '';
      }

      try {
        user.address = jsonMap?['custom_fields']?['address']?['view']?.toString() ?? '';
      } catch (_) {
        user.address = '';
      }

      try {
        user.bio = jsonMap?['custom_fields']?['bio']?['view']?.toString() ?? '';
      } catch (_) {
        user.bio = '';
      }

      user.image = (jsonMap?['media'] != null && (jsonMap?['media'] as List).isNotEmpty) ? Media.fromJSON(jsonMap!['media'][0]) : Media();

      user.customFields = jsonMap?["custom_fields"] != null ? CustomFields.fromJSON(jsonMap!["custom_fields"]) : null;
    } catch (e) {
      print(e);
    }
    return user;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "password": password,
      "api_token": apiToken,
      if (deviceToken != null) "device_token": deviceToken,
      "phone": phone,
      "address": address,
      "bio": bio,
      "media": image?.toMap(),
    };
  }

  Map<String, dynamic> toRestrictMap() {
    return {"id": id, "email": email, "name": name, "thumb": image?.thumb, "device_token": deviceToken};
  }

  @override
  String toString() {
    final map = toMap();
    map["auth"] = auth;
    return map.toString();
  }

  bool profileCompleted() {
    return (address?.isNotEmpty ?? false) && (phone?.isNotEmpty ?? false);
  }

  void updatePhoneVerification(bool value) {
    if (customFields?.phone != null) {
      customFields!.phone!.value = value ? "1" : "0";
    }
  }
}
