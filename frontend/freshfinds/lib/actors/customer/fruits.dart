import 'package:flutter/material.dart';

class FruitsPage extends StatelessWidget {
  const FruitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruits'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'List of Fruits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FruitItemCard(
              title: 'Apple',
              image: 'assets/apple.jpg',
              price: 'Rs. 100/kg',
            ),
            FruitItemCard(
              title: 'Banana',
              image: 'assets/banana.jpg',
              price: 'Rs. 60/dozen',
            ),
            FruitItemCard(
              title: 'Orange',
              image: 'assets/orange.jpg',
              price: 'Rs. 80/kg',
            ),
            // Add more FruitItemCard widgets as needed
          ],
        ),
      ),
    );
  }
}

class FruitItemCard extends StatelessWidget {
  final String title;
  final String image;
  final String price;

  const FruitItemCard({super.key, 
    required this.title,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            image,
            fit: BoxFit.fitWidth, // Ensure the image fits the width
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
