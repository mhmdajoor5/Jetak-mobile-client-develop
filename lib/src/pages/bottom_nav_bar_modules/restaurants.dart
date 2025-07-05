import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../generated/l10n.dart';
import '../../elements/CaregoriesCarouselWidget.dart';
import '../../elements/SearchBarWidget.dart';
import '../../models/category.dart';
import '../../models/restaurant.dart';
import '../../elements/grid_card_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RestaurantsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;
  final String restaurantType;

  const RestaurantsWidget({
    Key? key,
    this.parentScaffoldKey,
    required this.restaurantType,
  }) : super(key: key);

  @override
  State<RestaurantsWidget> createState() => _RestaurantsWidgetState();
}

class _RestaurantsWidgetState extends State<RestaurantsWidget> {
  static const _pageSize = 10;
  final PagingController<int, Restaurant> _pagingController =
  PagingController(firstPageKey: 1);
  List<Category> categories = [];

  late final String _entityType;

  @override
  void initState() {
    super.initState();
    _entityType = widget.restaurantType;
    _loadCategories();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('https://carrytechnologies.co/api/categories'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['data'];
        setState(() {
          categories = list.map((e) => Category.fromJSON(e)).toList();
        });
      } else {
        print('Failed to load categories, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final String apiUrl = 'https://carrytechnologies.co/api/restaurants?page=$pageKey&type=$_entityType';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List rawList = data['data']['data'];
        final int lastPage = data['data']['last_page'];

        final List<Restaurant> filteredList = rawList
            .map((e) => Restaurant.fromJSON(e))
            .where((r) => r.restaurantType?.toLowerCase() == _entityType.toLowerCase())
            .toList();

        final isLastPage = pageKey >= lastPage;
        if (isLastPage) {
          _pagingController.appendLastPage(filteredList);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(filteredList, nextPageKey);
        }
      } else {
        _pagingController.error = 'Failed to load data';
      }
    } catch (error) {
      print('Error fetching $_entityType: $error');
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
      body: RefreshIndicator(
        onRefresh: () async {
          _pagingController.refresh();
          await _loadCategories();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SearchBarWidget(
                  onClickFilter: (val) {
                    print("Filter clicked: $val");
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: CategoriesCarouselWidget(categories: categories),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: PagedSliverList<int, Restaurant>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Restaurant>(
                  itemBuilder: (context, item, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: GridCardWidget(restaurant: item),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => Center(
                    child: Text(
                      widget.restaurantType.toLowerCase() == 'restaurant'
                          ? S.of(context).no_restaurants_found
                          : S.of(context).no_stores_found,
                    ),
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