import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../generated/l10n.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../pages/home.dart';
import '../pages/map.dart';
import '../pages/notifications.dart';
import '../pages/orders.dart';
import 'messages.dart';
import 'restaurants.dart';

// ignore: must_be_immutable
class PagesWidget extends StatefulWidget {
  dynamic currentTab;
  RouteArgument? routeArgument;
  Widget currentPage = HomeWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PagesWidget({
    Key? key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 2;
    }
  }

  @override
  _PagesWidgetState createState() {
    return _PagesWidgetState();
  }
}

class _PagesWidgetState extends State<PagesWidget> {
  initState() {
    super.initState();
    _selectTab(widget.currentTab);
  }

  @override
  void didUpdateWidget(PagesWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage = HomeWidget(parentScaffoldKey: widget.scaffoldKey);//
          // NotificationsWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage = RestaurantsWidget(parentScaffoldKey: widget.scaffoldKey);//
          break;
        default:
          widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
        // case 1:
        //   widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: widget.routeArgument);
        //   break;
        // case 2:
        //   widget.currentPage = ;
        //   break;
        // case 3:
        //   widget.currentPage = OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
        //   break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        endDrawer: FilterWidget(onFilter: (filter) {
          Navigator.of(context).pushReplacementNamed('/Pages', arguments: widget.currentTab);
        }),
        body: widget.currentPage,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xff26386A),
          selectedFontSize: 0,
          unselectedFontSize: 0,
          iconSize: 22,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIconTheme: IconThemeData(size: 28),
          unselectedItemColor: Theme.of(context).focusColor.withOpacity(1),
          currentIndex: widget.currentTab,
          onTap: (int i) {
            this._selectTab(i);
          },
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
                label: '',
                icon: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/img/home.svg',
                      height: 32,
                      width: 32,
                    ),
                    Text(S.of(context).home, style: TextStyle(fontSize: 12))
                  ],
                ),
              activeIcon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/home.svg',
                    height: 32,
                    width: 32,
                    colorFilter: ColorFilter.mode(Color(0xff26386A), BlendMode.srcIn),
                  ),
                  Text(S.of(context).home, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold))
                ],
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/restaurants.svg',
                    height: 32,
                    width: 32,
                  ),
                  Text(S.of(context).restaurants, style: TextStyle(fontSize: 12,))
                ],
              ),
              activeIcon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/restaurants.svg',
                    height: 32,
                    width: 32,
                    colorFilter: ColorFilter.mode(Color(0xff26386A), BlendMode.srcIn),
                  ),
                  Text(S.of(context).restaurants, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold))
                ],
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/stores.svg',
                    height: 32,
                    width: 32,
                  ),
                  Text(S.of(context).stores, style: TextStyle(fontSize: 12))
                ],
              ),
              activeIcon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/stores.svg',
                    height: 32,
                    width: 32,
                    colorFilter: ColorFilter.mode(Color(0xff26386A), BlendMode.srcIn),
                  ),
                  Text(S.of(context).stores, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold))
                ],
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/chats.svg',
                    height: 32,
                    width: 32,
                  ),
                  Text(S.of(context).chats, style: TextStyle(fontSize: 12))
                ],
              ),
              activeIcon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/chats.svg',
                    height: 32,
                    width: 32,
                    colorFilter: ColorFilter.mode(Color(0xff26386A), BlendMode.srcIn),
                  ),
                  Text(S.of(context).chats, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold))
                ],
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/profile.svg',
                    height: 32,
                    width: 32,
                  ),
                  Text(S.of(context).profile, style: TextStyle(fontSize: 12))
                ],
              ),
              activeIcon: Column(
                children: [
                  SvgPicture.asset(
                    'assets/img/profile.svg',
                    height: 32,
                    width: 32,
                    colorFilter: ColorFilter.mode(Color(0xff26386A), BlendMode.srcIn),
                  ),
                  Text(S.of(context).profile, style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold))
                ],
              ),
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.notifications),
            //   label: '',
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.location_on),
            //   label: '',
            // ),
            // BottomNavigationBarItem(
            //   icon: new Icon(Icons.fastfood),
            //   label: '',
            // ),

          ],
        ),
      ),
    );
  }
}
