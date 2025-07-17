import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import '../controllers/icredit_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../models/icredit_create_sale_response.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/credit_card.dart';
import '../models/route_argument.dart';

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
      appBar: AppBar(
        leading: IconButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          icon: Icon(Icons.arrow_back),
          color: Theme.of(context).hintColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).iCredit,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Stack(
        children: [
          Builder(
            builder: (BuildContext context) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.secondary,
                      BlendMode.softLight,
                    ),
                    image: ExactAssetImage(
                      isLightTheme
                          ? 'assets/img/bg-light.png'
                          : 'assets/img/bg-dark.png',
                    ),
                    fit: BoxFit.fill,
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
                                    labelText: 'Number',
                                    hintText: 'XXXX XXXX XXXX XXXX',
                                    border: OutlineInputBorder()),
                                expiryDateDecoration: InputDecoration(
                                    labelText: 'Expired Date',
                                    hintText: 'XX/XX',
                                    border: OutlineInputBorder()),
                                cvvCodeDecoration: InputDecoration(
                                    labelText: 'CVV',
                                    hintText: 'XXX',
                                    border: OutlineInputBorder()),
                                cardHolderDecoration: InputDecoration(
                                    labelText: 'Card Holder',
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
                                  S.of(context).complete_payment,
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
    print('--- بدء عملية الدفع عبر iCredit (icredit_payment_page.dart) ---');
    print('بيانات البطاقة: cardNumber=$cardNumber, holderName=$cardHolderName, expiryDate=$expiryDate, cvv=$cvvCode');
    if (formKey.currentState?.validate() ?? false) {
      print('valid!');

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
      print('invalid!');
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
    });
  }
}
