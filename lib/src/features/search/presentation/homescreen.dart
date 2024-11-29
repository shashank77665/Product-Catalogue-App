import 'package:flutter/material.dart';
import 'package:productapp/src/features/search/controller/function.dart';
import 'package:productapp/src/features/search/presentation/product.dart';

class Homescreen extends StatefulWidget {
  const Homescreen(BuildContext context, {super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late Future<List<dynamic>> allProducts;
  List<dynamic> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  List<dynamic> categories = [];
  String selectedCategory = "All";
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    allProducts = fetchProducts();
    allProducts.then((products) {
      setState(() {
        filteredProducts = products;
      });
    });

    fetchCategories().then((fetchedCategories) {
      setState(() {
        categories = ["All", ...fetchedCategories];
      });
    });

    _checkConnectivity();
  }

//check connectivity
  Future<void> _checkConnectivity() async {
    var connectivity = await checkConnectivity();
    setState(() {
      isConnected = connectivity;
    });
  }

//UI filter
  void filterProducts(String query) {
    allProducts.then((products) {
      setState(() {
        var filteredByCategory = selectedCategory == "All"
            ? products
            : products
                .where((product) => product['category'] == selectedCategory)
                .toList();

        if (query.isEmpty) {
          filteredProducts = filteredByCategory;
        } else {
          filteredProducts = filteredByCategory
              .where((product) => product['title']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            padding: EdgeInsets.only(top: 30),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 12, 82, 140),
                  Color.fromARGB(255, 54, 90, 121),
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'Product Catalog App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            isConnected
                ? Container()
                : Container(
                    decoration: BoxDecoration(color: Colors.red),
                    height: 13,
                    width: double.infinity,
                    child: Text(
                      'Not Connected to Internet',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
            //Search Bar
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: "Type to Search",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                              ),
                              onChanged: (value) {
                                filterProducts(value);
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              filterProducts(searchController.text);
                            },
                            child: const Icon(Icons.search),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Filter option
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 10,
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories.map<DropdownMenuItem<String>>((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      filterProducts(searchController.text);
                    });
                  },
                ),
              ],
            ),
            //Search Result
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: allProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text('No products match your search or filter'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var product = filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Image.network(
                            product['image'],
                            height: 50,
                            width: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Image.asset(
                                'assets/no_internet.jpg',
                                height: 50,
                                width: 50,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                          title: Text(
                            product['title'],
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${product['category'][0].toUpperCase()}${product['category'].substring(1).toLowerCase()}',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                              Text(
                                '\$ ${product['price']}',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text(
                                product['rating']['rate'].toString(),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Productscreen(
                                    productId: product['id'].toString(),
                                  ),
                                ));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
