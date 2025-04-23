import 'package:ecommerce_firebase/provider/products.dart';
import 'package:ecommerce_firebase/screens/edit_producte_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Userproductitems extends StatelessWidget {
  final String id;
  final String title;
  final String imageurl;
  const Userproductitems(
      {required this.id, required this.title, required this.imageurl});

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageurl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(Editproductsscreen.routename, arguments: id);
                },
                icon: Icon(Icons.edit)),
            IconButton(
                onPressed: () async {
                  try {
                    await Provider.of<Products>(context, listen: false)
                        .deleteproduct(id);
                  } catch (e) {
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text('deleting feild'),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
