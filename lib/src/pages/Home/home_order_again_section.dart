import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:restaurantcustomer/generated/l10n.dart';
import 'package:restaurantcustomer/src/elements/CardWidget.dart';

import '../../controllers/profile_controller.dart';
import '../../models/order.dart';
import '../../models/restaurant.dart';
import '../../models/route_argument.dart';
import '../../elements/grid_card_widget.dart';

class HomeOrderAgainSection extends StatefulWidget {
  const HomeOrderAgainSection({Key? key}) : super(key: key);

  @override
  _HomeOrderAgainSectionState createState() => _HomeOrderAgainSectionState();
}

class _HomeOrderAgainSectionState extends StateMVC<HomeOrderAgainSection> {
  late ProfileController _con;

  String _tr(BuildContext context, {required String en, required String ar, required String he}) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return ar;
    if (code == 'he') return he;
    return en;
  }

  _HomeOrderAgainSectionState() : super(ProfileController()) {
    _con = controller as ProfileController;
  }

  @override
  void initState() {
    super.initState();
    _loadRecentOrders();
  }

  void _loadRecentOrders() {
    _con.listenForRecentOrders();
  }

  @override
  Widget build(BuildContext context) {
    if (_con.recentOrders.isEmpty) return SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _tr(context, en: 'Order Again', ar: 'إعادة الطلب', he: 'הזמן שוב'),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pushNamed(context, '/RecentOrders');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Color(0xFF2196F3).withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _tr(context, en: 'See all', ar: 'عرض الكل', he: 'ראה הכל'),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Color(0xFF2196F3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _tr(context,
                  en: 'Your previous orders from restaurants and stores',
                  ar: 'طلباتك السابقة من المطاعم والمتاجر',
                  he: 'ההזמנות הקודמות שלך ממסעדות וחנויות'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 15),
          _buildOrdersList(),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_con.recentOrders.isEmpty) {
        return _buildEmptyState();
    }

    Map<String, List<Order>> ordersByRestaurant = {};
    for (Order order in _con.recentOrders) {
      String restaurantId = 'unknown';
      String restaurantName = 'غير محدد';

      if (order.restaurant != null) {
        restaurantName = order.restaurant!.name;
        restaurantId = order.restaurant!.id;
      } else if (order.foodOrders.isNotEmpty &&
          order.foodOrders.first.food?.restaurant != null) {
        restaurantName = order.foodOrders.first.food!.restaurant!.name;
        restaurantId = order.foodOrders.first.food!.restaurant!.id;
      }

      if (!ordersByRestaurant.containsKey(restaurantId)) {
        ordersByRestaurant[restaurantId] = [];
      }
      ordersByRestaurant[restaurantId]!.add(order);
    }

    return Container(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: ordersByRestaurant.length,
        itemBuilder: (context, index) {
          String restaurantId = ordersByRestaurant.keys.elementAt(index);
          List<Order> restaurantOrders = ordersByRestaurant[restaurantId]!;
          Order latestOrder = restaurantOrders.first;

          Restaurant? restaurant;

          if (latestOrder.restaurant != null) {
            restaurant = latestOrder.restaurant!;
          } else if (latestOrder.foodOrders.isNotEmpty &&
              latestOrder.foodOrders.first.food?.restaurant != null) {
            restaurant = latestOrder.foodOrders.first.food!.restaurant!;
          }

          if (restaurant == null) {
            return SizedBox.shrink();
          }

          return Container(
            width: 292, // تغيير من 160 إلى 292
            margin: EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () {
                if (restaurant != null) {
                  Navigator.pushNamed(
                    context,
                    '/Details',
                    arguments: RouteArgument(
                      id: restaurant.id,
                      param: restaurant,
                      heroTag: 'home_order_again_${restaurant.id}',
                    ),
                  );
                }
              },
              child: CardWidget(
                restaurant: restaurant,
                heroTag: 'home_order_again_',
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildEmptyState() {
      return Container(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 50,
              color: Colors.grey[400],
            ),
            SizedBox(height: 10),
              Text(
                _tr(context, en: 'No previous orders', ar: 'لا توجد طلبات سابقة', he: 'אין הזמנות קודמות'),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
              Text(
                _tr(context,
                    en: 'Start ordering from restaurants and stores',
                    ar: 'ابدأ بالطلب من المطاعم والمتاجر',
                    he: 'התחל להזמין ממסעדות וחנויות'),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }


} 