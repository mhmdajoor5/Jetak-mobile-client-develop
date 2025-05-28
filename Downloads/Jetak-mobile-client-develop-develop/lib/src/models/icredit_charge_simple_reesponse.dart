class ICreditChargeSimpleResponse {
  final double amount;
  final String cardNum;
  final String customerTransactionId;
  final int status;
  final String token;

  ICreditChargeSimpleResponse({required this.amount, required this.cardNum, required this.customerTransactionId, required this.status, required this.token});

  factory ICreditChargeSimpleResponse.fromMap(Map<String, dynamic> map) {
    final parsedAmount = (map["Amount"] is int) ? (map["Amount"] as int).toDouble() : (map["Amount"] as num?)?.toDouble() ?? 0.0;

    return ICreditChargeSimpleResponse(
      amount: parsedAmount,
      cardNum: map["CardNum"]?.toString() ?? '',
      customerTransactionId: map["CustomerTransactionId"]?.toString() ?? '',
      status: map["Status"] ?? 0,
      token: map["Token"]?.toString() ?? '',
    );
  }
}
