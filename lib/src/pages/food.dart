import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/food_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';

class FoodWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  FoodWidget({Key? key, required this.routeArgument}) : super(key: key);

  @override
  _FoodWidgetState createState() => _FoodWidgetState();
}

class _FoodWidgetState extends StateMVC<FoodWidget> {
  late FoodController _con;
  List<String> selectedExtras = [];

  _FoodWidgetState() : super(FoodController()) {
    _con = controller as FoodController;
  }

  @override
  void initState() {
    _con.listenForFood(context, foodId: widget.routeArgument.id!);
    _con.listenForCart();
    _con.listenForFavorite(foodId: widget.routeArgument.id!);
    super.initState();
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      // _con.food.image == null
      //   ? SizedBox.shrink()
       // :
    Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      toolbarHeight: 70,
                      expandedHeight: 300,
                      pinned: true,
                      floating: false,
                      snap: false,
                      backgroundColor: Colors.white,
                      automaticallyImplyLeading: false,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background:
                        // Container(
                        //   width: double.infinity,
                        //   height: double.infinity,
                        //   child:
                          Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _con.food.image?.url ?? '',
                                placeholder: (context, url) => Container(),
                                // placeholder: (context, url) => Container(
                                //   color: Colors.grey[200],
                                //   child: Center(
                                //     child: CircularProgressIndicator(
                                //       color: Colors.blue,
                                //     ),
                                //   ),
                                // ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Image.asset(
                                      'assets/img/logo.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              // تأثير التظليل
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.1),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.15),
                                    ],
                                    stops: [0.0, 0.7, 1.0],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 30,
                                right: 16,
                                child: Row(
                                  children: [
                                    _buildCircleButton(
                                      icon: _con.favorite.id.isNotEmpty
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _con.favorite.id.isNotEmpty
                                          ? Colors.red
                                          : Colors.grey,
                                      onPressed: () {
                                        _con.addToFavorite(_con.food);
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    _buildCircleButton(
                                      icon: Icons.share,
                                      color: Colors.black,
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _con.food.name,
                                        style: TextStyle(
                                          fontSize: 20, // reduced from 22
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        _con.food.restaurant.name,
                                        style: TextStyle(
                                          fontSize: 14, // reduced from 16
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Helper.getPrice(
                                        _con.food.price,
                                        context,
                                        style: TextStyle(
                                          fontSize: 18, // reduced from 20
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            _con.food.restaurant.rate.toString(),
                                            style: TextStyle(
                                              fontSize: 12, // reduced from 14
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Divider(color: Colors.grey[300]),
                            SizedBox(height: 15),
                            Text(
                              S.of(context).description,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              Helper.skipHtmlTags(_con.food.description),
                              style: TextStyle(
                                fontSize: 14, // reduced from 16
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20),
                            if (_con.food.ingredients.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).ingredients,
                                    style: TextStyle(
                                      fontSize: 16, // reduced from 18
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    _con.food.ingredients.toString(),
                                    style: TextStyle(
                                      fontSize: 14, // reduced from 16
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            if (_con.food.nutritions.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).nutrition,
                                    style: TextStyle(
                                      fontSize: 16, // reduced from 18
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _con.food.nutritions.length,
                                    itemBuilder: (context, index) {
                                      final nutrition = _con.food.nutritions[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              nutrition.name,
                                              style: TextStyle(
                                                fontSize: 14, // reduced from 16
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              nutrition.quantity.toString(),
                                              style: TextStyle(
                                                fontSize: 14, // reduced from 16
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            if (_con.food.extraGroups.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).extras,
                                    style: TextStyle(
                                      fontSize: 16, // reduced from 18
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    S.of(context).select_extras,
                                    style: TextStyle(
                                      fontSize: 12, // reduced from 14
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: _con.food.extraGroups.length,
                                    itemBuilder: (context, index) {
                                      final group = _con.food.extraGroups[index];
                                      final groupExtras = _con.food.extras.where((e) => e.extraGroupId == group.id).toList();
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            group.name,
                                            style: TextStyle(
                                              fontSize: 14, // reduced from 16
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: groupExtras.length,
                                            itemBuilder: (context, extraIndex) {
                                              final extra = groupExtras[extraIndex];
                                              return CheckboxListTile(
                                                title: Text(
                                                  extra.name,
                                                  style: TextStyle(fontSize: 14), // added explicit font size
                                                ),
                                                subtitle: Helper.getPrice(extra.price, context),
                                                value: selectedExtras.contains(extra.id),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      selectedExtras.add(extra.id);
                                                    } else {
                                                      selectedExtras.remove(extra.id);
                                                    }
                                                  });
                                                },
                                                controlAffinity: ListTileControlAffinity.leading,
                                                contentPadding: EdgeInsets.zero,
                                                activeColor: Colors.blue[600],
                                                checkColor: Colors.white,
                                                tileColor: selectedExtras.contains(extra.id) 
                                                  ? Colors.blue[50] 
                                                  : Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(height: 15),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            if (_con.food.foodReviews.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).reviews,
                                    style: TextStyle(
                                      fontSize: 16, // reduced from 18
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  ReviewsListWidget(
                                    reviewsList: _con.food.foodReviews,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // الشريط السفلي للـ Add to Cart
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 55,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue[100]!, width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (_con.quantity > 1) {
                                  _con.decrementQuantity();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.blue[700],
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${_con.quantity}',
                            style: TextStyle(
                              fontSize: 16, // reduced from 18
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _con.incrementQuantity();
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.blue[700],
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _con.addToCart(_con.food, context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إضافة ${_con.food.name} للسلة'),
                              backgroundColor: Colors.green,
                              //duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            )
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          elevation: 3,
                          shadowColor: Colors.blue.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  S.of(context).add_to_cart,
                                  style: TextStyle(
                                    fontSize: 14, // reduced from 16
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Helper.getPrice(
                                _con.total,
                                context,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // reduced from 16
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
            ],
          );
  }
}
