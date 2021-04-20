import 'package:chatapp/UI/forget_password.dart';
import 'package:chatapp/UI/home.dart';
import 'package:chatapp/UI/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;

  bool _passwordOrEmailWrong = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() { 
    _emailTextController.dispose();
    _passwordTextController.dispose();
    
    super.dispose();
  }

  void _signIn() async {
    try {
      final FirebaseUser user = (
        await _auth.signInWithEmailAndPassword(
          email: _emailTextController.text, 
          password: _passwordTextController.text
        )
      ).user;

      SharedPreferences _prefs = await SharedPreferences.getInstance();

      _prefs.setBool('login', true);
      _prefs.setString('displayName', user.displayName);
      _prefs.setString('email', user.email);
      _prefs.setString('phoneNumber', user.phoneNumber);
      _prefs.setString('photoUrl', user.photoUrl);
      _prefs.setString('providerId', user.providerId);
      _prefs.setString('uid', user.uid);
      _prefs.setBool('isAnonymous', user.isAnonymous);
      _prefs.setBool('isEmailVerified', user.isEmailVerified);
      _prefs.setString('creationTime', user.metadata.creationTime.toString());
      _prefs.setString('lastSignInTime', user.metadata.lastSignInTime.toString());

      print(user);
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => ChatApp(
            user: user,
            uid: user.uid,
          )
        ));
      } else {
        print(2);
        setState(() {
          _passwordOrEmailWrong = true;
        });
      }
    } catch (e) {
      setState(() {
        _passwordOrEmailWrong = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailTextController,
              onChanged: (val) {
                _passwordOrEmailWrong = false;
              },
              validator: (val) {
                if (val == '' || val == null) {
                  return 'Harus diisi';
                } else if (_passwordOrEmailWrong) {
                  return 'Email atau password salah';
                }

                return null;
              },
            ),
            TextFormField(
              controller: _passwordTextController,
              onChanged: (val) {
                _passwordOrEmailWrong = false;
              },
              validator: (val) {
                if (val == '' || val == null) {
                  return 'Harus diisi';
                } else if (_passwordOrEmailWrong) {
                  return 'Email atau password salah';
                }

                return null;
              },
            ),
            Row(
              children: [
                RaisedButton(
                  child: Text('Login'),
                  onPressed: () {
                    if (_loginFormKey.currentState.validate()) {
                      _signIn();
                    }
                  }
                ),
                RaisedButton(
                  child: Text('Daftar'),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Register()))
                ),
                RaisedButton(
                  child: Text('Lupa Password'),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword()))
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}