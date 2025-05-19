class CustomFields {
  CustomFieldValue? phone;
  CustomFieldValue? bio;
  CustomFieldValue? address;
  CustomFieldValue? verifiedPhone;

  CustomFields({this.phone, this.bio, this.address, this.verifiedPhone});

  factory CustomFields.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return CustomFields(
        phone: jsonMap?['phone'] != null ? CustomFieldValue.fromJSON(jsonMap!['phone']) : null,
        bio: jsonMap?['bio'] != null ? CustomFieldValue.fromJSON(jsonMap!['bio']) : null,
        address: jsonMap?['address'] != null ? CustomFieldValue.fromJSON(jsonMap!['address']) : null,
        verifiedPhone: jsonMap?['verifiedPhone'] != null ? CustomFieldValue.fromJSON(jsonMap!['verifiedPhone']) : null,
      );
    } catch (e) {
      print(e);
      return CustomFields();
    }
  }
}

class CustomFieldValue {
  String value;
  String view;
  String name;

  CustomFieldValue({this.value = '', this.view = '', this.name = ''});

  factory CustomFieldValue.fromJSON(Map<String, dynamic>? jsonMap) {
    try {
      return CustomFieldValue(value: jsonMap?['value']?.toString() ?? '', view: jsonMap?['view']?.toString() ?? '', name: jsonMap?['name']?.toString() ?? '');
    } catch (e) {
      print(e);
      return CustomFieldValue();
    }
  }
}
