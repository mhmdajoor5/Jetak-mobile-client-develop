String? validatePhoneNumber(String value) {
  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = new RegExp(pattern);
  if (value.length == 0) {
    return 'Please enter mobile number';
  } else if (value.startsWith("00") || !regExp.hasMatch(value)) {
    return 'Please enter valid mobile number';
  }
  return null;
}
