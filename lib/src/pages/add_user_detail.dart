import 'dart:io';
import 'package:shappy/src/models/store_category.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shappy/src/elements/BlockButtonWidget.dart';
import 'package:dropdown_search/dropdown_search.dart';
class StoreDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StoreDetailState();
  }
}

class StoreDetailState extends StateMVC<StoreDetail> {
  UserController _con;
  StoreCategory categoryModel;
  File _image;

  StoreDetailState() : super(UserController()) {
    _con = controller;
  }

  void _setCate(StoreCategory model) {
    setState(() {
      categoryModel = model;
    });
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _setCate(StoreCategory(name: "Grocery", id: "999"));
    //getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: ListView(
          reverse: true,padding: EdgeInsets.all(4), children: <Widget>[
//sign up to get started and experience great shopping deals
        SizedBox(height: 50),
        Container(
          margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Text(
            "Store Details",
            style: Theme.of(context)
                .textTheme
                .headline2
                .merge(TextStyle(color: Theme.of(context).accentColor)),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: _con.loginFormKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                DropdownSearch<StoreCategory>(
                  mode: Mode.MENU,
                  items: [
                    StoreCategory(name: "Grocery", id: "999"),
                    StoreCategory(name: "Cloth & Dress", id: "0101")
                  ],
                  searchBoxDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
                    labelText: "Search a category",
                  ),
                  label: "Select your store category",
                  onFind: (String filter) {},
                  hint: "Select StoreCategory",
                  onChanged: (StoreCategory data) {
                    _setCate(data);
                  },
                  showSearchBox: true,
                  selectedItem: categoryModel,
                ),
                SizedBox(height: 30),
                TextFormField(
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  //verification
                  // A 5-Digit PIN has been sent to your mobile no.Enter it below to continue
                  validator: (input) => input.length < 3
                      ? "Enter the store name, minimum 3 character"
                      : null,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                  decoration: InputDecoration(
                    labelText: "Store Name",
                    labelStyle: TextStyle(color: Theme.of(context).accentColor),
                    contentPadding: EdgeInsets.all(12),
                    //prefixIcon: Icon(Icons.phone, color: Theme.of(context).accentColor),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  //verification
                  // A 5-Digit PIN has been sent to your mobile no.Enter it below to continue
                  validator: (input) => input.length < 3
                      ? "Enter the name,minimum 3 character"
                      : null,
                  decoration: InputDecoration(
                    labelText: "Owner Name",
                    labelStyle: TextStyle(color: Theme.of(context).accentColor),
                    contentPadding: EdgeInsets.all(12),
                    //prefixIcon: Icon(Icons.phone, color: Theme.of(context).accentColor),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.5))),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.2))),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  height: 30,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Upload Photo',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  height: 100,
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Color(0xFFe3e3e3),
                      child: _image != null
                          ? ClipRect(
                              child: Image.file(
                                _image,
                                width: 150,
                                height: 100,
                                fit: BoxFit.fitHeight,
                              ),
                            )
                          : Icon(Icons.add, size: 40, color: Colors.white),
                    ),
                    onTap: () {
                      print("Click event on Container");
                      _showPicker(context);
                    },
                  ),
                ),
                SizedBox(height: 30),
                BlockButtonWidget(
                  text: Text(
                    "Continue",
                    //#e3e3e3
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    // _con.storeDetail();
                  },
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ].reversed.toList()),
    );
  }
}
