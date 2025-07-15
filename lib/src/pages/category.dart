import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/category_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../elements/FoodGridItemWidget.dart';
import '../elements/FoodListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class CategoryWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  const CategoryWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends StateMVC<CategoryWidget> {
  String layout = 'grid';
  late CategoryController _con;

  _CategoryWidgetState() : super(CategoryController()) {
    _con = controller as CategoryController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForFoodsByCategory(id: widget.routeArgument!.id);
    _con.listenForCategory(id: widget.routeArgument!.id!);
    _con.listenForCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      // endDrawer: FilterWidget(
      //   onFilter: (filter) {
      //     Navigator.of(context).pushReplacementNamed('/Category', arguments: RouteArgument(id: widget.routeArgument!.id));
      //   },
      // ),
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.sort, color: Theme.of(context).hintColor), onPressed: () => _con.scaffoldKey.currentState?.openDrawer()),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(S.of(context).category, style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 0)),
        actions: [
          _con.loadCart
              ? Padding(padding: const EdgeInsets.symmetric(horizontal: 22.5, vertical: 15), child: SizedBox(width: 26, child: CircularProgressIndicator(strokeWidth: 2.5)))
              : ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).colorScheme.secondary),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _con.refreshCategory(widget.routeArgument!.id!),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarWidget(
                  onClickFilter: (filter) {
                    _con.scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.category, color: Theme.of(context).hintColor),
                  title: Text(_con.category?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineLarge),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.format_list_bulleted, color: layout == 'list' ? Theme.of(context).colorScheme.secondary : Theme.of(context).focusColor),
                        onPressed: () => setState(() => layout = 'list'),
                      ),
                      IconButton(
                        icon: Icon(Icons.apps, color: layout == 'grid' ? Theme.of(context).colorScheme.secondary : Theme.of(context).focusColor),
                        onPressed: () => setState(() => layout = 'grid'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_con.foods.isEmpty)
                CircularLoadingWidget(height: 500)
              else if (layout == 'list')
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _con.foods.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (_, index) => FoodListItemWidget(heroTag: 'favorites_list', food: _con.foods[index]),
                )
              else
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(_con.foods.length, (index) {
                    final food = _con.foods[index];
                    return FoodGridItemWidget(
                      heroTag: 'category_grid',
                      food: food,
                      onPressed: () {
                        if (currentUser.value.apiToken == null) {
                          Navigator.of(context).pushNamed('/Login');
                        } else if (_con.isSameRestaurants(food)) {
                          _con.addToCart(food);
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AddToCartAlertDialogWidget(oldFood: _con.carts.first.food!, newFood: food, onPressed: (f, {reset = true}) => _con.addToCart(f, reset: true)),
                          );
                        }
                      },
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
