import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:restaurantcustomer/src/pages/RecentOrdersWidget.dart';

import '../../generated/l10n.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../helpers/helper.dart';
import '../models/payment.dart';
import '../models/route_argument.dart';
import 'delivery_pickup.dart';

class OrderSuccessWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  OrderSuccessWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _OrderSuccessWidgetState createState() => _OrderSuccessWidgetState();
}

class _OrderSuccessWidgetState extends StateMVC<OrderSuccessWidget> {
  late CheckoutController _con;

  _OrderSuccessWidgetState() : super(CheckoutController()) {
    _con = controller as CheckoutController;
  }

  @override
  void initState() {
    _con.payment = new Payment(method: widget.routeArgument?.param);
    _con.listenForCarts();
    super.initState();
  }

  // دالة للتحقق من أن الطلب للاستلام (pickup)
  bool _isPickupOrder() {
    // التحقق من طريقة الدفع - Cash on Pickup disabled
    if (_con.payment?.method == 'Pay on Pickup') {
      return true;
    }
    
    // التحقق من نوع الطلب من routeArgument - Cash on Pickup disabled
    String? orderType = widget.routeArgument?.param;
    if (orderType == 'Pay on Pickup' || 
        orderType == 'iCredit Pickup') {
      return true;
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //   onWillPop: () {
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(builder: (_) => RecentOrdersWidget(fromProfile: false)), // 👈 مهم
    //     );
    //     return Future.value(true);
    //   },
     // child:
     return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/Pages',
                    (route) => false,
                arguments: 0,
              );
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),

          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).confirmation,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body:
            _con.carts.isEmpty
                ? CircularLoadingWidget(height: 500)
                : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      alignment: AlignmentDirectional.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 50,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      Colors.green.withOpacity(1),
                                      Colors.green.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                                child:
                                    _con.loading
                                        ? Padding(
                                          padding: EdgeInsets.all(55),
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                  Color
                                                >(
                                                  Theme.of(
                                                    context,
                                                  ).scaffoldBackgroundColor,
                                                ),
                                          ),
                                        )
                                        : Icon(
                                          Icons.check,
                                          color:
                                              Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                          size: 90,
                                        ),
                              ),
                              Positioned(
                                right: -30,
                                bottom: -50,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(150),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: -20,
                                top: -50,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(150),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Opacity(
                            opacity: 0.4,
                            child: Text(
                              S
                                  .of(context)
                                  .your_order_has_been_successfully_submitted,
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.displaySmall?.merge(
                                TextStyle(fontWeight: FontWeight.w300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 255,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).focusColor.withOpacity(0.15),
                              offset: Offset(0, -2),
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      S.of(context).subtotal,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  Helper.getPrice(
                                    _con.subTotal,
                                    context,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 3),
                              _isPickupOrder()
                                  ? SizedBox(height: 0)
                                  : Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          S.of(context).delivery_fee,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyLarge,
                                        ),
                                      ),
                                      Helper.getPrice(
                                        _con.carts[0].food?.restaurant.deliveryFee ?? 0,
                                        context,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                              SizedBox(height: 3),
                              // تم إزالة عرض الضريبة لأن الأسعار تدخل مع الضريبة مسبقاً
                              // Row(
                              //   children: <Widget>[
                              //     Expanded(
                              //       child: Text(
                              //         "${S.of(context).tax} (${_con.carts[0].food?.restaurant.defaultTax}%)",
                              //         style:
                              //             Theme.of(context).textTheme.bodyLarge,
                              //       ),
                              //     ),
                              //     Helper.getPrice(
                              //       _con.taxAmount,
                              //       context,
                              //       style:
                              //           Theme.of(context).textTheme.titleMedium,
                              //     ),
                              //   ],
                              // ),
                              Divider(height: 30),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      S.of(context).total,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.headlineSmall,
                                    ),
                                  ),
                                  Helper.getPrice(
                                    _isPickupOrder()
                                        ? _con.total - _con.deliveryFee
                                        : _con.total,
                                    context,
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 40,
                                child: MaterialButton(
                                  elevation: 0,
                                  focusElevation: 0,
                                  highlightElevation: 0,
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (_) => RecentOrdersWidget()),
                                    );
                                  },
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  shape: StadiumBorder(),
                                  child: Text(
                                    S.of(context).my_orders,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      );
  }
}
