import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/store_basket.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<StoreBasketModel>> fetchDataStoreBasketModel(int total) async {
  try {
    // Fetch user info to get the userId
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    int? userId;

    if (authToken != null) {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/auth/user/check'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('test') && responseData['test'].containsKey('id')) {
          userId = responseData['test']['id'];
        } else {
          throw Exception('Invalid response format: Missing "id" field.');
        }
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } else {
      throw Exception('Authentication token not found');
    }

    if (userId == null) {
      throw Exception('User ID is null');
    }

    // Perform POST request to fetch store basket data
    final response = await http.post(
      Uri.parse('${dotenv.env['BASE_URL']}/order'),
      body: jsonEncode({
        'total': total,
        'userID': userId,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final responseBody = response.body;
    print('Server response: $responseBody'); // Print the full server response for debugging

    if (response.statusCode == 200) {
      final jsonData = json.decode(responseBody);
      if (jsonData.containsKey('status') && jsonData['status'] == 'success') {
        if (jsonData.containsKey('order') && jsonData['order'] != null) {
          final List<dynamic> storeBasketModelListJson = jsonData['order'];
          // Parse the JSON data into a List of StoreBasketModel objects
          List<StoreBasketModel> storeBasketModels = storeBasketModelListJson.map((storeBasketModelJson) {
            return StoreBasketModel.fromJson(storeBasketModelJson);
          }).toList();
          return storeBasketModels;
        } else {
          // Handle the case where the order data is not present
          return []; // Return an empty list or handle as needed
        }
      } else {
        throw Exception('Unexpected response format or error: ${jsonData['message']}');
      }
    } else {
      throw Exception('Failed to load store basket data: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception caught: $e'); // Print the exception for debugging
    throw Exception('Error fetching data: $e');
  }
}
