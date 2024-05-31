import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cammotor_new_version/src/providers/real_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

import '../bucket/bucket_screen.dart';

class RealProduct extends StatefulWidget {
  final int subcategoryID;

  const RealProduct({Key? key, required this.subcategoryID}) : super(key: key);

  @override
  State<RealProduct> createState() => _RealProductState();
}

class _RealProductState extends State<RealProduct> with AutomaticKeepAliveClientMixin{
  final scrollController = ScrollController();
  late SearchController searchController;
  late TextEditingController textEditingController = TextEditingController();

  int basketCount = 0;
  int qty = 0;

  void incrementQuantity() {
    setState(() {
      qty++;
    });
  }

  void decrementQuantity() {
    setState(() {
      if (qty > 0) {
        qty--;
      }
    });
  }
  void updateQuantity(int newQuantity) {
    setState(() {
      qty = newQuantity;
    });
  }

  Future<void> _saveBasketItem(String productName, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> basketItems = prefs.getStringList('basketItems') ?? [];

    // Check if the product is already in the basket
    int index = basketItems.indexWhere((item) => jsonDecode(item)['productName'] == productName);
    if (index != -1) {
      // Product already exists in basket, update the quantity
      Map<String, dynamic> existingItem = jsonDecode(basketItems[index]);
      existingItem['quantity'] += quantity;
      basketItems[index] = jsonEncode(existingItem);
    } else {
      // Product does not exist in basket, add it with quantity
      basketItems.add(jsonEncode({'productName': productName, 'quantity': quantity}));
    }

    // Save the updated basket items
    await prefs.setStringList('basketItems', basketItems);
    _loadBasketCount();
  }




Future<void> _loadBasketCount() async {
  final prefs = await SharedPreferences.getInstance();
  final basketItems = prefs.getStringList('basketItems') ?? [];
  setState(() {
    basketCount = basketItems.length;
  });
}


  @override
  void initState() {
    super.initState();
    
    searchController = SearchController();
    
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchInitialData(widget.subcategoryID);
      _loadBasketCount();
    });
    
  }
  
  Future<void> fetchInitialData(int subcategoryID) async {
    final provider = Provider.of<RealProductProvider>(context, listen: false);
    try {
      await provider.fetchInitialData(subcategoryID);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _incrementBasketCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      basketCount++;
      prefs.setInt('basketCount', basketCount);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BasketPage()),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.shopping_basket,
                    size: 24,
                  ),
                  if (basketCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$basketCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Consumer<RealProductProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    updateProductList(value, provider);
                  },
                  decoration: InputDecoration(
                    hintText: 'ស្វែងរកគ្រឿងបន្លាស់',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 217, 217, 217),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!provider.isLoading &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      provider.fetchProductData(
                        provider.currentPage + 1,
                        provider.pageSize,
                        widget.subcategoryID,
                      );
                      return true;
                    }
                    return false;
                  },
                  child: GridView.builder(
                    controller: scrollController,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: provider.filteredProductData.length, // Use filtered data length
                    itemBuilder: (context, index) {
                      final product = provider.filteredProductData[index]; // Use filtered data
                      if (product.subcategoryID != widget.subcategoryID) {
                        return const SizedBox.shrink(); // Hide products of other categories
                      }
                      return GestureDetector(
                        onTap: () {
                          _showMyDialog(
                            product.name,
                            '${dotenv.env['BASE_URL']}/storage/${product.img}',
                            // imageUrl: '${dotenv.env['BASE_URL']}/api/storage',
                            product.instock.toString(),
                            product.qty,
                            product.discount.toDouble(),
                            product.yearID,
                            product.modelID,
                            product.price.toString(),
                            product.resourceID.toString(),
                            
                            updateQuantity,
                          );
                        },
                        child: Theme(
                          data: ThemeData(dialogBackgroundColor: Colors.white),
                          child: Card(
                            color: Colors.white,
                            elevation: 2.0,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(255, 65, 62, 62),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(14),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Center(
                                          child: Text(
                                            "${product.price} \$",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 2,
                                    child: Image(
                                      image: CachedNetworkImageProvider(
                                          '${dotenv.env['BASE_URL']}/storage/${product.img}',
                                          maxWidth: 200,
                                          maxHeight: 200),
                                      // fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 2, bottom: 10),
                                        child: Center(
                                          child: Text(
                                            product.name,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(255, 65, 62, 62),
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(14),
                                          topLeft: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: InkWell(
                                          onTap: () {
                                            // onAddToCart(productName);
                                          },
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (provider.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }

  void updateProductList(String value, RealProductProvider provider) {
    if (value.isEmpty) {
      provider.resetProductData(); 
    } else {
      provider.filterProductData(value.toLowerCase()); 
    }
  }

  void _scrollListener() {
    final provider = Provider.of<RealProductProvider>(context, listen: false);
    if (!provider.isLoading &&
        scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
      provider.fetchProductData(
          provider.currentPage + 1, provider.pageSize, widget.subcategoryID);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _showMyDialog(
    String productName,
    String img,
    String instock,
    int initialQuantity,
    double discount,
    int yearID,
    int modelID,
    String price,
    String resourceID,
    Function(int) updateQtyCallback,
  ) async {
    int dialogQty = 0;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
          child: Theme(
            data: ThemeData(dialogBackgroundColor: Colors.white),
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Center(
                child: Text(
                  productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 92, 88, 88),
                  ),
                ),
              ),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Center(
                            child: Image.network(
                              img,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.25,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '• In Stock: $instock',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Available Quantity: $initialQuantity',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Discount: \$ $discount',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '• Year: $yearID',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromARGB(255, 66, 53, 53),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (dialogQty > 0) {
                                            dialogQty--;
                                            updateQtyCallback(dialogQty);
                                          }
                                        });
                                      },
                                      color: Colors.white,
                                    ),
                                    Text(
                                      '$dialogQty', // User's selected quantity
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          dialogQty++;
                                          updateQtyCallback(dialogQty);
                                        });
                                      },
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        '\$ $price',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 92, 88, 88),
                      ),
                      onPressed: () {
                        updateQtyCallback(dialogQty);
                        _saveBasketItem(resourceID, dialogQty);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  bool get wantKeepAlive => true;
}


// save qty in local storage when user click increase or decrease

// Future<void> _showMyDialog(
//   String productName,
//   String img,
//   String instock,
//   int initialQuantity,
//   double discount,
//   int yearID,
//   int modelID,
//   String resourceID,
//   Function(int) updateQtyCallback,
// ) async {
//   int dialogQty = await _getSavedQuantity(resourceID);

//   return showDialog<void>(
//     context: context,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return Center(
//         child: Theme(
//           data: ThemeData(dialogBackgroundColor: Colors.white),
//           child: AlertDialog(
//             backgroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             title: Center(
//               child: Text(
//                 productName,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromARGB(255, 92, 88, 88),
//                 ),
//               ),
//             ),
//             content: StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//                 return SingleChildScrollView(
//                   child: SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         Center(
//                           child: Image.network(
//                             img,
//                             width: double.infinity,
//                             height: MediaQuery.of(context).size.height * 0.25,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           '• In Stock: $instock',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           '• Available Quantity: $initialQuantity',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           '• Discount: \$ $discount',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           '• Year: $yearID',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 color: const Color.fromARGB(255, 66, 53, 53),
//                               ),
//                               child: Row(
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.remove),
//                                     onPressed: () {
//                                       setState(() {
//                                         if (dialogQty > 0) {
//                                           dialogQty--;
//                                           updateQtyCallback(dialogQty);
//                                           _saveQuantity(resourceID, dialogQty);
//                                         }
//                                       });
//                                     },
//                                     color: Colors.white,
//                                   ),
//                                   Text(
//                                     '$dialogQty',
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(Icons.add),
//                                     onPressed: () {
//                                       setState(() {
//                                         dialogQty++;
//                                         updateQtyCallback(dialogQty);
//                                         _saveQuantity(resourceID, dialogQty);
//                                       });
//                                     },
//                                     color: Colors.white,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//             actions: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 10),
//                     child: Text(
//                       '\$ $discount',
//                       style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         width: 1,
//                         color: const Color.fromARGB(255, 66, 53, 53),
//                       ),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         bottomRight: Radius.circular(10),
//                       ),
//                       color: Colors.brown,
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.shopping_basket_outlined,
//                         color: Color.fromARGB(255, 249, 184, 87),
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

// Future<void> _saveQuantity(String resourceID, int quantity) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setInt(resourceID, quantity);
// }

// Future<int> _getSavedQuantity(String resourceID) async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getInt(resourceID) ?? 0;
// }

