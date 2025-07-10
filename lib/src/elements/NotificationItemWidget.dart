import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../helpers/helper.dart';
import '../helpers/swipe_widget.dart';
import '../models/notification.dart' as model;

class NotificationItemWidget extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnRead;
  final VoidCallback onRemoved;

  NotificationItemWidget({
    Key? key, 
    required this.notification, 
    this.onTap,
    required this.onMarkAsRead, 
    required this.onMarkAsUnRead, 
    required this.onRemoved
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OnSlide(
      backgroundColor: notification.read ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).primaryColor,
      items: <ActionItems>[
        ActionItems(
          icon: notification.read 
            ? Icon(Icons.panorama_fish_eye, color: Theme.of(context).colorScheme.secondary) 
            : Icon(Icons.brightness_1, color: Theme.of(context).colorScheme.secondary),
          onPress: () {
            if (notification.read) {
              onMarkAsUnRead();
            } else {
              onMarkAsRead();
            }
          },
        ),
        ActionItems(
          icon: Padding(
            padding: const EdgeInsets.only(right: 10), 
            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.secondary)
          ),
          onPress: () {
            onRemoved();
          },
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: notification.read 
              ? Theme.of(context).scaffoldBackgroundColor 
              : Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: notification.read 
                ? Colors.transparent 
                : Theme.of(context).primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Theme.of(context).focusColor.withOpacity(0.7), 
                          Theme.of(context).focusColor.withOpacity(0.05)
                        ],
                      ),
                    ),
                    child: Icon(
                      _getNotificationIcon(),
                      color: Theme.of(context).scaffoldBackgroundColor, 
                      size: 40
                    ),
                  ),
                  // Unread indicator
                  if (!notification.read)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  Positioned(
                    right: -30,
                    bottom: -50,
                    child: Container(
                      width: 100, 
                      height: 100, 
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15), 
                        borderRadius: BorderRadius.circular(150)
                      )
                    ),
                  ),
                  Positioned(
                    left: -20,
                    top: -50,
                    child: Container(
                      width: 120, 
                      height: 120, 
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15), 
                        borderRadius: BorderRadius.circular(150)
                      )
                    ),
                  ),
                ],
              ),
              SizedBox(width: 15),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    // Notification title
                    Text(
                      notification.getNotificationTitle(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium!.merge(
                        TextStyle(
                          fontWeight: notification.read ? FontWeight.w400 : FontWeight.w600,
                          color: notification.read 
                            ? Theme.of(context).textTheme.bodyMedium!.color 
                            : Theme.of(context).textTheme.titleMedium!.color,
                        )
                      ),
                    ),
                    // Notification message
                    Text(
                      notification.getNotificationMessage(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium!.merge(
                        TextStyle(
                          fontWeight: notification.read ? FontWeight.w300 : FontWeight.w400,
                          color: notification.read 
                            ? Theme.of(context).textTheme.bodySmall!.color 
                            : Theme.of(context).textTheme.bodyMedium!.color,
                        )
                      ),
                    ),
                    SizedBox(height: 8),
                    // Date and order info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy • HH:mm').format(notification.createdAt), 
                          style: Theme.of(context).textTheme.bodySmall!.merge(
                            TextStyle(
                              color: Theme.of(context).textTheme.bodySmall!.color!.withOpacity(0.7),
                            )
                          ),
                        ),
                        if (notification.orderId != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#${notification.orderId}',
                              style: Theme.of(context).textTheme.bodySmall!.merge(
                                TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                )
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    if (notification.isOrderNotification) {
      return Icons.shopping_bag;
    } else if (notification.type.contains('Message')) {
      return Icons.message;
    } else {
      return Icons.notifications;
    }
  }
}
