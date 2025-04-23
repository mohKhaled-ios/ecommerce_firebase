import 'package:ecommerce_firebase/provider/cart.dart' show Cart hide CartItem;
import 'package:ecommerce_firebase/provider/order.dart';
import 'package:ecommerce_firebase/widget/cart_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Cartscreen extends StatelessWidget {
  static const String routename = '/cart-screen';
  const Cartscreen();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('cart screen'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    backgroundColor: Colors.purple,
                    label: Text('\$${cart.totalamount.toStringAsFixed(2)}'),
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return Cartitem(
                        id: cart.items.values.toList()[index].id,
                        producteid: cart.items.keys.toList()[index],
                        quantity: cart.items.values.toList()[index].quantity,
                        price: cart.items.values.toList()[index].price,
                        title: cart.items.values.toList()[index].title);
                  }))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  const OrderButton({required this.cart});

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalamount <= 0 || isloading)
          ? null
          : () async {
              setState(() {
                isloading == true;
              });
              await Provider.of<Order>(context, listen: false).addorder(
                  widget.cart.items.values.toList(), widget.cart.totalamount);
              setState(() {
                isloading = false;
              });
              widget.cart.clear();
            },
      child: isloading
          ? CircularProgressIndicator()
          : Text(
              'Order Now',
              style: TextStyle(color: Colors.purple),
            ),
    );
  }
}
