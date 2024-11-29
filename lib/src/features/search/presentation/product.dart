import 'dart:async';

import 'package:flutter/material.dart';
import 'package:productapp/src/features/search/controller/function.dart';

class Productscreen extends StatefulWidget {
  final String productId;
  const Productscreen({super.key, required this.productId});

  @override
  State<Productscreen> createState() => _ProductscreenState();
}

class _ProductscreenState extends State<Productscreen> {
  Map<dynamic, dynamic>? productDetails;
  bool isLoading = true;
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
    _checkConnectivity();
  }

//Check Connectivity
  Future<void> _checkConnectivity() async {
    bool connectionStatus = await checkConnectivity();
    setState(() {
      isConnected = connectionStatus;
    });
  }

//Fetch product detail
  void fetchProductDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      productDetails = await fetchProduct(widget.productId)
          .timeout(const Duration(seconds: 10));

      setState(() {
        isLoading = false;
      });
      print('Product Details: $productDetails');
    } on TimeoutException catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Timeout error: $e');

      Future.delayed(const Duration(seconds: 10), () {
        showErrorScaffold("Request timed out. Please try again later.");
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching product: $e');

      Future.delayed(const Duration(seconds: 30), () {
        showErrorScaffold("Failed to load product details. try again later");
      });
    }
  }

  void showErrorScaffold(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Products Details',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: productDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(
                    productDetails!['image'],
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return Image.asset(
                        'assets/no_internet.jpg',
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(
                      children: [
                        Text(
                          productDetails!['title'],
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 49, 45, 45)),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              '\$ ${productDetails!['price']}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 5),
                                Text(
                                  productDetails!['rating']['rate'].toString(),
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          productDetails!['description'],
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w300),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
