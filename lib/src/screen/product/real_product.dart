import 'package:cached_network_image/cached_network_image.dart';
import 'package:cammotor_new_version/src/providers/real_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

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

  @override
  void initState() {
    super.initState();
    
    searchController = SearchController();
    
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchInitialData(widget.subcategoryID);
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
                // Perform action on basket icon tap
              },
              child: const Icon(
                Icons.shopping_basket,
                size: 24,
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
                  controller: searchController, // Assuming searchController is defined
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
                            product.instock,
                            product.qty.toDouble(),
                            product.discount.toInt(),
                            product.yearID,
                            product.modelID,
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
    int quantity,
    double discount,
    int yearID,
    int modelID,
    int resourceID,
    String instock,
    Function(int) updateQtyCallback,
  ) async {
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
              content: SingleChildScrollView(
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
                        '• Quantity: $quantity',
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
                                    updateQtyCallback(quantity - 1);
                                  },
                                  color: Colors.white,
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    updateQtyCallback(quantity + 1);
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
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        '\$ $discount',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: const Color.fromARGB(255, 66, 53, 53),
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        color: Colors.brown,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_basket_outlined,
                          color: Color.fromARGB(255, 249, 184, 87),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
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
