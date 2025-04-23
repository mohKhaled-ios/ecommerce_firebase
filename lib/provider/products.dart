import 'dart:convert';

import 'package:ecommerce_firebase/model/httpexception.dart';
import 'package:ecommerce_firebase/provider/producte.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageurl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   isfavorite: false,
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   isfavorite: false,
    //   imageurl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   isfavorite: false,
    //   imageurl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   isfavorite: false,
    //   imageurl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  String? authtoken;
  String? userId;
  //////////////خالى بالك كويس
  getData(String authtok, String uId) {
    authtoken = authtok;
    userId = uId;
  }

  List<Product> get items {
    return _items;
  }

  List<Product> get favoritesitems {
    return _items.where((proditem) => proditem.isfavorite!).toList();
  }

  Product findbyid(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchandsetproducts([bool filterByuser = false]) async {
    final filteredstring =
        filterByuser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://shop-8cb97-default-rtdb.firebaseio.com/products.json?auth=$authtoken&$filteredstring';
    try {
      final res = await http.get(Uri.parse(url));
      final extractedData = json.decode(res.body);
      if (extractedData == null) {
        return;
      }
      url =
          'https://shop-8cb97-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$authtoken';
      final favres = await http.get(Uri.parse(url));
      final favData = json.decode(favres.body);
      final List<Product> loadedproductes = [];
      // extractedData.forEach((prodId, prodData) {
      //   loadedproductes.add(Product(
      //       id: prodId,
      //       title: prodData['title'],
      //       description: prodData['description'],
      //       price: prodData['price'],
      //       imageurl: prodData['imageUrl'],
      //       isfavorite: favData == null ? false : favData[prodId] ?? false));
      // });
      //  _items = loadedproductes;
      notifyListeners();
    } catch (e) {
      //throw e;
    }
  }

  Future<void> addproduct(Product product) async {
    final url =
        'https://shop-8cb97-default-rtdb.firebaseio.com/products.json?auth=$authtoken';
    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageurl,
            'price': product.price,
            'creatorId': userId
          }));
      final newproducte = Product(
          id: json.decode(res.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageurl: product.imageurl,
          isfavorite: product.isfavorite);
      _items.add(newproducte);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateproduct(String id, Product newproduct) async {
    final prodindex = _items.indexWhere((prod) => prod.id == id);
    if (prodindex >= 0) {
      final url =
          'https://shop-8cb97-default-rtdb.firebaseio.com/products/$id.json?auth=$authtoken';
      await http.patch(Uri.parse(url),
          body: json.encode({
            'title': newproduct.title,
            'description': newproduct.description,
            'imageUrl': newproduct.imageurl,
            'price': newproduct.price,
          }));
      _items[prodindex] == newproduct;
      notifyListeners();
    } else {
      print('.....');
    }
  }

  Future<void> deleteproduct(String id) async {
    final url =
        'https://shop-8cb97-default-rtdb.firebaseio.com/products/$id.json?auth=$authtoken';
    final existingproductindex = _items.indexWhere((prod) => prod.id == id);
    ////////////////////////////////////////////////////////////var
    Product? existingproduct = _items[existingproductindex];
    _items.removeAt(existingproductindex);
    notifyListeners();
    final res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      _items.insert(existingproductindex, existingproduct);
      notifyListeners();
      throw HttpException("could not delet producte");
    }
    existingproduct = null;
  }
}
