import 'package:chatapp/splash.dart';
import 'package:flutter/material.dart';

/// written using digdayateknologi@gmail.com account
/// within Dygdaya Chat project
/// make sure the project still exist

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dygdaya Chat',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Color.fromRGBO(55,58,66,1),
          elevation: 0.0,
        ),
        primarySwatch: Colors.blue,
        primaryColor: Color.fromRGBO(55,58,66,1),
        accentColor: Color.fromRGBO(218,66,63,1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}