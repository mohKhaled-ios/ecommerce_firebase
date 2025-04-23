import 'package:ecommerce_firebase/provider/products.dart';
import 'package:ecommerce_firebase/widget/product_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavs;
  const ProductGrid({required this.showFavs});

  @override
  Widget build(BuildContext context) {
    final producteData = Provider.of<Products>(context);
    final products =
        showFavs ? producteData.favoritesitems : producteData.items;
    return products.isEmpty
        ? Center(
            child: Text('ther is no producte'),
          )
        : GridView.builder(
            padding: EdgeInsets.all(10),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 10,
                childAspectRatio: 3 / 2,
                crossAxisCount: 2,
                mainAxisSpacing: 10),
            itemBuilder: (context, index) {
              return ChangeNotifierProvider.value(
                value: products[index],
                child: ProductItems(),
              );
            });
  }
}
