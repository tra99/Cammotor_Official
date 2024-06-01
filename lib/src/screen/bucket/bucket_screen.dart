import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BasketPage extends StatefulWidget {
  const BasketPage({Key? key}) : super(key: key);

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  List<Map<String, dynamic>> basketItems = [];

  @override
  void initState() {
    super.initState();
    _loadBasketItems();
  }

  Future<void> _loadBasketItems() async {
    final prefs = await SharedPreferences.getInstance();
    final basketStringList = prefs.getStringList('basketItems') ?? [];

    List<Map<String, dynamic>> loadedItems = basketStringList.map((item) {
      final decodedItem = Map<String, dynamic>.from(jsonDecode(item));
      print('Loaded item: $decodedItem'); // Debug: Print the decoded item
      return decodedItem;
    }).toList();

    setState(() {
      basketItems = loadedItems;
    });
  }

  Future<void> _removeBasketItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final itemToRemove = basketItems[index];
    basketItems.removeAt(index);
    final updatedBasketStringList = basketItems.map((item) {
      return jsonEncode(item);
    }).toList();

    await prefs.setStringList('basketItems', updatedBasketStringList);
    setState(() {});

    final totalCount = basketItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
    await prefs.setInt('basketCount', totalCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 233, 233),
        title: const Text('កន្ត្រកទំនិញរបស់ខ្ញុំ'),
      ),
      body: ListView.builder(
        itemCount: basketItems.length,
        itemBuilder: (context, index) {
          final item = basketItems[index];
          print('Basket item: $item'); // Debug: Print the entire item
          final imageUrl = '${dotenv.env['BASE_URL']}/storage/${item['img']}';
          print('Image URL: $imageUrl'); 
          return Card(
            child: ListTile(
              leading: item['img'] != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    )
                  : const SizedBox.shrink(),
              title: Text(item['productName'] ?? 'Unknown Product'),
              subtitle: Text('Quantity: ${item['quantity']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _removeBasketItem(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
