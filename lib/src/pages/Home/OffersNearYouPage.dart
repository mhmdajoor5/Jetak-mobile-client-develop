import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../../generated/l10n.dart';
import '../../controllers/home_controller.dart';
import '../../elements/GridWidget.dart';
import '../../models/restaurant.dart';

class OffersNearYouPage extends StatefulWidget {
  const OffersNearYouPage({Key? key}) : super(key: key);

  @override
  StateMVC<OffersNearYouPage> createState() => _OffersNearYouPageState();
}

class _OffersNearYouPageState extends StateMVC<OffersNearYouPage> {
  late HomeController _con;

  _OffersNearYouPageState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(S.of(context).offers_near_you,),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).hintColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridWidget(
                restaurantsList: _con.topRestaurants,
                heroTag: 'offers_near_you',
              ),
            ],
          ),
        ),
      ),
    );
  }
}