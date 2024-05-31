import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BasketPage extends StatefulWidget {
  const BasketPage({Key? key}) : super(key: key);

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  Map<String, int> _basketItems = {};

  @override
  void initState() {
    super.initState();
    _loadBasketItems();
  }


void _addItemToBasket(String productId) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> basketItems = prefs.getStringList('basketItems') ?? [];

  // Check if the product is already in the basket
  int index = basketItems.indexWhere((item) => jsonDecode(item)['productId'] == productId);
  if (index != -1) {
    // Product already exists in basket, update the quantity
    Map<String, dynamic> existingItem = jsonDecode(basketItems[index]);
    existingItem['quantity']++;
    basketItems[index] = jsonEncode(existingItem);
  } else {
    // Product does not exist in basket, add it with quantity 1
    basketItems.add(jsonEncode({'productId': productId, 'quantity': 1}));
  }

  await prefs.setStringList('basketItems', basketItems);
  _loadBasketItems();
}

Future<void> _loadBasketItems() async {
  final prefs = await SharedPreferences.getInstance();
  final basketItems = prefs.getStringList('basketItems') ?? [];
  final Map<String, int> basketMap = {};

  for (final item in basketItems) {
    final decodedItem = jsonDecode(item);
    final productId = decodedItem['productId'].toString();
    final quantity = decodedItem['quantity'] as int;
    basketMap[productId] = quantity;
  }

  setState(() {
    _basketItems = basketMap;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basket'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _clearBasket();
            },
          ),
        ],
      ),

      body: _basketItems.isEmpty
          ? const Center(child: Text('No items in the basket'))
          : ListView.builder(
              itemCount: _basketItems.length,
              itemBuilder: (context, index) {
                final productId = _basketItems.keys.toList()[index];
                final quantity = _basketItems[productId];
                return ListTile(
                  title: Text('Product ID: $productId'),
                  subtitle: Text('Quantity: $quantity'),
                );
              },
            ),
    );
  }

  Future<void> _clearBasket() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('basketItems');
    setState(() {
      _basketItems.clear();
    });
  }
}

