import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import '../controllers/icredit_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../models/icredit_create_sale_response.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/credit_card.dart';
import '../models/route_argument.dart';
import '../helpers/icredit_validator.dart';

// ignore: must_be_immutable
class ICreditPaymentWidget extends StatefulWidget {
  Object? routeArgument;

  ICreditPaymentWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _ICreditPaymentWidgetState createState() => _ICreditPaymentWidgetState();
}

class _ICreditPaymentWidgetState extends StateMVC<ICreditPaymentWidget> {
  late ICreditController _con;

  bool isLoading = false;
  String? cardValidationError;

  _ICreditPaymentWidgetState() : super(ICreditController()) {
    _con = controller as ICreditController;
  }

  bool isLightTheme = true;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = true;
  bool useFloatingAnimation = true;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).primaryColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 250,
                          child: CreditCardWidget(
                            enableFloatingCard: useFloatingAnimation,
                            glassmorphismConfig: _getGlassmorphismConfig(),
                            cardNumber: cardNumber,
                            expiryDate: expiryDate,
                            cardHolderName: cardHolderName,
                            cvvCode: cvvCode,
                            frontCardBorder: useGlassMorphism
                                ? null
                                : Border.all(
                                    color: Theme.of(context).primaryColor),
                            backCardBorder: useGlassMorphism
                                ? null
                                : Border.all(
                                    color: Theme.of(context).primaryColor),
                            showBackView: isCvvFocused,
                            obscureCardNumber: true,
                            obscureCardCvv: true,
                            isHolderNameVisible: true,
                            cardBgColor: Theme.of(context).colorScheme.secondary,
                            // backgroundImage: useBackgroundImage
                            //     ? 'assets/img/card_bg.png'
                            //     : null,
                            isSwipeGestureEnabled: true,
                            onCreditCardWidgetChange:
                                (CreditCardBrand creditCardBrand) {},
                            customCardTypeIcons: <CustomCardTypeIcon>[
                              CustomCardTypeIcon(
                                cardType: CardType.mastercard,
                                cardImage: Image.asset(
                                  'assets/img/carry-eats-hub-logo.png',
                                  height: 48,
                                  width: 48,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // عرض رسالة خطأ إذا كانت البطاقة غير مدعومة
                        if (cardValidationError != null)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    cardValidationError!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // معلومات حول بطاقات iCredit المدعومة
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Theme.of(context).primaryColor, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'يتم قبول بطاقات iCredit فقط (تبدأ بـ 4580 28)',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              inputConfiguration: const InputConfiguration(
                                cardNumberDecoration: InputDecoration(
                                    labelText: 'رقم البطاقة',
                                    hintText: '4580 28XX XXXX XXXX',
                                    border: OutlineInputBorder()),
                                expiryDateDecoration: InputDecoration(
                                    labelText: 'تاريخ انتهاء الصلاحية',
                                    hintText: 'MM/YY',
                                    border: OutlineInputBorder()),
                                cvvCodeDecoration: InputDecoration(
                                    labelText: 'رمز الأمان',
                                    hintText: 'XXX',
                                    border: OutlineInputBorder()),
                                cardHolderDecoration: InputDecoration(
                                    labelText: 'اسم حامل البطاقة',
                                    border: OutlineInputBorder()),
                              ),
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: BlockButtonWidget(
                                text: Text(
                                  'إكمال الدفع',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Theme.of(context).colorScheme.secondary,
                                onPressed: _onValidate,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: isLoading,
            child: InkWell(
              onTap: () {},
              child: Container(
                color: Colors.grey.withOpacity(0.6),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onValidate() async {
    print('--- بدء عملية التحقق والدفع عبر iCredit (icredit_payment_page.dart) ---');
    print('بيانات البطاقة: cardNumber=$cardNumber, holderName=$cardHolderName, expiryDate=$expiryDate, cvv=$cvvCode');
    
    // التحقق من صحة البطاقة باستخدام الـ validator الجديد
    ICreditValidationResult validationResult = ICreditValidator.validateICreditCard(cardNumber);
    
    if (!validationResult.isValid) {
      setState(() {
        cardValidationError = validationResult.errorMessage;
      });
      print('فشل التحقق من البطاقة: ${validationResult.errorMessage}');
      return;
    }
    
    // التحقق من باقي البيانات
    if (!ICreditValidator.isValidExpiryDate(expiryDate)) {
      setState(() {
        cardValidationError = 'تاريخ انتهاء الصلاحية غير صحيح أو منتهي الصلاحية';
      });
      return;
    }
    
    if (!ICreditValidator.isValidCVV(cvvCode)) {
      setState(() {
        cardValidationError = 'رمز الأمان CVV غير صحيح (يجب أن يكون 3 أرقام)';
      });
      return;
    }
    
    if (!ICreditValidator.isValidCardHolderName(cardHolderName)) {
      setState(() {
        cardValidationError = 'اسم حامل البطاقة غير صحيح';
      });
      return;
    }
    
    // مسح رسالة الخطأ إذا كانت البيانات صحيحة
    setState(() {
      cardValidationError = null;
    });
    
    if (formKey.currentState?.validate() ?? false) {
      print('✅ التحقق من البطاقة نجح - بطاقة iCredit صحيحة');

      setState(() {
        isLoading = true;
      });

      if (widget.routeArgument == null ||
          (widget.routeArgument is CreditCard)) {
        CreditCard creditCard = await _con.saveCreditCard(
          cvvCode,
          cardHolderName,
          cardNumber.replaceAll(" ", ""),
          expiryDate,
        );

        print('تم حفظ البطاقة محلياً: ${creditCard.number}');
        Navigator.pop(context, creditCard);
        return;
      }

      await _con.saveCreditCard(
        cvvCode,
        cardHolderName,
        cardNumber.replaceAll(" ", ""),
        expiryDate,
      );
      print('تم حفظ البطاقة محلياً: $cardNumber');
      await _con.completeSale(
          cvvCode,
          cardHolderName,
          cardNumber.replaceAll(" ", ""),
          expiryDate,
          widget.routeArgument as ICreditCreateSaleResponse);

      setState(() {
        isLoading = false;
      });
    } else {
      print('❌ فشل التحقق من النموذج');
    }
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Theme.of(context).primaryColor.withAlpha(50),
        Theme.of(context).primaryColor.withAlpha(50)
      ],
      stops: const <double>[0.3, 0],
    );

    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      
      // التحقق من البطاقة في الوقت الفعلي
      if (cardNumber.isNotEmpty) {
        ICreditValidationResult validationResult = ICreditValidator.validateICreditCard(cardNumber);
        if (!validationResult.isValid && cardNumber.replaceAll(RegExp(r'[^\d]'), '').length >= 6) {
          cardValidationError = validationResult.errorMessage;
        } else {
          cardValidationError = null;
        }
      } else {
        cardValidationError = null;
      }
    });
  }
}
