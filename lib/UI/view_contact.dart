import 'package:chatapp/UI/detail_chat.dart';
import 'package:chatapp/function/backend.dart';
import 'package:chatapp/function/model.dart';
import 'package:flutter/material.dart';

class ViewContact extends StatefulWidget {
  ViewContact({Key key}) : super(key: key);

  @override
  _ViewContactState createState() => _ViewContactState();
}

class _ViewContactState extends State<ViewContact> {

  Future<List<UserInformation>> _users;

  @override
  void initState() { 
    super.initState();
    _users = Backend().getUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add People'),
      ),
      body: FutureBuilder(
        future: _users,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.done
            ? snapshot.hasData
              ? _userListBody(snapshot.data)
              : _offlineMsg()
            : Center(
              child: CircularProgressIndicator(),
            );
        },
      ),
    );
  }

  Widget _userListBody(List<UserInformation> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            ListTile(
              title: Text('${data[index].name}'),
              leading: Icon(Icons.person),
              trailing: RaisedButton(
                elevation: 0,
                child: Text('MESSAGE'),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailChat(
                  name: data[index].name,
                  toUid: data[index].uid,
                )))
              ),
            ),
            Divider()
          ],
        );
      }
    );
  }

  Widget _offlineMsg() {
    return Text('Oops, something went wrong');
  }
}