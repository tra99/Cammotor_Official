import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/store_basket.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order['id']}'),
            Text('Total: ${order['total']}'),
            Text('Status: ${order['status']}'),
            Text('User ID: ${order['userID']}'),
            Text('Payment ID: ${order['paymentID']}'),
            Text('Created At: ${order['created_at']}'),
            Text('Updated At: ${order['updated_at']}'),
          ],
        ),
      ),
    );
  }
}