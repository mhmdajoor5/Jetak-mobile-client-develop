import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/cuisine_details_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/grid_card_widget.dart';
import '../models/route_argument.dart';

class CuisineDetailsWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  const CuisineDetailsWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _CuisineDetailsWidgetState createState() => _CuisineDetailsWidgetState();
}

class _CuisineDetailsWidgetState extends StateMVC<CuisineDetailsWidget> {
  late CuisineDetailsController _con;

  _CuisineDetailsWidgetState() : super(CuisineDetailsController()) {
    _con = controller as CuisineDetailsController;
  }

  @override
  void initState() {
    super.initState();
    if (widget.routeArgument?.id != null) {
      _con.loadCuisineDetails(widget.routeArgument!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _con.cuisine?.name ?? (_con.isStoreType ? 'Store Category' : 'Cuisine'),
          style: Theme.of(context).textTheme.headlineMedium?.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _con.refreshCuisineDetails(widget.routeArgument?.id ?? ''),
        child: _con.isLoading
            ? CircularLoadingWidget(height: 500)
            : _con.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).hintColor,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Error loading cuisine details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          _con.errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _con.loadCuisineDetails(widget.routeArgument?.id ?? ''),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cuisine header
                        if (_con.cuisine != null)
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_con.cuisine!.description != null && _con.cuisine!.description!.isNotEmpty)
                                  Text(
                                    _con.cuisine!.description!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  )
                                else if (_con.isStoreType)
                                  Text(
                                    _con.browseMessage,
                                    style: Theme.of(context).textTheme.bodyMedium?.merge(
                                      TextStyle(color: Theme.of(context).hintColor),
                                    ),
                                  ),
                                SizedBox(height: 20),
                                Text(
                                  '${_con.restaurants.length} ${_con.entityName}',
                                                                     style: Theme.of(context).textTheme.headlineSmall?.merge(
                                     TextStyle(
                                       fontWeight: FontWeight.w600,
                                       color: Theme.of(context).colorScheme.secondary,
                                     ),
                                   ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Restaurants grid
                        if (_con.restaurants.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: _con.restaurants.map((restaurant) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: GridCardWidget(restaurant: restaurant),
                              )).toList(),
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    _con.entityIcon,
                                    size: 64,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    _con.noDataMessage,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
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

 