import 'package:ecommerce_firebase/provider/products.dart';
import 'package:ecommerce_firebase/screens/edit_producte_screen.dart';
import 'package:ecommerce_firebase/widget/Userproductitems.dart';
import 'package:ecommerce_firebase/widget/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Userproductscreen extends StatelessWidget {
  static const routename = 'user-product-screen';
  const Userproductscreen();

  Future<void> _refreshproducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchandsetproducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('your products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Editproductsscreen.routename);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: _refreshproducts(context),
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  child: Consumer<Products>(
                      builder: (context, productsData, child) => Padding(
                            padding: EdgeInsets.all(8),
                            child: ListView.builder(
                                itemCount: productsData.items!.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Userproductitems(
                                          id: productsData.items![index].id!,
                                          title:
                                              productsData.items![index].title!,
                                          imageurl: productsData
                                              .items![index].imageurl!),
                                      Divider()
                                    ],
                                  );
                                }),
                          )),
                  onRefresh: () => _refreshproducts(context))),
    );
  }
}
