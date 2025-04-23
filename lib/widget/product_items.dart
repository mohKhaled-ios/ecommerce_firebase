import 'package:ecommerce_firebase/provider/auth.dart';
import 'package:ecommerce_firebase/provider/cart.dart';
import 'package:ecommerce_firebase/provider/producte.dart';
import 'package:ecommerce_firebase/screens/producte_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductItems extends StatelessWidget {
  const ProductItems();

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(Productedetailsscreen.routename,
                  arguments: product.id);
            },
            child: Hero(
                tag: product.id!,
                child: FadeInImage(
                  placeholder:
                      AssetImage('assets/images/product-placeholder.png'),
                  image: NetworkImage(product.imageurl!),
                  fit: BoxFit.cover,
                )),
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
                builder: (context, product, child) => IconButton(
                    onPressed: () {
                      product.togglefavoritesStatus(
                          authData.token ?? '', authData.userId);
                    },
                    icon: Icon(product.isfavorite
                        ? Icons.favorite
                        : Icons.favorite_border))),
            title: Text(
              product.title!,
              textAlign: TextAlign.center,
            ),
            trailing: InkWell(
                onTap: () {
                  cart.additems(product.id!, product.price!, product.title!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'add to cart',
                    ),
                    duration: Duration(seconds: 3),
                    action: SnackBarAction(
                        label: 'UNDON',
                        onPressed: () {
                          cart.removesingleitem(product.id!);
                        }),
                  ));
                },
                child: Icon(Icons.shopping_cart)),
          ),
        ));
  }
}
