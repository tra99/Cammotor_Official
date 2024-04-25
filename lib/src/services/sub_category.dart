import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/sub_category.dart';

class SubCategoryService {
  Future<List<SubCategoryModel>> fetchDataSubCategoryModel(int currentPage, int pageSize, int categoryId) async {
    final postUrl = "${dotenv.env['BASE_URL']}/api/search1/subcategory";

    final response = await http.post(
      Uri.parse(postUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "page": currentPage,
        "size": pageSize,
        "categoryID": categoryId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final subCategoryList = List<Map<String, dynamic>>.from(
        responseData["students"]["data"],
      );
      print(responseData);
      return subCategoryList.map((subCategoryJson) => SubCategoryModel.fromJson(subCategoryJson)).toList();
    } else {
      throw Exception("Failed to load subcategory data");
    }
  }
}


// class SubCategoryService {
//   Future<List<SubCategoryModel>> fetchDataSubCategoryModel(int currentPage, int pageSize, int categoryId) async {
//     final postUrl = "http://143.198.217.4:1026/api/search1/subcategory";
//     final requestBody = jsonEncode({
//       "size": pageSize,
//       "page": currentPage,
//       "categoryID": categoryId,
//     });

//     final response = await http.post(
//       Uri.parse(postUrl),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: requestBody,
//     );

//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
      
//       // Check if the response contains the expected structure before parsing
//       if (responseData.containsKey("students") && responseData["students"] is Map) {
//         final studentList = List<Map<String, dynamic>>.from(
//           responseData["students"]["data"] ?? [],
//         );

//         // Parse and return subcategory models
//         return studentList.map((studentJson) => SubCategoryModel.fromJson(studentJson)).toList();
//       } else {
//         throw Exception("Unexpected response format");
//       }
//     } else {
//       // Provide a more detailed error message including the status code
//       throw Exception("Failed to load student data. Status Code: ${response.statusCode}");
//     }
//   }
// }

