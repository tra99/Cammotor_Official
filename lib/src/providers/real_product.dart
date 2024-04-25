import 'package:cammotor_new_version/src/model/real_product.dart';
import 'package:flutter/material.dart';
import '../services/real_product.dart';

class RealProductProvider extends ChangeNotifier {
  List<RealProductModel> productData = [];
  int currentPage = 1;
  int pageSize = 11;
  bool isLoading = false;
  List<RealProductModel> cachedData = [];
  final RealProductService productService = RealProductService(); 
  List<RealProductModel> filteredProductData = [];

  void filterProductData(String query) {
    filteredProductData = productData
        .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
  void resetProductData() {
    filteredProductData = List.from(productData);
    notifyListeners();
  }

  Future<void> fetchProductData(int page, int pageSize, int subcategoryID) async {
    isLoading = true;
    notifyListeners(); // Notify listeners before fetching data
    
    try {
      final products = await productService.fetchProductData(page, pageSize, subcategoryID);

      if (products.isNotEmpty) {
        productData.addAll(products);
        currentPage = page;
      }
    } catch (e) {
      print("Error fetching product data: $e");
      // Handle errors as needed (throw an exception, log the error, etc.)
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInitialData(int subcategoryID) async {
    isLoading = true;
    notifyListeners();

    try {
      productData.clear();
      currentPage = 1;

      final products = await productService.fetchProductData(currentPage, pageSize, subcategoryID);
      productData.addAll(products);
      filteredProductData.addAll(products); // Set filtered data initially to all products
    } catch (e) {
      print("Error fetching initial data: $e");
      // Handle errors as needed (throw an exception, log the error, etc.)
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}




