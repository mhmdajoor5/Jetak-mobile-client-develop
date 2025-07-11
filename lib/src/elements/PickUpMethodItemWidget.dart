import 'package:flutter/material.dart';

import '../models/payment_method.dart';

// ignore: must_be_immutable
class PickUpMethodItem extends StatefulWidget {
  PaymentMethod paymentMethod;
  ValueChanged<PaymentMethod> onPressed;

  PickUpMethodItem({Key? key, required this.paymentMethod, required this.onPressed}) : super(key: key);

  @override
  _PickUpMethodItemState createState() => _PickUpMethodItemState();
}

class _PickUpMethodItemState extends State<PickUpMethodItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      focusColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        widget.onPressed(widget.paymentMethod);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), image: DecorationImage(image: AssetImage(widget.paymentMethod.logo), fit: BoxFit.fill)),
                ),
                Container(
                  height: widget.paymentMethod.selected ? 60 : 0,
                  width: widget.paymentMethod.selected ? 60 : 0,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: Theme.of(context).colorScheme.secondary.withOpacity(widget.paymentMethod.selected ? 0.74 : 0)),
                  child: Icon(Icons.check, size: widget.paymentMethod.selected ? 44 : 0, color: Theme.of(context).primaryColor.withOpacity(widget.paymentMethod.selected ? 0.9 : 0)),
                ),
              ],
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.paymentMethod.name, overflow: TextOverflow.ellipsis, maxLines: 2, style: Theme.of(context).textTheme.titleMedium),
                        Text(widget.paymentMethod.description, overflow: TextOverflow.fade, softWrap: false, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
