import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/food_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/ExtraItemWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

// ignore: must_be_immutable
class FoodWidget extends StatefulWidget {
  RouteArgument routeArgument;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: _con.food.image == null
          ? CircularLoadingWidget(height: 500)
          : RefreshIndicator(
        onRefresh: () => _con.refreshFood(context),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 150),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    toolbarHeight: 70,
                    expandedHeight: 300,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                    iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Hero(
                        tag: widget.routeArgument.heroTag ?? '' + _con.food.id,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: _con.food.image?.url ?? '',
                          placeholder: (context, url) => Image.asset('assets/img/loading.gif', fit: BoxFit.cover),
                          errorWidget: (context, url, error) => Image.asset('assets/img/logo.png', fit: BoxFit.fill),
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                        child: ShoppingCartFloatButtonWidget(
                          iconColor: Theme.of(context).primaryColor,
                          labelColor: Theme.of(context).hintColor,
                          routeArgument: RouteArgument(param: '/Food', id: _con.food.id),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.star_purple500_sharp, color: Colors.yellow,size: 25,),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _con.food.name ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      _con.food.restaurant.name ?? '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: Theme.of(context).textTheme.bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Helper.getPrice(
                                          _con.food.price,
                                          context,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue,fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 270,),
                                        Icon(Icons.ios_share_outlined, color: Colors.black87,size: 20,),
                                      ],
                                    )

                                  ],
                                ),
                              ),
                              // Expanded(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: [
                              //       Helper.getPrice(_con.food.price, context, style: Theme.of(context).textTheme.displayMedium),
                              //       if (_con.food.discountPrice > 0)
                              //         Helper.getPrice(
                              //           _con.food.discountPrice,
                              //           context,
                              //           style: Theme.of(context)
                              //               .textTheme
                              //               .bodyMedium
                              //               ?.merge(TextStyle(decoration: TextDecoration.lineThrough)),
                              //         ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(height: 14),
                          // Row(
                          //   children: [
                          //     _con.food.deliverable && Helper.canDelivery(_con.food.restaurant)
                          //         ? Chip(label: Text(S.of(context).deliverable))
                          //         : Chip(label: Text(S.of(context).not_deliverable)),
                          //     Spacer(),
                          //     Chip(label: Text('${_con.food.weight} ${_con.food.unit}')),
                          //     SizedBox(width: 5),
                          //     Chip(label: Text('${_con.food.packageItemsCount} ${S.of(context).items}')),
                          //   ],
                          // ),
                          //Divider(height: 20),
                          Text(
                            Helper.skipHtmlTags(_con.food.description ?? ''),
                            style: TextStyle(fontSize: 15 ,fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: 15),
                          Divider(height: 20),
                          ListTile(
                            leading: Icon(Icons.add_circle, color: Theme.of(context).hintColor),
                            title: Text(S.of(context).extras, style: Theme.of(context).textTheme.titleMedium),
                            subtitle: Text(S.of(context).select_extras_to_add_them_on_the_food, style: Theme.of(context).textTheme.bodySmall),
                          ),
                          Divider(),
                          if (_con.food.extraGroups == null)
                            CircularLoadingWidget(height: 100)
                          else
                            ..._con.food.extraGroups.map((group) {
                              var extras = _con.food.extras.where((e) => e.extraGroupId == group.id).toList();
                              int selectedCount = selectedExtras.where((id) => extras.any((e) => e.id == id)).length;
                              bool hasError = selectedCount < 2;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    dense: true,
                                    leading: Icon(Icons.add_circle_outline, color: Theme.of(context).hintColor),
                                    title: Text(group.name, style: Theme.of(context).textTheme.titleMedium),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Text(
                                      hasError ? 'You must select at least 2 items' : "You've chosen the maximum",
                                      style: TextStyle(color: selectedCount == 0 ? Colors.grey : (hasError ? Colors.red : Colors.green), fontSize: 12),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  ...extras.map((extra) {
                                    bool isSelected = selectedExtras.contains(extra.id);
                                    bool isDisabled = !isSelected && selectedCount >= 2;
                                    return Opacity(
                                      opacity: isDisabled ? 0.5 : 1.0,
                                      child: InkWell(
                                          highlightColor: Colors.grey[200],
                                          splashColor: Colors.transparent,
                                          onTap: isDisabled
                                              ? null
                                              : () {
                                            setState(() {
                                              if (isSelected) {
                                                selectedExtras.remove(extra.id);
                                              } else {
                                                selectedExtras.add(extra.id);
                                              }
                                            });
                                            _con.calculateTotal();
                                          },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                shape: CircleBorder(),
                                                side: BorderSide(color: Colors.blue),
                                                fillColor: MaterialStateProperty.resolveWith((states) =>
                                                states.contains(MaterialState.selected) ? Colors.blue : Colors.transparent),
                                                checkColor: Colors.black,
                                                value: isSelected,
                                                onChanged: isDisabled
                                                    ? null
                                                    : (val) {
                                                  setState(() {
                                                    if (val == true)
                                                      selectedExtras.add(extra.id);
                                                    else
                                                      selectedExtras.remove(extra.id);
                                                  });
                                                  _con.calculateTotal();
                                                },
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(child: Text(extra.name)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  Divider(),
                                ],
                              );
                            }).toList(),
                          SizedBox(height: 15),
                          ListTile(
                            leading: Icon(Icons.local_activity, color: Theme.of(context).hintColor),
                            title: Text(S.of(context).nutrition, style: Theme.of(context).textTheme.titleMedium),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _con.food.nutritions.map((n) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.2), offset: Offset(0,2), blurRadius: 6)],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(n.name, style: Theme.of(context).textTheme.bodySmall),
                                    Text(n.quantity.toString(), style: Theme.of(context).textTheme.headlineMedium),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          Divider(),
                          SizedBox(height: 15),
                          ListTile(
                            leading: Icon(Icons.recent_actors, color: Theme.of(context).hintColor),
                            title: Text(S.of(context).reviews, style: Theme.of(context).textTheme.titleMedium),
                          ),
                          ReviewsListWidget(reviewsList: _con.food.foodReviews),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => setState(() => _con.decrementQuantity()),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.remove, color: Colors.blue, size: 20),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            _con.quantity.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(width: 12),
                          InkWell(
                            onTap: () => setState(() => _con.incrementQuantity()),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.add, color: Colors.blue, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (currentUser.value.apiToken == null)
                            Navigator.of(context).pushNamed("/Login");
                          else
                            _con.addToCart(_con.food, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).add_to_cart,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Helper.getPrice(
                              _con.total,
                              context,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
