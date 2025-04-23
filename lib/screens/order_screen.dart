import 'package:ecommerce_firebase/widget/app_drawer.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  static const routename = "/order-screen";
  const OrderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
    );
  }
}
