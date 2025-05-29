import 'dart:convert';
import 'dart:io';

import '../models/icredit_charge_simple_reesponse.dart';
import '../models/icredit_complete_sale_body.dart';
import '../models/icredit_complete_sale_response.dart';
import '../models/icredit_create_sale_body.dart';
import '../models/icredit_create_sale_response.dart';
import '../models/user.dart';
import '../models/icredit_charge_simple_body.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:http/http.dart' as http;

Future<ICreditCreateSaleResponse> iCreditCreateSale(List<Item> items) async {
  User user = userRepo.currentUser.value;
  String firstName = user.name?.split(' ').first ?? '';
  String lastName = (user.name?.split(' ').length ?? 0) > 1 ? user.name!.split(' ')[1] : '';
  String url = "https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/CreateSale";
  String privateGroupToken = "30502c15-5895-4e9a-bea1-e0d366a69572"; // prod

  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.acceptHeader: 'application/json'},
    body: json.encode(ICreditSaleBody(groupPrivateToken: privateGroupToken, saleType: 1, items: items).toMap()),
  );

  return ICreditCreateSaleResponse.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<ICreditChargeSimpleResponse> iCreditChargeSimple(String cvv, String holderName, String cardNumber, String expDateYymm, ICreditCreateSaleResponse saleResponse) async {
  String url = "https://pci.rivhit.co.il/api/iCreditRestApiService.svc/ChargeSimple";

  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.acceptHeader: 'application/json'},
    body: json.encode(
      ICreditChargeSimpleBody(cardNum: cardNumber, currency: 1, cvv2: cvv, expDateYymm: expDateYymm, creditboxToken: saleResponse.creditboxToken, amount: saleResponse.totalAmount).toMap(),
    ),
  );

  return ICreditChargeSimpleResponse.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<ICreditCompleteSaleResponse> iCreditCompleteSale(ICreditCreateSaleResponse saleResponse, ICreditChargeSimpleResponse chargeResponse) async {
  String url = "https://icredit.rivhit.co.il/API/PaymentPageRequest.svc/CompleteSale";

  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json', HttpHeaders.acceptHeader: 'application/json'},
    body: json.encode(ICreditCompleteSaleBody(customerTransactionId: chargeResponse.customerTransactionId, saleToken: saleResponse.saleToken).toMap()),
  );

  return ICreditCompleteSaleResponse.fromMap(jsonDecode(response.body) as Map<String, dynamic>);
}
