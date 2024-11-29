import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:productapp/src/features/search/presentation/product.dart';

class Favouritescreen extends StatefulWidget {
  const Favouritescreen({super.key});

  @override
  State<Favouritescreen> createState() => _FavouritescreenState();
}

class _FavouritescreenState extends State<Favouritescreen> {
  late Box favouritesBox;

  @override
  void initState() {
    super.initState();
    _initializeHiveBox();
  }

  void _initializeHiveBox() async {
    favouritesBox = await Hive.openBox('favourites');
    setState(() {});
  }

  List<dynamic> getFavouriteProducts() {
    return favouritesBox.values.where((item) => item is Map).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> favouriteProducts = getFavouriteProducts();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Products'),
        backgroundColor: const Color.fromARGB(255, 12, 82, 140),
      ),
      body: favouriteProducts.isEmpty
          ? const Center(
              child: Text(
                'No favourite products found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favouriteProducts.length,
              itemBuilder: (context, index) {
                final product = favouriteProducts[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(
                      product['image'],
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${product['category'][0].toUpperCase()}${product['category'].substring(1).toLowerCase()}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          '\$${product['price']}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Productscreen(
                            productId: product['id'].toString(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
