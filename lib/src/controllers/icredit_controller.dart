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
    try {
      print('=== بدء عملية الدفع عبر iCredit ===');
      print('وقت بدء العملية: ${DateTime.now()}');
      print('بيانات البطاقة:');
      print('- رقم البطاقة: $cardNumber');
      print('- اسم حامل البطاقة: $holderName');
      print('- تاريخ الانتهاء: $expDateYymm');
      print('- رمز الأمان: $cvv');
      print('بيانات البيع:');
      print('- رمز البيع: ${iCreditCreateSaleResponse.saleToken}');
      print('- رمز الصندوق: ${iCreditCreateSaleResponse.creditboxToken}');
      print('- المبلغ الإجمالي: ${iCreditCreateSaleResponse.totalAmount}');
      
      print('\nجاري تنفيذ عملية الشحن...');
      ICreditChargeSimpleResponse response = await iCreditChargeSimple(
          cvv, holderName, cardNumber, expDateYymm, iCreditCreateSaleResponse);
      print('نتيجة عملية الشحن:');
      // print('- الحالة: ${response.status}');
      // print('- معرف المعاملة: ${response.customerTransactionId}');
      // print('- رسالة الخطأ: ${response.errorMessage}');
      //
      // if (response.status != 0) {
      //   throw Exception('فشلت عملية الشحن: ${response.errorMessage}');
      // }

      print('\nجاري حفظ بيانات البطاقة...');
      Helper.addCardToSP(CardItem(
        cardNumber: cardNumber,
        cardCVV: cvv,
        cardHolderName: holderName,
        cardExpirationDate: expDateYymm,
      ));
      print('تم حفظ بيانات البطاقة بنجاح');

      print('\nجاري إكمال عملية البيع...');
      ICreditCompleteSaleResponse completeSaleResponse =
          await iCreditCompleteSale(iCreditCreateSaleResponse, response);
      print('نتيجة إكمال عملية البيع:');
      print('- الحالة: ${completeSaleResponse.status}');
      print('- رسالة التصحيح: ${completeSaleResponse.debugMessage}');

      if (kDebugMode) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(completeSaleResponse.debugMessage),
          backgroundColor: completeSaleResponse.status == 0 ? Colors.green : Colors.red,
        ));
      }

      if (completeSaleResponse.status == 0) {
        print('\n=== عملية الدفع عبر iCredit نجحت ===');
        print('وقت انتهاء العملية: ${DateTime.now()}');
      } else {
        print('\n=== عملية الدفع عبر iCredit فشلت ===');
        print('سبب الفشل: ${completeSaleResponse.debugMessage}');
        print('وقت انتهاء العملية: ${DateTime.now()}');
        throw Exception('فشلت عملية إكمال البيع: ${completeSaleResponse.debugMessage}');
      }
    } catch (e) {
      print('\n=== حدث خطأ في عملية الدفع ===');
      print('نوع الخطأ: ${e.runtimeType}');
      print('رسالة الخطأ: $e');
      print('وقت حدوث الخطأ: ${DateTime.now()}');
      
      if (kDebugMode) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text('حدث خطأ في عملية الدفع: $e'),
          backgroundColor: Colors.red,
        ));
      }
      rethrow;
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
