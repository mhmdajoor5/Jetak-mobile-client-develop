import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
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
                  '🔹 إعادة الطلب',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // التنقل إلى صفحة آخر الطلبات
                    Navigator.pushNamed(context, '/RecentOrders');
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // التنقل إلى صفحة آخر الطلبات
                        Navigator.pushNamed(context, '/RecentOrders');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Order Again',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
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
              'طلباتك السابقة من المطاعم والمتاجر',
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
              'لا توجد طلبات سابقة',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'ابدأ بالطلب من المطاعم والمتاجر',
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