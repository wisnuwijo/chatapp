import 'package:chatapp/UI/home.dart';
import 'package:chatapp/function/backend.dart';
import 'package:chatapp/function/model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _registerScaffoldState = GlobalKey<ScaffoldState>();

  @override
  void dispose() { 
    _emailTextController.dispose();
    _passwordTextController.dispose();

    super.dispose();
  }

  void _register() async {
    FirebaseUser register = await Backend().register(
      name: _nameTextController.text, 
      email: _emailTextController.text, 
      password: _passwordTextController.text
    );

    if (register != null) {
      await Backend().saveUserInformation(UserInformation(
        email: register.email,
        fcmToken: '',
        name: _nameTextController.text,
        uid: register.uid
      ));

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => ChatApp(
          uid: register.uid,
        )
      ));
    } else {
      _registerScaffoldState.currentState.showSnackBar(
        SnackBar(content: Text('Oops, something went wrong'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _registerScaffoldState,
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Form(
        key: _registerFormKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Name'
                ),
                controller: _nameTextController,
                validator: (val) {
                  if (val == '' || val == null) {
                    return 'Harus diisi';
                  }

                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email'
                ),
                controller: _emailTextController,
                validator: (val) {
                  if (val == '' || val == null) {
                    return 'Harus diisi';
                  }

                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password'
                ),
                controller: _passwordTextController,
                validator: (val) {
                  if (val == '' || val == null) {
                    return 'Harus diisi';
                  }

                  return null;
                },
              ),
              RaisedButton(
                child: Text('Daftar'),
                onPressed: () {
                  if (_registerFormKey.currentState.validate()) {
                    _register();
                  }
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}