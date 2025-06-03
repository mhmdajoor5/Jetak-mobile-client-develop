import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';

Widget swipeButtonWidget({required BuildContext context}) {
  return SwipeButton.expand(
    thumb: Icon(
      Icons.arrow_forward,
      color: Colors.white,
      size: 24,
    ),
    child: Text(
      "Swipe to confirm",
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    activeThumbColor: Colors.blue.shade800,
    activeTrackColor: Colors.blue.shade300,
    thumbPadding: EdgeInsets.all(4),
    // elevation: 2,
    // radius: 10,
    onSwipe: () async {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Processing..."),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Simulate async operation
      await Future.delayed(Duration(seconds: 2));

      // Show completion message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Action completed successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    },
  );
}