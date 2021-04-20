import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({Key key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  TextEditingController _emailTextController = TextEditingController();

  GlobalKey<FormState> _forgetPasswordKey = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() { 
    _emailTextController.dispose();
    
    super.dispose();
  }

  void _sendPasswordResetEmail() async {
    await _auth.sendPasswordResetEmail(email: _emailTextController.text);
    print('email sent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forget Password'),
      ),
      body: Form(
        key: _forgetPasswordKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailTextController,
              validator: (val) {
                if (val == '' || val == null) {
                  return 'Harus diisi';
                }

                return null;
              },
            ),
            RaisedButton(
              child: Text('Kirim'),
              onPressed: () {
                if (_forgetPasswordKey.currentState.validate()) {
                  _sendPasswordResetEmail();
                }
              }
            )
          ],
        ),
      ),
    );
  }
}