import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateOrder(int total, int status) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? orderId;
    int? userId;

    // Attempt to retrieve orderId and userId as integers
    if (prefs.containsKey('orderId')) {
      orderId = prefs.getInt('orderId');
      if (orderId == null) {
        // If orderId is stored as a String, convert it to an integer
        String? orderIdStr = prefs.getString('orderId');
        if (orderIdStr != null) {
          orderId = int.tryParse(orderIdStr);
        }
      }
    }

    if (prefs.containsKey('userID')) {
      userId = prefs.getInt('userID');
      if (userId == null) {
        // If userId is stored as a String, convert it to an integer
        String? userIdStr = prefs.getString('userID');
        if (userIdStr != null) {
          userId = int.tryParse(userIdStr);
        }
      }
    }

    if (orderId == null || userId == null) {
      throw Exception('Order ID or User ID is null');
    }

    // Log the orderId and userId to check their values
    print('Updating order with orderId: $orderId and userID: $userId');

    // Perform the POST request to update the order
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/order/$orderId/edit'),
      body: jsonEncode({
        'total': total,
        'status': status,
        'userID': userId, // Send userID as an integer
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final responseBody = response.body;
    print('Update response: $responseBody');

    if (response.statusCode == 200) {
      final jsonData = json.decode(responseBody);
      if (jsonData.containsKey('status') && jsonData['status'] == 200) {
        print('Order Updated Successfully');
      } else {
        throw Exception('Unexpected response format or error: ${jsonData['message']}');
      }
    } else {
      throw Exception('Failed to update order: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception caught: $e');
    throw Exception('Error updating order: $e');
  }
}
