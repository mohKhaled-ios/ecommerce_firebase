import 'package:ecommerce_firebase/provider/auth.dart';
import 'package:ecommerce_firebase/provider/cart.dart';
import 'package:ecommerce_firebase/provider/order.dart';
import 'package:ecommerce_firebase/provider/products.dart';
import 'package:ecommerce_firebase/screens/auth_screen.dart';
import 'package:ecommerce_firebase/screens/cart_screen.dart';
import 'package:ecommerce_firebase/screens/edit_producte_screen.dart';
import 'package:ecommerce_firebase/screens/order_screen.dart';
import 'package:ecommerce_firebase/screens/producte_detail_screen.dart';
import 'package:ecommerce_firebase/screens/producte_overview_screen.dart';
import 'package:ecommerce_firebase/screens/user_producte_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
              create: (
                context,
              ) =>
                  Products(),
              update: (context, authvalue, previousproducte) =>
                  previousproducte!
                    ..getData(authvalue.token ?? '', authvalue.userId)),
          ChangeNotifierProvider.value(value: Cart()),
          ChangeNotifierProxyProvider<Auth, Order>(
              create: (context) => Order(),
              update: (context, authvalue, previousorder) => previousorder!
                ..getData(
                  authvalue.token ?? '',
                  authvalue.userId,
                )),
        ],
        child: Consumer<Auth>(
            builder: ((context, auth, child) => MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Flutter Demo',
                    theme: ThemeData(
                      primarySwatch: Colors.purple,
                      primaryColor: Colors.deepOrange,
                    ),
                    home: auth.isAuth
                        ? Producteoverviewscreen()
                        : FutureBuilder(
                            future: auth.tryAutoLogin(),
                            builder: (context, AsyncSnapshot snapshot) =>
                                snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? CircularProgressIndicator()
                                    : AuthScreen(),
                          ),
                    routes: {
                      Producteoverviewscreen.routename: (context) =>
                          Producteoverviewscreen(),
                      Productedetailsscreen.routename: (context) =>
                          Productedetailsscreen(),
                      Cartscreen.routename: (context) => Cartscreen(),
                      AuthScreen.routename: (context) => AuthScreen(),
                      OrderScreen.routename: (context) => OrderScreen(),
                      Userproductscreen.routename: (context) =>
                          Userproductscreen(),
                      Editproductsscreen.routename: (context) =>
                          Editproductsscreen(),
                    }))));
  }
}
