import 'package:flutter/material.dart';
import '../../models/restaurant.dart';

class OffersNearYouPage extends StatelessWidget {
  const OffersNearYouPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Restaurant> sampleRestaurants = [
      Restaurant(id: '1', name: 'Burger House', description: 'Best burgers in town'),
      Restaurant(id: '2', name: 'Pizza Corner', description: 'Delicious pizza offers'),
      Restaurant(id: '3', name: 'Sushi World', description: 'Fresh and tasty sushi'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers Near You'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = sampleRestaurants[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(restaurant.name),
              subtitle: Text(restaurant.description),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to restaurant details or offers page
              },
            ),
          );
        },
      ),
    );
  }
}