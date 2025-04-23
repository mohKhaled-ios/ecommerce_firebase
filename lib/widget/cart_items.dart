import 'package:ecommerce_firebase/provider/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Cartitem extends StatelessWidget {
  final String id;
  final String producteid;
  final int quantity;
  final double price;
  final String title;
  const Cartitem({
    required this.id,
    required this.producteid,
    required this.quantity,
    required this.price,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        onDismissed: (direction) {
          Provider.of<Cart>(context, listen: false).removeitems(producteid);
        },
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('are you sure'),
                  content: Text('do you wat to remove item from the cart?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('no')),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('yes'))
                  ],
                );
              });
        },
        background: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          padding: EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete,
            color: Colors.red,
            size: 40,
          ),
        ),
        key: ValueKey(id),
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: ListTile(
              title: Text(title),
              subtitle: Text('total \$${price * quantity}'),
              trailing: Text("$quantity X"),
              leading: CircleAvatar(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: FittedBox(
                    child: Text('\$$price'),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
