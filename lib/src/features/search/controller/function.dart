import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

//Function to check internet Connectivity
Future<bool> checkConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  } else {
    return true;
  }
}

//Function to Fetch all products
Future<List<dynamic>> fetchProducts() async {
  var box = await Hive.openBox('productsBox');
  List<dynamic> products;

  if (box.isEmpty) {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      products = List<dynamic>.from(jsonDecode(response.body));
      await box.put('products', products);
    } else {
      throw Exception('Failed to load products');
    }
  } else {
    products = box.get('products');
  }
  return products;
}

//Function to fetch available categories
Future<List<dynamic>> fetchCategories() async {
  var box = await Hive.openBox('categoriesBox');
  List<dynamic> categories;

  if (box.isEmpty) {
    final response = await http
        .get(Uri.parse('https://fakestoreapi.com/products/categories'));
    if (response.statusCode == 200) {
      categories = List<dynamic>.from(jsonDecode(response.body));
      await box.put('categories', categories);
    } else {
      throw Exception('Failed to load categories');
    }
  } else {
    categories = box.get('categories');
  }
  return categories;
}

//Function to fetch product details
Future<Map<String, dynamic>> fetchProduct(String productId) async {
  var box = await Hive.openBox('productCacheBox');
  Map<String, dynamic> product;

  if (box.isEmpty || !box.containsKey(productId)) {
    final response = await http
        .get(Uri.parse('https://fakestoreapi.com/products/$productId'));
    if (response.statusCode == 200) {
      product = Map<String, dynamic>.from(jsonDecode(response.body));
      await box.put(productId, product);
    } else {
      throw Exception('Failed to load product');
    }
  } else {
    product = Map<String, dynamic>.from(box.get(productId));
  }

  return product;
}
