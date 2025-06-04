import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import '../repository/settings_repository.dart';
import 'app_colors.dart';

class SwipeButtonWidget extends StatelessWidget {
  const SwipeButtonWidget({
    super.key,
    required this.context,
    required this.numOfItems,
    required this.onSwipe,
    required this.totalPrice,
  });

  final BuildContext context;
  final numOfItems;
  final totalPrice ;

  final Function? onSwipe;

  @override
  Widget build(BuildContext context) {
    return SwipeButton.expand(
      borderRadius: BorderRadius.circular(20),
      thumb: Icon(Icons.shopping_cart, color: AppColors.color26386A, size: 24),
      child: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 80),
            Text(
              "${numOfItems.toString()} items in Cart",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            // SizedBox(width: 8),

            Text(
              "Pay ${totalPrice.toStringAsFixed(2)} ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              setting.value.defaultCurrency,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
      ),
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.color26386A,
      thumbPadding: EdgeInsets.all(2),
      // Optional: adjust to your design
      onSwipe: () async {
        if (onSwipe != null) {
          onSwipe!();
        }
      },
    );
  }
}
