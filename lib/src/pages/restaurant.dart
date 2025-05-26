import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/FoodItemWidget.dart';
import '../elements/GalleryCarouselWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'menu_list.dart';

class RestaurantWidget extends StatefulWidget {
  final RouteArgument? routeArgument;
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  RestaurantWidget({Key? key, this.parentScaffoldKey, this.routeArgument})
      : super(key: key);

  @override
  _RestaurantWidgetState createState() {
    return _RestaurantWidgetState();
  }
}

class _RestaurantWidgetState extends StateMVC<RestaurantWidget> {
  late RestaurantController _con;

  _RestaurantWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController;
  }

  @override
  void initState() {
    _con.restaurant = widget.routeArgument?.param as Restaurant;
    _con.listenForGalleries(_con.restaurant!.id);
    _con.listenForFeaturedFoods(_con.restaurant!.id);
    _con.listenForRestaurantReviews(id: _con.restaurant!.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
        key: _con.scaffoldKey,
        body: RefreshIndicator(
          onRefresh: _con.refreshRestaurant,
          child: _con.restaurant == null
              ? CircularLoadingWidget(height: 500)
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CustomScrollView(
                      primary: true,
                      shrinkWrap: false,
                      slivers: <Widget>[
                        SliverAppBar(
                          toolbarHeight: 70,
                          actions: [
                            SizedBox(
                              height: 60,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 5),
                                child: ShoppingCartFloatButtonWidget(
                                    iconColor:
                                        Theme.of(context).primaryColor,
                                    labelColor:
                                        Theme.of(context).hintColor,
                                    routeArgument: RouteArgument(
                                        id: '0',
                                        param: _con.restaurant!.id,
                                        heroTag: 'home_slide')),
                              ),
                            ),
                          ],
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                          expandedHeight: 300,
                          elevation: 0,
//                          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                          automaticallyImplyLeading: false,
                          leading: new IconButton(
                            icon: new Icon(Icons.sort,
                                color: Theme.of(context).primaryColor),
                            onPressed: () => widget
                                .parentScaffoldKey?.currentState
                                ?.openDrawer(),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Hero(
                              tag: (widget?.routeArgument?.heroTag ?? '') +
                                  _con.restaurant!.id ?? "",
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: _con.restaurant!.image.url,
                                      placeholder: (context, url) => Image.asset(
                                        'assets/img/loading.gif',
                                        fit: BoxFit.cover,
                                      ),
                                      errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill, ),

                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(width: 20),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 3),
                                          decoration: BoxDecoration(
                                              color: _con.restaurant!.closed
                                                  ? Colors.grey
                                                  : Colors.green,
                                              borderRadius:
                                              BorderRadius.circular(24)),
                                          child: _con.restaurant!.closed
                                              ? Text(
                                            S.of(context).closed,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall                            
                                                ?.merge(TextStyle(
                                                color: Theme.of(
                                                    context)
                                                    .primaryColor)),
                                          )
                                              : Text(
                                            S.of(context).open,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall                            
                                                ?.merge(TextStyle(
                                                color: Theme.of(
                                                    context)
                                                    .primaryColor)),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 3),
                                          decoration: BoxDecoration(
                                              color: Helper.canDelivery(
                                                  _con.restaurant!)
                                                  ? Colors.green
                                                  : Colors.grey,
                                              borderRadius:
                                              BorderRadius.circular(24)),
                                          child: Text(
                                            Helper.getDistance(
                                                _con.restaurant!.distance,
                                                Helper.of(context).trans(setting
                                                    .value.distanceUnit)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall                            
                                                ?.merge(TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Wrap(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 20,
                                  left: 20,
                                  bottom: 6,
                                  top: 25,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        _con.restaurant?.name ?? '',
                                        overflow: TextOverflow.fade,
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(bottom: 8.0),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: MaterialButton(
                                              elevation: 0,
                                              focusElevation: 0,
                                              highlightElevation: 0,
                                              padding: EdgeInsets.all(0),
                                              onPressed: () async {
                                                if (await MapLauncher
                                                    .isMapAvailable(
                                                    MapType.waze)??false) {
                                                  await MapLauncher
                                                      .showMarker(
                                                    mapType: MapType.waze,
                                                    coords: Coords(
                                                        double.parse(_con
                                                            .restaurant
                                                            !.latitude),
                                                        double.parse(_con
                                                            .restaurant
                                                            !.longitude)),
                                                    title:
                                                    _con.restaurant!.name,
                                                    description: _con
                                                        .restaurant
                                                        !.description,
                                                  );
                                                }

                                                // Navigator.of(context).pushNamed(
                                                //     '/Pages',
                                                //     arguments: new RouteArgument(
                                                //         id: '1',
                                                //         param: _con.restaurant));
                                              },
                                              child: SvgPicture.asset(
                                                "assets/img/ic_waze.svg",
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                width: 16,
                                                // height: 24,
                                              ),
                                              color: Theme.of(context).colorScheme.secondary
                                                  .withOpacity(0.9),
                                              shape: StadiumBorder(),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: MaterialButton(
                                              elevation: 0,
                                              focusElevation: 0,
                                              highlightElevation: 0,
                                              padding: EdgeInsets.all(0),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    '/Pages',
                                                    arguments:
                                                    new RouteArgument(
                                                        id: '1',
                                                        param: _con
                                                            .restaurant));
                                              },
                                              child: Icon(
                                                Icons.directions,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                size: 24,
                                              ),
                                              color: Theme.of(context).colorScheme.secondary
                                                  .withOpacity(0.9),
                                              shape: StadiumBorder(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 32,
                                      child: Chip(
                                        padding: EdgeInsets.all(0),
                                        label: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(_con.restaurant!.rate,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.merge(TextStyle(
                                                        color: Theme.of(
                                                                context)
                                                            .primaryColor))),
                                            Icon(
                                              Icons.star_border,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.secondary
                                            .withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 8),
                                child: Helper.applyHtml(
                                    context, _con.restaurant!.description,
                                    style: TextStyle(fontSize: 8)),
                              ),
                              ImageThumbCarouselWidget(
                                  galleriesList: _con.galleries),

                              // <Menu>
                              MenuWidget(
                                  routeArgument:
                                      RouteArgument(param: _con.restaurant)),

                              _con.featuredFoods.isEmpty
                                  ? SizedBox(height: 0)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 0),
                                        leading: Icon(
                                          Icons.restaurant,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        title: Text(
                                          S.of(context).featured_foods,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge,
                                        ),
                                      ),
                                    ),
                              _con.featuredFoods.isEmpty
                                  ? SizedBox(height: 0)
                                  : ListView.separated(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: _con.featuredFoods.length,
                                      separatorBuilder: (context, index) {
                                        return SizedBox(height: 10);
                                      },
                                      itemBuilder: (context, index) {
                                        return FoodItemWidget(
                                          heroTag: 'details_featured_food',
                                          food: _con.featuredFoods
                                              .elementAt(index),
                                        );
                                      },
                                    ),
                              SizedBox(height: 100),
                              _con.reviews.isEmpty
                                  ? SizedBox(height: 5)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            EdgeInsets.symmetric(vertical: 0),
                                        leading: Icon(
                                          Icons.recent_actors,
                                          color: Theme.of(context).hintColor,
                                        ),
                                        title: Text(
                                          S.of(context).what_they_say,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge,
                                        ),
                                      ),
                                    ),
                              _con.reviews.isEmpty
                                  ? SizedBox(height: 5)
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: ReviewsListWidget(
                                          reviewsList: _con.reviews),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Positioned(
                    //   top: 32,
                    //   right: 20,
                    //   child: ShoppingCartFloatButtonWidget(
                    //       iconColor: Theme.of(context).primaryColor,
                    //       labelColor: Theme.of(context).hintColor,
                    //       routeArgument: RouteArgument(
                    //           id: '0',
                    //           param: _con.restaurant!.id,
                    //           heroTag: 'home_slide')),
                    // ),
                  ],
                ),
        ));
  }
}
