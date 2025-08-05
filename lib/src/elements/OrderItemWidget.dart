import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/route_argument.dart';
import 'FoodOrderItemWidget.dart';

class OrderItemWidget extends StatefulWidget {
  final bool expanded;
  final Order order;
  final ValueChanged<Order>? onCanceled;

  OrderItemWidget({Key? key, this.expanded = false, required this.order, this.onCanceled}) : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: widget.order.active ? 1 : 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 14),
                padding: EdgeInsets.only(top: 20, bottom: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
                ),
                child: Theme(
                  data: theme,
                  child: ExpansionTile(
                    initiallyExpanded: widget.expanded,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${S.of(context).order_id}: #${widget.order.id}',
                          style: Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                    trailing: Container(
                      constraints: BoxConstraints(maxWidth: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Helper.getPrice(
                              Helper.getTotalOrdersPrice(widget.order), 
                              context, 
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 16)
                            ),
                          ),
                          SizedBox(height: 2),
                          Flexible(
                            child: Text(
                              widget.order.payment.method.isNotEmpty 
                                  ? widget.order.payment.method 
                                  : S.of(context).pending_payment ?? 'Pending Payment',
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: <Widget>[
                      // طباعة معلومات الطلب للتحقق
                      Builder(
                        builder: (context) {
                          print('🔍 عرض الطلب ${widget.order.id}:');
                          print('   - عدد الأطعمة: ${widget.order.foodOrders.length}');
                          print('   - إجمالي الطعام: ${Helper.getFoodTotalPrice(widget.order)}');
                          print('   - الضريبة: ${Helper.getTaxOrder(widget.order)}');
                          print('   - المجموع الكلي: ${Helper.getTotalOrdersPrice(widget.order)}');
                          return SizedBox.shrink();
                        },
                      ),
                      if (widget.order.foodOrders.isNotEmpty)
                        Column(
                          children: List.generate(widget.order.foodOrders.length, (indexFood) {
                            return FoodOrderItemWidget(heroTag: 'mywidget.orders', order: widget.order, foodOrder: widget.order.foodOrders.elementAt(indexFood));
                          }),
                        )
                      else
                        // عرض placeholder عندما لا توجد تفاصيل المنتجات
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.grey[400],
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Food Items',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Order details not available',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Helper.getPrice(
                                    Helper.getFoodTotalPrice(widget.order),
                                    context,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    "x 1",
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(child: Text(S.of(context).subtotal ?? 'Subtotal', style: Theme.of(context).textTheme.bodyLarge)),
                                Helper.getPrice(Helper.getFoodTotalPrice(widget.order), context, style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(child: Text(S.of(context).delivery_fee, style: Theme.of(context).textTheme.bodyLarge)),
                                Helper.getPrice(widget.order.deliveryFee, context, style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(child: Text('${S.of(context).tax} (${widget.order.tax}%)', style: Theme.of(context).textTheme.bodyLarge)),
                                Helper.getPrice(Helper.getTaxOrder(widget.order), context, style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: <Widget>[
                                Expanded(child: Text(S.of(context).total, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold))),
                                Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.end,
                children: <Widget>[
                  MaterialButton(
                    elevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    onPressed: () {
                      print("mElkerm !!!!!!!!!! ##### Order ID: ${widget.order.id}");
              
                      Navigator.of(context).pushNamed('/Tracking', arguments: RouteArgument(id: widget.order.id));
                    },
                    textColor: Theme.of(context).hintColor,
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Wrap(children: <Widget>[Text(S.of(context).view)]),
                  ),
                  if (widget.order.canCancelOrder())
                    MaterialButton(
                      elevation: 0,
                      focusElevation: 0,
                      highlightElevation: 0,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Wrap(spacing: 10, children: <Widget>[Icon(Icons.report, color: Colors.orange), Text(S.of(context).confirmation, style: TextStyle(color: Colors.orange))]),
                              content: Text(S.of(context).areYouSureYouWantToCancelThisOrder),
                              contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                              actions: <Widget>[
                                MaterialButton(
                                  elevation: 0,
                                  focusElevation: 0,
                                  highlightElevation: 0,
                                  child: Text(S.of(context).yes, style: TextStyle(color: Theme.of(context).hintColor)),
                                  onPressed: () {
                                    if (widget.onCanceled != null) {
                                      widget.onCanceled!(widget.order);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                                MaterialButton(
                                  elevation: 0,
                                  focusElevation: 0,
                                  highlightElevation: 0,
                                  child: Text(S.of(context).close, style: TextStyle(color: Colors.orange)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      textColor: Theme.of(context).hintColor,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Wrap(children: <Widget>[Text(S.of(context).cancel + " ")]),
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsetsDirectional.only(start: 20),
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 28,
          width: 140,
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100)), color: widget.order.active ? Theme.of(context).colorScheme.secondary : Colors.redAccent),
          alignment: AlignmentDirectional.center,
          child: Text(
            widget.order.active ? widget.order.orderStatus.status : S.of(context).canceled,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: Theme.of(context).textTheme.bodySmall?.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor)),
          ),
        ),
      ],
    );
  }
}
