import 'package:ecommerce_firebase/provider/cart.dart';
import 'package:ecommerce_firebase/provider/products.dart';
import 'package:ecommerce_firebase/screens/cart_screen.dart';
import 'package:ecommerce_firebase/widget/app_drawer.dart';
import 'package:ecommerce_firebase/widget/badge.dart';
import 'package:ecommerce_firebase/widget/products_grids.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum filteroption { favoutite, all }

class Producteoverviewscreen extends StatefulWidget {
  static const String routename = '/overview-screen';
  const Producteoverviewscreen();

  @override
  State<Producteoverviewscreen> createState() => _ProducteoverviewscreenState();
}

class _ProducteoverviewscreenState extends State<Producteoverviewscreen> {
  var _isloading = false;
  var _showonlyfavorites = false;
  // var _isinit = false;
  @override
  void initState() {
    super.initState();
    _isloading = true;
    Provider.of<Products>(context, listen: false)
        .fetchandsetproducts()
        .then((_) => setState(() => _isloading = false))
        .catchError((error) => print(error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('MY Shop'),
          actions: [
            PopupMenuButton(
                onSelected: (filteroption selectedvalue) {
                  setState(() {
                    if (selectedvalue == filteroption.favoutite) {
                      _showonlyfavorites = true;
                    } else {
                      _showonlyfavorites = false;
                    }
                  });
                },
                icon: Icon(Icons.more_vert),
                itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text('only favourite'),
                        value: filteroption.favoutite,
                      ),
                      PopupMenuItem(
                        child: Text('show all '),
                        value: filteroption.all,
                      ),
                    ]),
            Consumer<Cart>(
              builder: (context, cart, child) => Badge(
                child: child!,
                value: cart.itemscount.toString(),
                color: Colors.amber,
              ),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Cartscreen.routename);
                  },
                  icon: Icon(Icons.shopping_cart)),
            )
          ],
        ),
        drawer: AppDrawer(),
        body: _isloading
            ? Center(child: CircularProgressIndicator())
            : ProductGrid(showFavs: _showonlyfavorites));
  }
}
