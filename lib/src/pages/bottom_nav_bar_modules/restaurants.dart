import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../../generated/l10n.dart';
import '../../controllers/home_controller.dart';
import '../../elements/GridWidget.dart';
import '../../models/restaurant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RestaurantsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  RestaurantsWidget({Key? key, this.parentScaffoldKey}) : super(key: key);

  @override
  _RestaurantsWidgetState createState() => _RestaurantsWidgetState();
}

class _RestaurantsWidgetState extends StateMVC<RestaurantsWidget> {
  late HomeController _con;
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Restaurant> _restaurants = [];
  final ScrollController _scrollController = ScrollController();

  _RestaurantsWidgetState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && !isLoading && hasMore) {
        fetchRestaurants();
      }
    });
  }

  Future<void> fetchRestaurants() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse('https://carrytechnologies.co/api/restaurants?page=$currentPage'));      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List list = data['data']['data'];

        if (list.isEmpty) {
          setState(() => hasMore = false);
        } else {
          setState(() {
            _restaurants.addAll(list.map((e) => Restaurant.fromJSON(e)).toList());
            currentPage++;
          });
        }
      }
    } catch (e) {
      print('Error loading restaurants: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          style: Theme.of(context).textTheme.headlineSmall?.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: GridWidget(
                restaurantsList: _restaurants,
                heroTag: 'home_restaurants',
              ),
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}