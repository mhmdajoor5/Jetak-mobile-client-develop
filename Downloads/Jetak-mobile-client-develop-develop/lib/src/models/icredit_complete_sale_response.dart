class ICreditCompleteSaleResponse {
  final dynamic clientMessage;
  final dynamic debugMessage;
  final String documentIdentity;
  final String documentLink;
  final int documentNumber;
  final int documentType;
  final int printStatus;
  final int status;

  ICreditCompleteSaleResponse({
    required this.clientMessage,
    required this.debugMessage,
    required this.documentIdentity,
    required this.documentLink,
    required this.documentNumber,
    required this.documentType,
    required this.printStatus,
    required this.status,
  });

  factory ICreditCompleteSaleResponse.fromMap(Map<String, dynamic> map) {
    return ICreditCompleteSaleResponse(
      clientMessage: map["ClientMessage"],
      debugMessage: map["DebugMessage"],
      documentIdentity: map["DocumentIdentity"]?.toString() ?? '',
      documentLink: map["DocumentLink"]?.toString() ?? '',
      documentNumber: map["DocumentNumber"] ?? 0,
      documentType: map["DocumentType"] ?? 0,
      printStatus: map["PrintStatus"] ?? 0,
      status: map["Status"] ?? 0,
    );
  }
}
