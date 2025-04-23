import 'dart:math';

import 'package:ecommerce_firebase/model/httpexception.dart';
import 'package:ecommerce_firebase/provider/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  static const routename = '/auth-screen';
  const AuthScreen();

  @override
  Widget build(BuildContext context) {
    final devicesize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                      Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    stops: [0, 1])),
          ),
          SingleChildScrollView(
            child: Container(
              width: devicesize.width,
              height: devicesize.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                      child: Container(
                    transform: Matrix4.rotationZ(-8 * pi / 180)
                      ..translate(-10.0),
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(blurRadius: 8, offset: Offset(0, 2))
                        ]),
                    child: Text(
                      'MY Shop',
                      style: TextStyle(color: Colors.white, fontSize: 50),
                    ),
                  )),
                  Flexible(
                    child: Authcard(),
                    flex: devicesize.width > 600 ? 2 : 1,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Authcard extends StatefulWidget {
  const Authcard();

  @override
  State<Authcard> createState() => _AuthcardState();
}

enum AuthMode {
  login,
  signup,
}

class _AuthcardState extends State<Authcard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formkey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  Map<String, String> _autData = {
    "email": "",
    "password": "",
  };
  var isloading = false;
  final _passwordcontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _confirmpasswordcontroller = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideranimation;
  late Animation<double> _opicityanimation;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideranimation = Tween<Offset>(begin: Offset(0, -15), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _opicityanimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    // _emailcontroller.dispose();
    // _passwordcontroller.dispose();

    super.dispose();
  }

  Future<void> submit() async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formkey.currentState!.save();
    setState(() {
      isloading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_autData['email']!, _autData['password']!);
      } else {
        Provider.of<Auth>(context, listen: false)
            .signUp(_autData['email']!, _autData['password']!);
      }
    } on HttpException catch (error) {
      var errormessage = "Authantication faild";
      if (error.toString().contains('EMAIL_EXISTS')) {
        errormessage = "this email address is already in used";
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errormessage = "is not valid email address";
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errormessage = "this passsword is weak";
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errormessage = "this email is not found";
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errormessage = "this is invalid password";
      }
      _showerrorDialog(errormessage);
    } catch (error) {
      const errormessage = "coudnt authantecate you. please try again";
      _showerrorDialog(errormessage);
    }
    setState(() {
      isloading = false;
    });
  }

  void switchauthmode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final devicesize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
          duration: Duration(
            milliseconds: 300,
          ),
          curve: Curves.easeIn,
          height: _authMode == AuthMode.signup ? 320 : 260,
          constraints: BoxConstraints(
              minHeight: _authMode == AuthMode.signup ? 320 : 260),
          width: devicesize.width * 0.75,
          padding: EdgeInsets.all(15),
          child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return "invalid email";
                        }
                        return null;
                      },
                      onSaved: (Value) {
                        _autData['email'] = Value!;
                      },
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        label: Text('email'),
                      ),
                    ),
                    TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 5) {
                          return "invalid password is to short";
                        }
                        return null;
                      },
                      onSaved: (Value) {
                        _autData['password'] = Value!;
                      },
                      controller: _passwordcontroller,
                      decoration: InputDecoration(
                        label: Text('password'),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      constraints: BoxConstraints(
                          minHeight: _authMode == AuthMode.signup ? 60 : 0,
                          maxHeight: _authMode == AuthMode.signup ? 120 : 0),
                      curve: Curves.easeIn,
                      child: FadeTransition(
                        child: SlideTransition(
                          position: _slideranimation,
                          child: TextFormField(
                            controller: _confirmpasswordcontroller,
                            enabled: _authMode == AuthMode.signup,
                            obscureText: true,
                            validator: _authMode == AuthMode.signup
                                ? (value) {
                                    //value != _passwordcontroller.text
                                    if (value != _passwordcontroller.text) {
                                      return "invalid password is not math";
                                    }
                                    return null;
                                  }
                                : null,
                            decoration: InputDecoration(
                              label: Text('confirm password'),
                            ),
                          ),
                        ),
                        opacity: _opicityanimation,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    isloading
                        ? CircularProgressIndicator()
                        : MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            minWidth: 200,
                            color: Colors.deepOrange,
                            onPressed: () {
                              submit();
                            },
                            /////////////////لحظ
                            child: Text(_authMode == AuthMode.signup
                                ? 'signup'
                                : 'signin')),
                    TextButton(
                        onPressed: switchauthmode,
                        child: Text(
                            _authMode == AuthMode.signup ? 'signin' : 'signup'))
                  ],
                ),
              ))),
    );
  }

  void _showerrorDialog(message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('an error has occured'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: (() {
                    Navigator.of(context).pop();
                  }),
                  child: Text('ok'))
            ],
          );
        });
  }
}
