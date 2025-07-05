class ICreditChargeSimpleBody {
  final String cardNum;
  final String? token;
  final bool? createToken;
  final int currency;
  final int? id;
  final String cvv2;
  final String expDateYymm;
  final String creditboxToken;
  final double amount;

  ICreditChargeSimpleBody({
    required this.cardNum,
    this.token,
    this.createToken,
    required this.currency,
    this.id,
    required this.cvv2,
    required this.expDateYymm,
    required this.creditboxToken,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {"CardNum": cardNum, "Currency": currency, "Cvv2": cvv2, "ExpDate_YYMM": expDateYymm.split("/").reversed.join(), "CreditboxToken": creditboxToken, "Amount": (amount ~/ 100).toDouble()};
  }
}
