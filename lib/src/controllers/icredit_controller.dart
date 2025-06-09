import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../helpers/helper.dart';
import '../models/card_item.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/credit_card.dart';
import '../models/icredit_charge_simple_reesponse.dart';
import '../models/icredit_complete_sale_response.dart';
import '../models/icredit_create_sale_response.dart';
import '../repository/icredit_repository.dart';

class ICreditController extends ControllerMVC {
  late GlobalKey<ScaffoldState> scaffoldKey;

  PayPalController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> completeSale(
      String cvv,
      String holderName,
      String cardNumber,
      String expDateYymm,
      ICreditCreateSaleResponse iCreditCreateSaleResponse) async {
    print('--- بدء عملية الدفع عبر iCredit ---');
    print('بيانات البطاقة: cardNumber=$cardNumber, holderName=$holderName, expDateYymm=$expDateYymm, cvv=$cvv');
    print('بيانات البيع: saleToken=${iCreditCreateSaleResponse.saleToken}, creditboxToken=${iCreditCreateSaleResponse.creditboxToken}, totalAmount=${iCreditCreateSaleResponse.totalAmount}');
    
    ICreditChargeSimpleResponse response = await iCreditChargeSimple(
        cvv, holderName, cardNumber, expDateYymm, iCreditCreateSaleResponse);
    print('رد iCreditChargeSimple:');
    print(response);
    print('status: ${response.status}, customerTransactionId: ${response.customerTransactionId}');

    Helper.addCardToSP(CardItem(
      cardNumber: cardNumber,
      cardCVV: cvv,
      cardHolderName: holderName,
      cardExpirationDate: expDateYymm,
    ));

    ICreditCompleteSaleResponse completeSaleResponse =
        await iCreditCompleteSale(iCreditCreateSaleResponse, response);
    print('رد iCreditCompleteSale:');
    print(completeSaleResponse);
    print('status: ${completeSaleResponse.status}, debugMessage: ${completeSaleResponse.debugMessage}');

    if (kDebugMode) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(completeSaleResponse.debugMessage),
      ));
    }
    if (completeSaleResponse.status == 0) {
      print('--- عملية الدفع عبر iCredit نجحت ---');
    } else {
      print('--- عملية الدفع عبر iCredit فشلت ---');
    }
  }

  Future<CreditCard> saveCreditCard(
    String cvvCode,
    String cardHolderName,
    String cardNumber,
    String expiryDate,
  ) async {
    CreditCard creditCard = CreditCard();
    creditCard.cvc = cvvCode;
    creditCard.holderName = cardHolderName;
    creditCard.expiryDate = expiryDate;
    creditCard.number = cardNumber;
    await Helper.addCardToSP(CardItem(
      cardNumber: cardNumber,
      cardCVV: cvvCode,
      cardHolderName: cardHolderName,
      cardExpirationDate: expiryDate,
    ));
    return creditCard;
  }
}
