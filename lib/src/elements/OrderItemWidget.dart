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
                      children: <Widget>[
                        Text('${S.of(context).order_id}: #${widget.order.id}'),
                        Text(DateFormat('dd-MM-yyyy | HH:mm').format(widget.order.dateTime), style: Theme.of(context).textTheme.bodySmall),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headlineLarge),
                        Text('${widget.order.payment.method}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    children: <Widget>[
                      Column(
                        children: List.generate(widget.order.foodOrders.length, (indexFood) {
                          return FoodOrderItemWidget(heroTag: 'mywidget.orders', order: widget.order, foodOrder: widget.order.foodOrders.elementAt(indexFood));
                        }),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Column(
                          children: <Widget>[
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
                            Row(
                              children: <Widget>[
                                Expanded(child: Text(S.of(context).total, style: Theme.of(context).textTheme.bodyLarge)),
                                Helper.getPrice(Helper.getTotalOrdersPrice(widget.order), context, style: Theme.of(context).textTheme.headlineLarge),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Wrap(
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
                      child: Wrap(children: <Widget>[Text(S.of(context).view)]),
                      padding: EdgeInsets.symmetric(horizontal: 0),
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
                        child: Wrap(children: <Widget>[Text(S.of(context).cancel + " ")]),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                  ],
                ),
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
            widget.order.active ? '${widget.order.orderStatus.status}' : S.of(context).canceled,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.bodySmall?.merge(TextStyle(height: 1, color: Theme.of(context).primaryColor)),
          ),
        ),
      ],
    );
  }
}
