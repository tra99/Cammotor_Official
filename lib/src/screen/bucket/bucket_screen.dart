import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'basket_notifier.dart';

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
      return decodedItem;
    }).toList();

    setState(() {
      basketItems = loadedItems;
    });
    _updateBasketCount();
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
    BasketNotifier.decrementCount(itemToRemove['quantity'] as int);
  }

  void _updateBasketCount() {
    final totalCount =
        basketItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
    BasketNotifier.updateCount(totalCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 233, 233),
        title: const Text('កន្ត្រកទំនិញរបស់ខ្ញុំ'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: basketItems.length,
              itemBuilder: (context, index) {
                final item = basketItems[index];
                final imageUrl = '${item['img']}';
                return Card(
                  child: ListTile(
                    leading: item['img'] != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : const SizedBox.shrink(),
                    title: Text(item['productName'] ?? 'Unknown Product'),
                    subtitle: Text('ចំនួន x ${item['quantity']}'),
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Container(
              width: 200,
              child: TextButton(
                autofocus: true,
                onPressed: () {
                  print("Press");
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 80, 70, 72),
                  disabledForegroundColor: Colors.grey.withOpacity(0.38),
                  shadowColor: Colors.grey,
                  // elevation: 5,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  textStyle: const TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopify_sharp,size: 24,),
                    Text("ទិញ"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
