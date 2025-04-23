import 'package:ecommerce_firebase/provider/products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Productedetailsscreen extends StatelessWidget {
  static const String routename = '/producte-details-screen';
  const Productedetailsscreen();

  @override
  Widget build(BuildContext context) {
    final productid = ModalRoute.of(context)!.settings.arguments as String;
    final loadedproducte =
        Provider.of<Products>(context, listen: false).findbyid(productid);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: loadedproducte.id!,
                child: Image.network(
                  loadedproducte.imageurl!,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                loadedproducte.title!,
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadedproducte.price}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            Container(
              height: 150,
              width: double.infinity,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.purple[400]),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '${loadedproducte.description}',
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]))
        ],
      ),
    );
  }
}
