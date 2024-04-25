import 'package:flutter/material.dart';

class Product {
  final String name;
  final String description;
  // Add other properties as needed

  Product({
    required this.name,
    required this.description,
    // Initialize other properties here
  });

  static fromJson(e) {}
}

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            // Add other product details here as needed
          ],
        ),
      ),
    );
  }
}
