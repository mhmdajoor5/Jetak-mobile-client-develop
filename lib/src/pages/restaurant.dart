import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// import 'package:font_awesome_flutter/font_awesome_flutter.dart' show FaIcon, FontAwesomeIcons;
import 'package:map_launcher/map_launcher.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/FoodItemWidget.dart';
import '../elements/GalleryCarouselWidget.dart' show ImageThumbCarouselWidget;
import '../elements/ReviewsListWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/food.dart';
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
  _RestaurantWidgetState createState() => _RestaurantWidgetState();
}

class _RestaurantWidgetState extends StateMVC<RestaurantWidget> {
  late RestaurantController _con;

  _RestaurantWidgetState() : super(RestaurantController()) {
    _con = controller as RestaurantController;
  }

  @override
  void initState() {
    _con.restaurant = widget.routeArgument?.param as Restaurant;
    // _con.listenForGalleries(_con.restaurant!.id!);
    _con.listenForFeaturedFoods(_con.restaurant!.id!);
    // _con.listenForRestaurantReviews(id: _con.restaurant!.id!);
    super.initState();
  }

  final List<Cart> _cart = [];

  int get cartCount =>
      _cart.fold(0, (sum, c) => (sum + (c.quantity ?? 1)).toInt());

  double get totalPrice => _cart.fold(0.0, (sum, c) {
    return sum + (c.food?.price ?? 0) * (c.quantity ?? 1);
  });

  void _addToCart(Food food) {
    setState(() {
      final idx = _cart.indexWhere((c) => c.food?.id == food.id);
      if (idx >= 0) {
        _cart[idx].quantity = (_cart[idx].quantity ?? 1) + 1;
      } else {
        _cart.add(Cart(food: food, quantity: 1));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _con.scaffoldKey,
      body: RefreshIndicator(
        onRefresh: _con.refreshRestaurant,
        child:
            _con.restaurant == null
                ? CircularLoadingWidget(height: 500)
                : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CustomScrollView(
                      primary: true,
                      slivers: <Widget>[
                        SliverAppBar(
                          toolbarHeight: 70,
                          automaticallyImplyLeading: false,
                          elevation: 0,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.9),
                          expandedHeight: 300,
                          bottom: PreferredSize(
                            preferredSize: Size.fromHeight(45),
                            child: SizedBox(
                              height: 45,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                    height: 45,
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    left: 16,
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: _con.restaurant!.image.url!,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) => Image.asset(
                                                'assets/img/loading.gif',
                                                fit: BoxFit.cover,
                                              ),
                                          // errorWidget: (context, url, error) =>
                                          //     Icon(Icons.error),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Image.asset(
                                                    'assets/img/logo.png',
                                                    fit: BoxFit.fill,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.parallax,
                            background: Hero(
                              tag:
                                  (widget.routeArgument?.heroTag ?? '') +
                                  (_con.restaurant!.id ?? ''),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: CachedNetworkImage(
                                      imageUrl: _con.restaurant!.image.url!,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Image.asset(
                                            'assets/img/loading.gif',
                                            fit: BoxFit.cover,
                                          ),
                                      // errorWidget: (context, url, error) =>
                                      //     Icon(Icons.error),
                                      errorWidget:
                                          (context, url, error) => Image.asset(
                                            'assets/img/logo.png',
                                            fit: BoxFit.fill,
                                          ),
                                    ),
                                  ),
                                  Positioned(
                                    top: MediaQuery.of(context).padding.top + 6,
                                    left: 10,
                                    width: 66,
                                    height: 66,
                                    child: CircleAvatar(
                                      radius: 100,
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.black,
                                        ),
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top:
                                        MediaQuery.of(context).padding.top + 10,
                                    right: 10,
                                    width: 60,
                                    height: 60,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 50,

                                      /// TODO : mElkerm *->put correct icon without using package for icons
                                      child: IconButton(
                                        icon: SvgPicture.asset(
                                          'assets/img/google_scv_icon.svg',
                                          color: Colors.redAccent,
                                        ),

                                        // icon: FaIcon(
                                        //   FontAwesomeIcons.heart,
                                        //   color: Colors.black,
                                        // ),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                  // Positioned(
                                  //   top: 260,
                                  //   left: 16,
                                  //   child: Container(
                                  //     width: 90,
                                  //     height: 90,
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.white,
                                  //       borderRadius: BorderRadius.circular(12),
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color: Colors.black26,
                                  //           blurRadius: 4,
                                  //           offset: Offset(0, 2),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     child: ClipRRect(
                                  //       borderRadius: BorderRadius.circular(12),
                                  //       child: CachedNetworkImage(
                                  //         imageUrl: _con.restaurant!.image.url!,
                                  //         fit: BoxFit.cover,
                                  //         placeholder: (context, url) =>
                                  //             Image.asset(
                                  //               'assets/img/loading.gif',
                                  //               fit: BoxFit.cover,
                                  //             ),
                                  //         errorWidget: (context, url, error) =>
                                  //             Icon(Icons.error),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 20),
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: 20,
                                    left: 20,
                                    top: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _con.restaurant?.name ?? '',
                                        overflow: TextOverflow.fade,
                                        maxLines: 2,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Icon(Icons.star, size: 14, color: Colors.amber),
                                            SvgPicture.asset(
                                              'assets/img/star.svg',
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              _con.restaurant!.rate ?? '0.0',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Container(
                                        height: 16,
                                        width: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // FaIcon(FontAwesomeIcons.route, size: 14, color: Colors.grey.shade500),
                                            SvgPicture.asset(
                                              'assets/img/routing.svg',
                                            ),

                                            SizedBox(width: 4),
                                            Text(
                                              Helper.getDistance(
                                                _con.restaurant!.distance,
                                                Helper.of(context).trans(
                                                  setting.value.distanceUnit,
                                                ),
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        height: 16,
                                        width: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              _con.restaurant!.closed!
                                                  ? S.of(context).closed
                                                  : S
                                                      .of(context)
                                                      .open_until(
                                                        _con
                                                                .restaurant
                                                                ?.closingTime ??
                                                            '22:00',
                                                      ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        height: 16,
                                        width: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          print('More info tapped!');
                                        },
                                        child: Text(
                                          S.of(context).more,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff26386A),
                                            height: 1.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: OutlinedButton.icon(
                                            onPressed: () {},
                                            icon: SvgPicture.asset(
                                              'assets/img/truck-fast2.svg',
                                              height: 20,width: 20,
                                            ),

                                            label: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                //SizedBox(width: 5),
                                                Text(
                                                  'Delivery 20–30 mnt',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                //SizedBox(width: 5),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.black87,
                                                  size: 23,
                                                ),
                                              ],
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFFF0F0F0,
                                              ),
                                              side: BorderSide(
                                                color: Colors.white,
                                                width: 5.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal: 16,
                                              ),
                                              fixedSize: Size.fromHeight(60),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 5.0,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.transparent,
                                          child: IconButton(
                                            icon: SvgPicture.asset(
                                              'assets/img/user-cirlce-add.svg',
                                              height: 25,
                                              width: 25,
                                            ),

                                            onPressed: () {
                                              // Add your onPressed logic here
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 5.0,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Colors.transparent,
                                          // child: IconButton(
                                          //   icon: FaIcon(FontAwesomeIcons.share, size: 20,),
                                          /// TODO : mElkerm *->put correct icon without using package for icons
                                          child: IconButton(
                                            icon: SvgPicture.asset(
                                              'assets/img/share_svg_icon.svg',
                                              height: 25,
                                              width: 25,
                                            ),

                                            onPressed: () {
                                              // Add your onPressed logic here
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),

                                ImageThumbCarouselWidget(
                                  galleriesList: _con.galleries,
                                ),


                                /// mElkerm menu Widget
                                MenuWidget(
                                  routeArgument: RouteArgument(
                                    param: _con.restaurant,
                                  ),
                                ),

                                /// mElkerm : Featured Foods list
                                // if (_con.featuredFoods.isNotEmpty) ...[
                                //   Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 20,
                                //     ),
                                //     child: ListTile(
                                //       dense: true,
                                //       contentPadding: EdgeInsets.symmetric(
                                //         vertical: 0,
                                //       ),
                                //       leading: Icon(
                                //         Icons.restaurant,
                                //         color: Theme.of(context).hintColor,
                                //       ),
                                //       title: Text(
                                //         S.of(context).featured_foods,
                                //         style:
                                //             Theme.of(
                                //               context,
                                //             ).textTheme.headlineLarge,
                                //       ),
                                //     ),
                                //   ),
                                //   ListView.separated(
                                //     padding: EdgeInsets.symmetric(vertical: 10),
                                //     shrinkWrap: true,
                                //     physics: NeverScrollableScrollPhysics(),
                                //     itemCount: _con.featuredFoods.length,
                                //     separatorBuilder:
                                //         (context, index) =>
                                //             SizedBox(height: 10),
                                //     itemBuilder:
                                //         (context, index) => FoodItemWidget(
                                //           heroTag: 'details_featured_food',
                                //           food: _con.featuredFoods[index],
                                //           onAdd:
                                //               () => _addToCart(
                                //                 _con.featuredFoods[index],
                                //               ),
                                //         ),
                                //   ),
                                // ],

                                /// mElkerm : reviews list
                                // if (_con.reviews.isNotEmpty) ...[
                                //   Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //       vertical: 10,
                                //       horizontal: 20,
                                //     ),
                                //     child: ListTile(
                                //       dense: true,
                                //       contentPadding: EdgeInsets.symmetric(
                                //         vertical: 0,
                                //       ),
                                //       leading: Icon(
                                //         Icons.recent_actors,
                                //         color: Theme.of(context).hintColor,
                                //       ),
                                //       title: Text(
                                //         S.of(context).what_they_say,
                                //         style:
                                //             Theme.of(
                                //               context,
                                //             ).textTheme.headlineLarge,
                                //       ),
                                //     ),
                                //   ),
                                // ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 8,
                      left: 16,
                      right: 16,
                      child: SizedBox(
                        height: 48,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF26386A),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 44,
                                width: 120,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/img/bag.svg',
                                      height: 27,
                                      width: 27,
                                      color: Colors.black87,
                                    ),
                                    // const Icon(Icons.shopping_bag,
                                    //     color: Colors.black, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$cartCount Cart',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Total',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 120),
                              Text(
                                '\$${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
