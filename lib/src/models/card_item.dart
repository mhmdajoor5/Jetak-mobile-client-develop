class CardItem {
  final String cardNumber;
  final String cardHolderName;
  final String cardCVV;
  final String cardExpirationDate;

  CardItem(
      {required this.cardNumber,
      required this.cardHolderName,
      required this.cardCVV,
      required this.cardExpirationDate});

  String get formattedCardNumber {
    return '${cardNumber.substring(0, 3)}-${cardNumber.substring(4, 7)}-${cardNumber.substring(8, 11)}-${cardNumber.substring(12, 15)}';
  }

  String get maskedCardNumber {
    return '****-****-****-${cardNumber.substring(12, 15)}';
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["cardNumber"] = cardNumber;
    map["cardHolderName"] = cardHolderName;
    map["cardCVV"] = cardCVV;
    map["cardExpirationDate"] = cardExpirationDate;
    return map;
  }

  factory CardItem.fromMap(Map<String, dynamic> map) {
    return CardItem(
      cardNumber: map["cardNumber"],
      cardHolderName: map["cardHolderName"],
      cardCVV: map["cardCVV"],
      cardExpirationDate: map["cardExpirationDate"],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardItem &&
          runtimeType == other.runtimeType &&
          cardNumber == other.cardNumber &&
          cardHolderName == other.cardHolderName &&
          cardCVV == other.cardCVV &&
          cardExpirationDate == other.cardExpirationDate;

  @override
  int get hashCode => cardNumber.hashCode ^ cardHolderName.hashCode ^ cardCVV.hashCode ^ cardExpirationDate.hashCode;
}
