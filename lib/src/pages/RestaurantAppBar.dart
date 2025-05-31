import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';

class RestaurantAppBar extends StatelessWidget {
  final Restaurant restaurant;
  final RouteArgument? routeArgument;

  const RestaurantAppBar({
    Key? key,
    required this.restaurant,
    this.routeArgument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 70,
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
      expandedHeight: 300,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(45),
        child: SizedBox(
          height: 45,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(color: Colors.white, width: double.infinity, height: 45),
              Positioned(
                bottom: -2,
                left: 16,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: restaurant.image.url!,
                      fit: BoxFit.cover,
                      errorWidget: (c, u, e) => Image.asset('assets/img/logo.png'),
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
          tag: (routeArgument?.heroTag ?? '') + (restaurant.id ?? ''),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: restaurant.image.url!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Image.asset('assets/img/loading.gif'),
                  errorWidget: (context, url, error) => Image.asset('assets/img/logo.png'),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 6,
                left: 10,
                width: 66,
                height: 66,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: 10,
                width: 60,
                height: 60,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: SvgPicture.asset('assets/img/heart.svg'),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}