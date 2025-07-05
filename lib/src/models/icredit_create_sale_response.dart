class ICreditCreateSaleResponse {
  final String clientMessage;
  final String creditboxToken;
  final int currency;
  final String debugMessage;
  final String privateSaleToken;
  final String saleToken;
  final int status;
  final double totalAmount;
  final String paymentPageUrl;

  ICreditCreateSaleResponse({
    required this.clientMessage,
    required this.creditboxToken,
    required this.currency,
    required this.debugMessage,
    required this.privateSaleToken,
    required this.saleToken,
    required this.status,
    required this.totalAmount,
    this.paymentPageUrl = '',
  });

  factory ICreditCreateSaleResponse.fromMap(Map<String, dynamic> map) {
    return ICreditCreateSaleResponse(
      clientMessage: map["ClientMessage"]?.toString() ?? '',
      creditboxToken: map["CreditboxToken"]?.toString() ?? '',
      currency: map["Currency"] ?? 0,
      debugMessage: map["DebugMessage"]?.toString() ?? '',
      privateSaleToken: map["PrivateSaleToken"]?.toString() ?? '',
      saleToken: map["SaleToken"]?.toString() ?? '',
      status: map["Status"] ?? 0,
      totalAmount: (map["TotalAmount"] is num) ? (map["TotalAmount"] as num).toDouble() : double.tryParse(map["TotalAmount"]?.toString() ?? '0') ?? 0.0,
      paymentPageUrl: map["PaymentPageUrl"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "ClientMessage": clientMessage,
      "CreditboxToken": creditboxToken,
      "Currency": currency,
      "DebugMessage": debugMessage,
      "PrivateSaleToken": privateSaleToken,
      "SaleToken": saleToken,
      "Status": status,
      "TotalAmount": totalAmount,
      "PaymentPageUrl": paymentPageUrl,
    };
  }
}
