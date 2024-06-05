import 'dart:convert';
import 'package:cammotor_new_version/src/model/add_to_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

List<AddToCardModel> cachedAddToCardModel = [];

Future<List<AddToCardModel>> fetchDataAddToCardModel() async {
  if (cachedAddToCardModel.isNotEmpty) {
    // If cached data is available, return it immediately.
    return cachedAddToCardModel;
  }

  try {
    final response = await http.get(Uri.parse('${dotenv.env['BASE_URL']}/order_items'));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> addToCardModelListJson = jsonData['order'];

      // Parse the JSON data into a List of CategoryModel objects
      List<AddToCardModel> addToCardModels = addToCardModelListJson.map((addToCardModelJson) {
        return AddToCardModel.fromJson(addToCardModelJson);
        
      }).toList();

      cachedAddToCardModel = addToCardModels;

      return addToCardModels;
    } else {
      throw Exception('Failed to load add to card data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    if (cachedAddToCardModel.isNotEmpty) {
      return cachedAddToCardModel;
    } else {
      throw e;
    }
  }
}