import 'package:flutter/material.dart';

class NotificationsButtonWidget extends StatelessWidget {
  const NotificationsButtonWidget({
    this.iconColor,
    this.labelColor,
    Key? key,
  }) : super(key: key);

  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        alignment: Alignment.topRight,
        children: <Widget>[
          Icon(
            Icons.notifications_outlined,
            color: iconColor ?? Theme.of(context).hintColor,
            size: 28,
          ),
          Container(
            child: Text(
              '0',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.merge(
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 9),
              ),
            ),
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: labelColor ?? Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
          ),
        ],
      ),
      onPressed: () {
        Navigator.of(context).pushNamed('/Notifications');
      },
    );
  }
} 