import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shappy/src/controller/user_controller.dart';
import 'package:shappy/src/models/route_argument.dart';
import 'package:shappy/src/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_edit_tab_page.dart';

class ProfileEditPage extends StatefulWidget {
  final RouteArgument rar;
  ProfileEditPage(this.rar);
  @override
  ProfileEditPageState createState() => ProfileEditPageState();
}

class ProfileEditPageState extends StateMVC<ProfileEditPage> {
  User user;
  UserController _con;
  final _formKey = GlobalKey<FormState>();
  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _mobilenumberFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  Future<SharedPreferences> _sharePrefs = SharedPreferences.getInstance();
  final RegExp emailRegex = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  final RegExp phoneRegex = new RegExp(r'^[6-9]\d{9}$');
  ProfileEditPageState() : super(UserController()) {
    _con = controller;
  }
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController numberController = new TextEditingController();

  @override
  void initState() {
    user = widget.rar.param;
    nameController.text = user.name != null ? user.name : "";
    emailController.text = user.email != null ? user.email : "";
    numberController.text = user.phone != null ? user.phone : "";
    super.initState();
  }

  void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Profile Edit'),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () => Navigator.of(context).pop()),
            centerTitle: true,
            elevation: 0),
        body: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    color: Color(0xffe62136),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                padding: EdgeInsets.all(10)),
            Expanded(
              child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                child: TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  controller: nameController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter name';
                                    }
                                    return null;
                                  },
                                  focusNode: _usernameFocusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Enter your Name',
                                    labelStyle: TextStyle(color: Colors.black),
                                  ),
                                  onFieldSubmitted: (_) {
                                    fieldFocusChange(
                                        context,
                                        _usernameFocusNode,
                                        _mobilenumberFocusNode);
                                  },
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(20),
                                child: TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  controller: emailController,
                                  decoration: InputDecoration(
                                      labelText: 'Enter your Email',
                                      labelStyle:
                                          TextStyle(color: Colors.black)),
                                  validator: (value) {
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Please enter valid email';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  focusNode: _emailFocusNode,
                                ),
                              ),
                            ],
                          )),
                      Container(
                        child: RaisedButton(
                            textColor: Colors.white,
                            color: Color(0xffe62136),
                            child: Text('Save'),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                final SharedPreferences sharedPrefs =
                                    await _sharePrefs;
                                Map<String, dynamic> body = {
                                  "user_ID": sharedPrefs.getString("spUserID"),
                                  "username": nameController.text,
                                  "user_Email": emailController.text
                                };
                                print(sharedPrefs.getString("spUserID"));
                                print(nameController.text);
                                print(emailController.text);
                                _con.waitUntilUpdateProfile(body);
                              } else {
                                print('Error');
                              }
                            }),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 20,
                        ),
                        height: MediaQuery.of(context).size.height / 16,
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(5)),
            )
          ],
        ));
  }
}
