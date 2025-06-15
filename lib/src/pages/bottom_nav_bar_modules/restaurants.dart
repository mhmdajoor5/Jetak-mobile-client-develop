import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../generated/l10n.dart';
import '../../models/restaurant.dart';
import '../../elements/grid_card_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RestaurantsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  const RestaurantsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);

  @override
  State<RestaurantsWidget> createState() => _RestaurantsWidgetState();
}

class _RestaurantsWidgetState extends State<RestaurantsWidget> {
  static const _pageSize = 10;

  final PagingController<int, Restaurant> _pagingController =
  PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final response = await http.get(Uri.parse(
        'https://carrytechnologies.co/api/restaurants?page=$pageKey',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['data']['data'];
        final int lastPage = data['data']['last_page'];

        final newItems = list.map((e) => Restaurant.fromJSON(e)).toList();

        final isLastPage = pageKey >= lastPage;
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      } else {
        _pagingController.error = 'Failed to load data';
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey?.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).restaurants,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: RefreshIndicator(
          onRefresh: () => Future.sync(() => _pagingController.refresh()),
          child: PagedMasonryGridView.count(
            pagingController: _pagingController,
            crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            builderDelegate: PagedChildBuilderDelegate<Restaurant>(
              itemBuilder: (context, item, index) => GridCardWidget(
                restaurant: item,
              ),
              noItemsFoundIndicatorBuilder: (_) => Center(
                child: Text('S.of(context).no_restaurants_found'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
