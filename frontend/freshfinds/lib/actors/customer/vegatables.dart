import 'package:flutter/material.dart';

class VegetablesPage extends StatelessWidget {
  const VegetablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vegetables'),
      ),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'List of Vegetables',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            VegetableItemCard(
              title: 'Carrots',
              image: 'assets/carrot.jpg',
              price: 'Rs. 50/kg',
            ),
            VegetableItemCard(
              title: 'Spinach',
              image: 'assets/spinach.jpg',
              price: 'Rs. 30/bundle',
            ),
            VegetableItemCard(
              title: 'Tomato',
              image: 'assets/tomato.jpg',
              price: 'Rs. 40/kg',
            ),
            // Add more VegetableItemCard widgets as needed
          ],
        ),
      ),
    );
  }
}

class VegetableItemCard extends StatelessWidget {
  final String title;
  final String image;
  final String price;

  const VegetableItemCard({super.key, 
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
            width: double.infinity,
            height: 300,
            fit: BoxFit
                .fitWidth, // Ensure the image fills the container without distortion
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
