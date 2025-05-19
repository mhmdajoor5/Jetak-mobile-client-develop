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
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/Notifications');
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFFF1F1F1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Icon(
              Icons.notifications_outlined,
              color: iconColor ?? Color(0xFF292D32),
              size: 24,
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 15,
                height: 15,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: labelColor ?? Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '0', // TODO: Replace with real count
                  style: TextStyle(fontSize: 9, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
