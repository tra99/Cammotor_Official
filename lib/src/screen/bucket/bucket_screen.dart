import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/store_basket.dart';
import 'basket_notifier.dart';

class BasketPage extends StatefulWidget {
  const BasketPage({Key? key}) : super(key: key);

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  List<Map<String, dynamic>> basketItems = [];
  String? _orderId;

  @override
  void initState() {
    super.initState();
    _loadBasketItems();
  }

  Future<void> _storeOrderId(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('orderId', orderId);
    print('Stored order ID: $orderId');
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
      _orderId = prefs.getString('orderId'); 
    });

    print('Loaded order ID: $_orderId');
    _updateBasketCount();
  }


  Future<void> _addItemToBasket(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final basketStringList = prefs.getStringList('basketItems') ?? [];
    
    basketStringList.add(jsonEncode(item));
    
    await prefs.setStringList('basketItems', basketStringList);
    
    setState(() {
      basketItems.add(item);
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

    if (basketItems.isEmpty && _orderId != null) {
      await _deleteOrder(_orderId!);
      setState(() {
        _orderId = null;
      });
      prefs.remove('orderId');
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    final String url = '${dotenv.env['BASE_URL']}/order/$orderId/delete';

    try {
      final response = await http.post(Uri.parse(url));

      print('API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 200) {
          print('Order deleted successfully');
        } else {
          print('Failed to delete order: ${responseData['message']}');
        }
      } else {
        print('Failed to delete order. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  void _updateBasketCount() {
    final totalCount = basketItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
    BasketNotifier.updateCount(totalCount);
  }

  Future<void> _fetchDataStoreBasketModel(int subcategoryID) async {
    try {
      final response = await fetchDataStoreBasketModel(subcategoryID);
      print('Server response: $response');

      if (response.containsKey('orderId')) {
        final orderId = response['orderId'].toString();
        print('Extracted order ID: $orderId');
        setState(() {
          _orderId = orderId;
        });
        await _storeOrderId(orderId);
      } else {
        print('Unexpected response structure');
        setState(() {
          _orderId = null;
        });
      }
      print('Loaded order ID: $_orderId');
    } catch (e) {
      print('Error fetching data: $e');
    }
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
            child: basketItems.isEmpty
                ? const Center(child: Text('Your basket is empty'))
                : ListView.builder(
                    itemCount: basketItems.length,
                    itemBuilder: (context, index) {
                      final item = basketItems[index];
                      final imageUrl = '${item['img']}';
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
                          subtitle: Text('ចំនួន x ${item['quantity']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              print('Removing item: $item');
                              _removeBasketItem(index);
                            },
                          ),
                          onTap: () {
                            final productId = item['productId'];
                            print('Item: $item');
                            print('Product ID: $productId');
                          },
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
                    Icon(Icons.shopify_sharp, size: 24,),
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