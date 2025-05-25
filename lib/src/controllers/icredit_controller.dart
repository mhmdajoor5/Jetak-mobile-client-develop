import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/l10n.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/card_item.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/credit_card.dart';
import '../models/icredit_charge_simple_reesponse.dart';
import '../models/icredit_complete_sale_response.dart';
import '../models/icredit_create_sale_response.dart';
import '../repository/icredit_repository.dart';
import '../repository/user_repository.dart' as repository;

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
    ICreditChargeSimpleResponse response = await iCreditChargeSimple(
        cvv, holderName, cardNumber, expDateYymm, iCreditCreateSaleResponse);

    Helper.addCardToSP(CardItem(
      cardNumber: cardNumber,
      cardCVV: cvv,
      cardHolderName: holderName,
      cardExpirationDate: expDateYymm,
    ));

    ICreditCompleteSaleResponse completeSaleResponse =
        await iCreditCompleteSale(iCreditCreateSaleResponse, response);

    if (kDebugMode && scaffoldKey.currentContext! != null) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(completeSaleResponse.debugMessage),
      ));
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
