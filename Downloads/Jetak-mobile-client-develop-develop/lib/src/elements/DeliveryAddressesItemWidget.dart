import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';

// ignore: must_be_immutable
class DeliveryAddressesItemWidget extends StatelessWidget {
  final String? heroTag;
  final model.Address? address;
  final PaymentMethod? paymentMethod;
  final ValueChanged<model.Address>? onPressed;
  final ValueChanged<model.Address>? onLongPress;
  final ValueChanged<model.Address>? onDismissed;
  final bool isSelected;

  DeliveryAddressesItemWidget({Key? key, this.heroTag, this.address, this.onPressed, this.onLongPress, this.onDismissed, this.paymentMethod, this.isSelected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onDismissed != null) {
      return Dismissible(
        key: Key(address?.id ?? UniqueKey().toString()),
        onDismissed: (direction) {
          if (onDismissed != null && address != null) {
            onDismissed!(address!);
          }
        },
        child: buildItem(context),
      );
    } else {
      return buildItem(context);
    }
  }

  InkWell buildItem(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary,
      focusColor: Theme.of(context).colorScheme.secondary,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        if (onPressed != null && address != null) onPressed!(address!);
      },
      onLongPress: () {
        if (onLongPress != null && address != null) onLongPress!(address!);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.2) : Theme.of(context).primaryColor.withOpacity(0.9),
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: (address?.isDefault ?? false) || (paymentMethod?.selected ?? false) ? Theme.of(context).colorScheme.secondary : Theme.of(context).focusColor,
                  ),
                  child: Icon((paymentMethod?.selected ?? false) ? Icons.check : Icons.place, color: Theme.of(context).primaryColor, size: 38),
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
                        if ((address?.description ?? '').isNotEmpty) Text(address!.description ?? '', overflow: TextOverflow.fade, softWrap: false, style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          address?.address ?? S.of(context).unknown,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: (address?.description ?? '').isNotEmpty ? Theme.of(context).textTheme.bodySmall : Theme.of(context).textTheme.titleMedium,
                        ),
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
