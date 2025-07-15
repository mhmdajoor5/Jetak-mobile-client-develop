import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../../generated/l10n.dart';
import '../../controllers/profile_controller.dart';
import '../../elements/DrawerWidget.dart';
import '../../elements/EmptyOrdersWidget.dart';
import '../../elements/OrderItemWidget.dart';
import '../../elements/PermissionDeniedWidget.dart';
import '../../elements/ProfileAvatarWidget.dart';
import '../../elements/ShoppingCartButtonWidget.dart';
import '../../repository/user_repository.dart';


class ProfileWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

   ProfileWidget({Key? key, this.parentScaffoldKey}) : super(key: key);
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends StateMVC<ProfileWidget> {
  late ProfileController _con;

  _ProfileWidgetState() : super(ProfileController()) {
    _con = controller as ProfileController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: Theme.of(context).appBarTheme.centerTitle ?? true,
        leading: IconButton(
          icon: Icon(
            Icons.sort,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
          onPressed: () => _con.scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          S.of(context).profile,
          style: Theme.of(context).appBarTheme.titleTextStyle?.merge(
            const TextStyle(letterSpacing: 1.3),
          ),
        ),
        actions: <Widget>[
          ShoppingCartButtonWidget(
            iconColor: Theme.of(context).appBarTheme.iconTheme?.color,
            labelColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),

      body: currentUser.value.apiToken == null
          ? PermissionDeniedWidget()
          : SingleChildScrollView(
//              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Column(
                children: <Widget>[
                  ProfileAvatarWidget(user: currentUser.value),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(
                      Icons.person,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).about,
                      style: Theme.of(context).appBarTheme.titleTextStyle?.merge(
                        const TextStyle(letterSpacing: 1.3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      currentUser.value.bio ?? "",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: Icon(
                      Icons.shopping_basket,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).recent_orders,
                      style: Theme.of(context).appBarTheme.titleTextStyle?.merge(
                        const TextStyle(letterSpacing: 1.3),
                      ),
                    ),
                  ),
                  _con.recentOrders.isEmpty
                      ? EmptyOrdersWidget()
                      : ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          primary: false,
                          itemCount: _con.recentOrders.length,
                          itemBuilder: (context, index) {
                            var _order = _con.recentOrders.elementAt(index);
                            return OrderItemWidget(expanded: index == 0 ? true : false, order: _order);
                          },
                          separatorBuilder: (context, index) {
                            return SizedBox(height: 20);
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
