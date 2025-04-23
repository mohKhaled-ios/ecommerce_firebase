import 'dart:convert';

import 'package:ecommerce_firebase/provider/cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double ammount;
  final List<CartItem> producte;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.ammount,
    required this.producte,
    required this.dateTime,
  });
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];
  String authtoken = '';
  String userId = '';

  getData(String authtok, String uId) {
    authtoken = authtok;
    userId = uId;

    notifyListeners();
  }

/////////////////لاحظ
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchandsetorders() async {
    final url =
        'https://shop-8cb97-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authtoken';
    try {
      final res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<OrderItem> loadedorders = [];
      extractedData.forEach((orderId, orderData) {
        loadedorders.add(OrderItem(
          id: orderId,
          ammount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          producte: (orderData['productes'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price']))
              .toList(),
        ));
      });
      _orders = loadedorders.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addorder(List<CartItem> cartproducte, double total) async {
    final url =
        'https://shop-8cb97-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authtoken';
    try {
      final timestamp = DateTime.now();
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'amount': total,
            'dateTime': timestamp.toIso8601String(),
            'products': cartproducte
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quantity,
                      'price': cp.price,
                    })
                .toList(),
          }));
      _orders.insert(
          0,
          OrderItem(
              id: json.decode(res.body)['name'],
              ammount: total,
              producte: cartproducte,
              dateTime: timestamp));
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
