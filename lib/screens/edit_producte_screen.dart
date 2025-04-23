import 'package:ecommerce_firebase/provider/producte.dart';
import 'package:ecommerce_firebase/provider/products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Editproductsscreen extends StatefulWidget {
  static const String routename = '/editproductescreen';
  const Editproductsscreen();

  @override
  State<Editproductsscreen> createState() => _EditproductsscreenState();
}

class _EditproductsscreenState extends State<Editproductsscreen> {
  final _pricefucosNode = FocusNode();
  final _descriptionfucosNode = FocusNode();
  final _imageurlcontroller = TextEditingController();
  final _imageurlfucosNode = FocusNode();
  final _formkey = GlobalKey<FormState>();
  var _editedproducte =
      ////////////////التصحيح
      Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageurl: '',
    isfavorite: false,
  );
  Map _intialvalues = {
    'title': '',
    'description': '',
    'price': 0,
    'imageurl': ''
  };
  var isloading = false;
  var _isinit = true;
  @override
  void initState() {
    super.initState();
    _imageurlfucosNode.addListener(_updateimageurl);
  }

  void _updateimageurl() {
    if (!_imageurlfucosNode.hasFocus) {
      if (!_imageurlcontroller.text.startsWith('http') &&
              !_imageurlcontroller.text.startsWith('https') ||
          (!_imageurlcontroller.text.endsWith('.png') &&
              !_imageurlcontroller.text.endsWith('.jpg') &&
              !_imageurlcontroller.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveform() async {
    final isvalid = _formkey.currentState!.validate();
    if (!isvalid) {
      return;
    } else {
      setState(() {
        isloading = true;
      });
      _formkey.currentState!.save();
      setState(() {
        isloading = true;
      });
      if (_editedproducte.id.isNotEmpty) {
        await Provider.of<Products>(context, listen: false)
            .updateproduct(_editedproducte.id, _editedproducte);
      } else {
        try {
          await Provider.of<Products>(context, listen: false)
              .addproduct(_editedproducte);
        } catch (e) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('an error occure'),
              content: Text('some thing want wrong'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('okey!'))
              ],
            ),
          );
        }
      }
      setState(() {
        isloading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _imageurlfucosNode.removeListener(_updateimageurl);
    _pricefucosNode.dispose();
    _imageurlfucosNode.dispose();
    _imageurlcontroller.dispose();
    _descriptionfucosNode.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isinit) {
      final producteid = ModalRoute.of(context)!.settings.arguments as String?;
      if (producteid != null) {
        _editedproducte =
            Provider.of<Products>(context, listen: false).findbyid(producteid);
        _intialvalues = {
          'title': _editedproducte.title,
          'description': _editedproducte.description,
          'price': _editedproducte.price,
          'imageurl': '',
        };
        _imageurlcontroller.text = _editedproducte.imageurl!;
      }
      _isinit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
              onPressed: () {
                _saveform();
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: isloading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                  key: _formkey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _intialvalues['title'],
                        decoration: InputDecoration(
                          label: Text('Title'),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_pricefucosNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'please provide a value';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedproducte = Product(
                              id: _editedproducte.id,
                              title: value!,
                              description: _editedproducte.description,
                              price: _editedproducte.price,
                              imageurl: _editedproducte.imageurl,
                              isfavorite: _editedproducte.isfavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _intialvalues['price'].toString(),
                        decoration: InputDecoration(
                          label: Text('price'),
                        ),
                        textInputAction: TextInputAction.next,
                        focusNode: _pricefucosNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionfucosNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'please enter a  price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'please enter a vaild number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'please enter a  number greater than zero';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedproducte = Product(
                              id: _editedproducte.id,
                              title: _editedproducte.title,
                              description: _editedproducte.description,
                              price: double.parse(value!),
                              imageurl: _editedproducte.imageurl,
                              isfavorite: _editedproducte.isfavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _intialvalues['description'].toString(),
                        decoration: InputDecoration(
                          label: Text('description'),
                        ),
                        maxLines: 3,
                        focusNode: _descriptionfucosNode,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'please enter a  description';
                          }
                          if (value.length < 10) {
                            return 'should be at lest 10 character lenght';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedproducte = Product(
                              id: _editedproducte.id,
                              price: _editedproducte.price,
                              title: _editedproducte.title,
                              description: value!,
                              imageurl: _editedproducte.imageurl,
                              isfavorite: _editedproducte.isfavorite);
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageurlcontroller.text.isEmpty
                                ? Text('enter a url')
                                : FittedBox(
                                    child: Image.network(
                                      _imageurlcontroller.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _imageurlcontroller,
                              decoration: InputDecoration(
                                label: Text('image url'),
                              ),
                              focusNode: _imageurlfucosNode,
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'please enter a  image url';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'please enter a valid url';
                                }
                                if (!value.endsWith('png') &&
                                    !value.endsWith('jpg') &&
                                    !value.endsWith('jpeg')) {
                                  return 'please enter a valid url';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _editedproducte = Product(
                                    id: _editedproducte.id,
                                    price: _editedproducte.price,
                                    title: _editedproducte.title,
                                    description: _editedproducte.description,
                                    imageurl: value!,
                                    isfavorite: _editedproducte.isfavorite);
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
