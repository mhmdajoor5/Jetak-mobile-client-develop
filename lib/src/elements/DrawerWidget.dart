import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../helpers/helper.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends StateMVC<DrawerWidget> {
  _DrawerWidgetState() : super(ProfileController());

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentUser,
      builder: (context, user, _) {
        return Drawer(
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  user.apiToken != null
                      ? Navigator.of(context).pushNamed('/Profile')
                      : Navigator.of(context).pushNamed('/Login');
                },
                child: user.apiToken != null
                    ? UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.1)),
                  accountName: Text(user.name ?? '', style: Theme.of(context).textTheme.headlineSmall),
                  accountEmail: Text(user.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                  currentAccountPicture: Stack(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(80)),
                          child: CachedNetworkImage(
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: user.image?.thumb ?? '',
                            placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover, width: double.infinity, height: 80),
                            errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill),
                          ),
                        ),
                      ),
                      if (user.verifiedPhone ?? false)
                        Positioned(top: 0, right: 0, child: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary, size: 24)),
                    ],
                  ),
                )
                    : Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.1)),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.person, size: 32, color: Theme.of(context).colorScheme.secondary.withOpacity(1)),
                      const SizedBox(width: 30),
                      Text(S.of(context).guest, style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
              ),
              _buildTile(context, '/Pages', S.of(context).home, Icons.home, 0),
              _buildTile(context, '/Notifications', S.of(context).notifications, Icons.notifications),
              _buildTile(context, '/RecentOrders', S.of(context).my_orders, Icons.local_mall),
              _buildTile(context, '/Favorites', S.of(context).favorite_foods, Icons.favorite),
              _buildTile(context, '/Chat', S.of(context).messages, Icons.chat),
              _buildDividerTile(context, S.of(context).application_preferences),
              _buildTile(context, '/Help', S.of(context).help__support, Icons.help),
              ListTile(
                onTap: () {
                  if (user.apiToken != null) {
                    Navigator.of(context).pushNamed('/Settings');
                  } else {
                    Navigator.of(context).pushReplacementNamed('/Login');
                  }
                },
                leading: Icon(Icons.settings, color: Theme.of(context).focusColor.withOpacity(1)),
                title: Text(S.of(context).settings, style: Theme.of(context).textTheme.titleMedium),
              ),
              ListTile(
                onTap: () {
                  if (user.apiToken != null) {
                    logout().then((_) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/Pages', (Route<dynamic> route) => false, arguments: 0);
                    });
                  } else {
                    Navigator.of(context).pushNamed('/Login');
                  }
                },
                leading: Icon(Icons.exit_to_app, color: Theme.of(context).focusColor.withOpacity(1)),
                title: Text(user.apiToken != null ? S.of(context).log_out : S.of(context).login, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (user.apiToken == null) _buildTile(context, '/SignUp', S.of(context).register, Icons.person_add),
              if (setting.value.enableVersion)
                ListTile(
                  dense: true,
                  title: Text('${S.of(context).version} ${setting.value.appVersion}', style: Theme.of(context).textTheme.bodyMedium),
                  trailing: Icon(Icons.remove, color: Theme.of(context).focusColor.withOpacity(0.3)),
                ),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildTile(BuildContext context, String route, String title, IconData icon, [int? arguments]) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(route, arguments: arguments);
      },
      leading: Icon(icon, color: Theme.of(context).focusColor.withOpacity(1)),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  ListTile _buildDividerTile(BuildContext context, String title) {
    return ListTile(dense: true, title: Text(title, style: Theme.of(context).textTheme.bodyMedium), trailing: Icon(Icons.remove, color: Theme.of(context).focusColor.withOpacity(0.3)));
  }
}
