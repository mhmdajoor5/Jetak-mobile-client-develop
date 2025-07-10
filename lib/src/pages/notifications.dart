import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/notification_controller.dart';
import '../elements/EmptyNotificationsWidget.dart';
import '../elements/NotificationItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/user_repository.dart';

class NotificationsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  NotificationsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends StateMVC<NotificationsWidget> {
  late NotificationController _con;

  _NotificationsWidgetState() : super(NotificationController()) {
    _con = controller as NotificationController;
  }

  @override
  void initState() {
    super.initState();
    // Use the new method to load notifications
    _con.loadNotificationsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey?.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).notifications,
          style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          // Mark all as read button
          if (_con.hasUnreadNotifications)
            IconButton(
              icon: Icon(Icons.mark_email_read, color: Theme.of(context).hintColor),
              onPressed: () => _con.doMarkAllAsRead(),
              tooltip: 'Mark all as read',
            ),
          new ShoppingCartButtonWidget(
            iconColor: Theme.of(context).hintColor, 
            labelColor: Theme.of(context).colorScheme.secondary
          ),
        ],
      ),
      body: currentUser.value.apiToken == null
          ? PermissionDeniedWidget()
          : RefreshIndicator(
              onRefresh: _con.refreshNotifications,
              child: _buildNotificationsList(),
            ),
    );
  }

  Widget _buildNotificationsList() {
    if (_con.isLoading && _con.notifications.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
        ),
      );
    }
    
    if (_con.notifications.isEmpty) {
      return EmptyNotificationsWidget();
    }
    
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10),
      children: <Widget>[
        // Header with notification count
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 10),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 0),
            leading: Stack(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).hintColor,
                ),
                if (_con.hasUnreadNotifications)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _con.unReadNotificationsCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              S.of(context).notifications,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineLarge
            ),
            subtitle: Text(
              _con.hasUnreadNotifications 
                ? '${_con.unReadNotificationsCount} unread • ${S.of(context).swipeLeftTheNotificationToDeleteOrReadUnreadIt}'
                : S.of(context).swipeLeftTheNotificationToDeleteOrReadUnreadIt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        // Loading indicator if refreshing
        if (_con.isLoading)
          Container(
            height: 3,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: LinearProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
            ),
          ),
        // Notifications list
        ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 15),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          primary: false,
          itemCount: _con.notifications.length,
          separatorBuilder: (context, index) {
            return SizedBox(height: 15);
          },
          itemBuilder: (context, index) {
            final notification = _con.notifications.elementAt(index);
            return NotificationItemWidget(
              notification: notification,
              onTap: () => _con.handleNotificationTap(notification),
              onMarkAsRead: () {
                _con.doMarkAsReadNotifications(notification);
              },
              onMarkAsUnRead: () {
                _con.doMarkAsUnReadNotifications(notification);
              },
              onRemoved: () {
                _con.doRemoveNotification(notification);
              },
            );
          },
        ),
      ],
    );
  }
}
