import 'package:chatapp/UI/home.dart';
import 'package:chatapp/UI/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    _init();

    super.initState();
  }

  void _init() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String uid = _prefs.getString('uid');
    bool _getLoginStatus = _prefs.getBool('login');

    if (_getLoginStatus != null && _getLoginStatus) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatApp(
        uid: uid
      )));
    } else {
      _prefs.clear();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Row(
            children: [
              Center(
                child: Text('Dygdaya Chat')
              ),
            ],
          ),
        ],
      ),
    );
  }
}