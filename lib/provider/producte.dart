import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String? title;
  final String? description;
  final double? price;
  final String? imageurl;
  bool isfavorite = false;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageurl,
      required this.isfavorite});

  void _setfavValue(bool newvalue) {
    isfavorite = newvalue;
    notifyListeners();
  }

  Future<void> togglefavoritesStatus(String token, String userId) async {
    final oldstatus = isfavorite;
    isfavorite = isfavorite;
    notifyListeners();
    final url =
        'https://shop-8cb97-default-rtdb.firebaseio.com/userFavorite/$userId/$id.json?auth=$token';
    try {
      final res = await http.put(Uri.parse(url), body: json.encode(isfavorite));
      if (res.statusCode >= 400) {
        _setfavValue(oldstatus);
      } else if (res.statusCode == 200) {
        _setfavValue(!oldstatus);
      }
    } catch (e) {
      _setfavValue(oldstatus!);
    }
  }
}
