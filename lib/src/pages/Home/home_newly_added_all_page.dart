import 'package:flutter/material.dart';
import 'package:restaurantcustomer/src/elements/CardWidget.dart';
import 'package:restaurantcustomer/src/models/restaurant.dart';
import 'package:restaurantcustomer/src/models/route_argument.dart';
import 'package:restaurantcustomer/src/repository/home/get_newly_added_restaurants_repo.dart';

class HomeNewlyAddedAllPage extends StatefulWidget {
  const HomeNewlyAddedAllPage({Key? key}) : super(key: key);

  @override
  State<HomeNewlyAddedAllPage> createState() => _HomeNewlyAddedAllPageState();
}

class _HomeNewlyAddedAllPageState extends State<HomeNewlyAddedAllPage> {
  final List<Restaurant> _items = [];
  bool _isLoading = true;
  String? _error;

  String _tr(BuildContext context, {required String en, required String ar, required String he}) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return ar;
    if (code == 'he') return he;
    return en;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _items.clear();
    });
    try {
      final list = await getNewlyAddedRestaurants();
      setState(() {
        _items.addAll(list);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _tr(context, en: 'New in the app', ar: 'جديد في التطبيق', he: 'חדש באפליקציה');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                      const SizedBox(height: 10),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(_error!, textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final restaurant = _items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/Details',
                              arguments: RouteArgument(id: restaurant.id, param: restaurant, heroTag: 'newly_added_all_${restaurant.id}'),
                            );
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: CardWidget(
                              restaurant: restaurant,
                              heroTag: 'newly_added_all_',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}


