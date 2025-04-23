import 'dart:async';
import 'dart:convert';

import 'package:ecommerce_firebase/model/httpexception.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId.toString();
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBOeq9OFJ52P2dJfQoF5VBd9yPERFlxCxM';
    try {
      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = json.decode(res.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'].toString();
      _userId = responseData['localId'].toString();
      _expiryDate = DateTime.now().add(
          Duration(seconds: int.parse(responseData['expiresIn'].toString())));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token.toString(),
        'userId': _userId.toString(),
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final Map<String, dynamic> extractedData = json
        .decode(prefs.getString('userData') as String) as Map<String, dynamic>;

    final expiryDate = DateTime.parse(extractedData['expiryDate'] as String);
    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = extractedData['token'] as String;
    _userId = extractedData['userId'] as String;
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(days: timeToExpiry), logout);
  }
}



// class Auth with ChangeNotifier {
//   String? _token;
//   DateTime? _expiryDate;
//   String? _userId;
//   Timer? _authTimer;

//   bool get isAuth {
//     // return token != null;
//     if (_token == null) {
//       return false;
//     }
//     return true;
//   }

//   String get token {
//     if (_expiryDate != null &&
//         _expiryDate!.isAfter(DateTime.now()) &&
//         _token != null) {
//       return _token!;
//     }
//     return null.toString();
//   }

//   String get userId {
//     return _userId!;
//   }

//   Future<void> userSignUp(String email, String password) async {
//     /* final responce =*/ await http.post(
//       Uri.parse(
//           'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBOeq9OFJ52P2dJfQoF5VBd9yPERFlxCxM'),
//       body: json.encode(
//         {
//           'email': email,
//           'password': password,
//           'returnSecureToken': true,
//         },
//       ),
//     );
//   }

//   Future<void> userSignIn(String email, String password) async {
//     try {
//       final responce = await http.post(
//         Uri.parse(
//             'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBOeq9OFJ52P2dJfQoF5VBd9yPERFlxCxM'),
//         body: json.encode(
//           {
//             'email': email,
//             'password': password,
//             'returnSecureToken': true,
//           },
//         ),
//       );
//       final Responce = json.decode(responce.body);
//       if (Responce['error'] != null) {
//         throw HttpException(Responce['error']['message']);
//       }
//       _token = Responce['idToken'];
//       _userId = Responce['localId'];
//       _expiryDate = DateTime.now().add(
//         Duration(
//           seconds: int.parse(
//             Responce['expiresIn'],
//           ),
//         ),
//       );
//       _autoLogOut();
//       notifyListeners();
//       final prefs = await SharedPreferences.getInstance();
//       final userDate = json.encode(
//         {
//           'token': _token,
//           'userId': _userId,
//           'expiryDate': _expiryDate!.toIso8601String(),
//         },
//       );
//       prefs.setString('userData', userDate);
//     } catch (error) {
//       rethrow;
//     }
//   }

//   Future<bool> tryAutoLogin() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!prefs.containsKey('userDate')) {
//       return false;
//     }
//     final extractDate = json.decode(prefs.getString('userDate')!).toString()
//         as Map<String, Object>;
//     final expiryDate = DateTime.parse(extractDate['expiryDate'] as String);
//     if (expiryDate.isAfter(DateTime.now())) {
//       return false;
//     }
//     _token = extractDate['token'] as String;
//     _userId = extractDate['userId'] as String;
//     _expiryDate = expiryDate;
//     notifyListeners();
//     _autoLogOut();
//     return true;
//   }

//   Future<void> logOut() async {
//     _token = null;
//     _userId = null;
//     _expiryDate = null;
//     if (_authTimer != null) {
//       _authTimer!.cancel();
//     }
//     notifyListeners();
//     final prefs = await SharedPreferences.getInstance();
//     prefs.clear();
//   }

//   void _autoLogOut() {
//     if (_authTimer != null) {
//       _authTimer!.cancel();
//       _authTimer = null;
//     }
//     final timeToExpire = _expiryDate!.difference(DateTime.now()).inSeconds;
//     _authTimer = Timer(Duration(seconds: timeToExpire), logOut);
//   }
// }

////الاول
// class Auth with ChangeNotifier {
//   String? _token;
//   DateTime? _expirydate;
//   String? _userid;
//   Timer? _authtimer;

//   bool get isAuth {
//     return token != null;
//   }

//   String? get token {
//     if (_expirydate != null &&
//         _expirydate!.isAfter(DateTime.now()) &&
//         _token != null) {
//       return _token!; ///////////المفروض
//     }

//     /////////////////////المشكله
//     return null.toString();
//   }

//   String? get userid {
//     return _userid.toString();
//   }

//   Future<void> _authenticate(
//       String email, String password, String urlsegment) async {
//     final url =
//         'https://identitytoolkit.googleapis.com/v1/accounts:$urlsegment?key=AIzaSyBOeq9OFJ52P2dJfQoF5VBd9yPERFlxCxM';
//     try {
//       final res = await http.post(Uri.parse(url),
//           body: json.encode({
//             "email": email,
//             "password": password,
//             "returnSecureToken": true,
//           }));
//       final responseData = jsonDecode(res.body);
//       if (responseData['error'] != null) {
//         throw HttpException(responseData['error']['message']);
//       }
//       _token = responseData['idToken'].toString();
//       _userid = responseData['localId'].toString();
//       _expirydate = DateTime.now()
//           .add(Duration(seconds: int.parse(responseData['expiresIn'])));
//       _autologout();
//       notifyListeners();
//       final prefs = await SharedPreferences.getInstance();
//       String userData = json.encode({
//         'token': _token.toString(),
//         'userId': _userid.toString(),
//         'expiryDate': _expirydate!.toString(),
//       });
//       prefs.setString('userData', userData.toString());
//     } catch (e) {
//       throw e;
//     }
//   }

//   Future<void> signup(String email, String password) async {
//     return _authenticate(email, password, "signUp");
//   }

//   Future<void> login(String email, String password) async {
//     return _authenticate(email, password, "signInWithPassword");
//   }

//   Future<bool?> tryAutoLogin() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!prefs.containsKey('userData')) {
//       return false;
//     }
//     final extractedUserData = json.decode(prefs.getString('userData') as String)
//         as Map<String, dynamic>;
//     final expiryDate =
//         DateTime.parse(extractedUserData['expiryDate'] as String);
// ///////////////////////////is after
//     if (expiryDate.isBefore(DateTime.now())) {
//       return false;
//     }
//     _token = extractedUserData['token'].toString();
//     _userid = extractedUserData['userId'].toString();
//     _expirydate = expiryDate;
//     notifyListeners();
//     _autologout();
//     return true;
//   }

//   // Future<void> Logout() async {
//   //   _token = null!;
//   //   _userid = null;
//   //   _expirydate = null;
//   //   if (_authtimer != null) {
//   //     _authtimer!.cancel();
//   //     _authtimer = null;
//   //   }
//   //   notifyListeners();
//   //   final prefs = await SharedPreferences.getInstance();
//   //   prefs.clear();
//   // }
//   Future<void> Logout() async {
//     _token = null.toString();
//     _userid = null.toString();
//     _expirydate = null.toString() as DateTime?;
//     if (_authtimer != null) {
//       _authtimer!.cancel();
//       _authtimer = null.toString() as Timer?;
//     }
//     notifyListeners();
//     final prefs = await SharedPreferences.getInstance();
//     prefs.clear();
//   }

//   void _autologout() {
//     if (_authtimer != null) {
//       _authtimer!.cancel();
//       // _authtimer = null;
//     }
//     final timetoexpiry = _expirydate!.difference(DateTime.now()).inSeconds;
//     _authtimer = Timer(Duration(seconds: timetoexpiry), Logout);
//   }
// }
