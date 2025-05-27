class ICreditCompleteSaleBody {
  final String customerTransactionId;
  final String saleToken;

  ICreditCompleteSaleBody({required this.customerTransactionId, required this.saleToken});

  Map<String, dynamic> toMap() {
    return {"CustomerTransactionId": customerTransactionId, "SaleToken": saleToken};
  }
}
