import 'package:chatapp/UI/view_contact.dart';
import 'package:chatapp/function/backend.dart';
import 'package:chatapp/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_chat.dart';

class ChatApp extends StatefulWidget {
  final FirebaseUser user;
  final String uid;

  ChatApp({
    Key key,
    this.user,
    this.uid,
  }) : super(key: key);

  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {

  var query = Firestore.instance;

  Future<SharedPreferences> prefs;

  GlobalKey<ScaffoldState> _homeScaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    prefs = SharedPreferences.getInstance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _homeScaffold,
      backgroundColor: Theme.of(context).primaryColor,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _createNewChat(),
      ),
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Color.fromRGBO(218,66,63,1)), 
            onPressed: () {
              showModalBottomSheet(
                context: context, 
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Confirmation', style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ))),
                          IconButton(
                            icon: Icon(Icons.close), 
                            onPressed: () => Navigator.pop(context)
                          )
                        ],
                      ),
                      Divider(),
                      Text('Do you really want to log out?'),
                      Row(
                        children: [
                          FlatButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel')
                          ),
                          FlatButton(
                            onPressed: () => _logOut(),
                            child: Text('Exit')
                          )
                        ],
                      )
                    ],
                  ),
                )
              );
            }
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              child: _chatToolBar(),
            ),
            Expanded(
              child: FutureBuilder(
                future: prefs,
                builder: (context, snapshot) {
                  return snapshot.hasData
                    ? Container(
                      child: SingleChildScrollView(
                        child: StreamBuilder(
                          stream: Backend().getChat(),
                          builder: (context, snapshot) {
                            return snapshot.hasData
                              ? _chatList(snapshot.data)
                              : Center(
                                child: CircularProgressIndicator()
                              );
                          },
                        )
                      ),
                    ) : Container();
                }
              ),
            )
          ],
        ),
      ),
    );
  }

  _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SplashScreen()));
  }

  _createNewChat() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ViewContact()));
  }

  Widget _chatList(QuerySnapshot data) {
    if (data.documents.length <= 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .3,
          ),
          Text('Start chatting by click + to add contact to your phone', style: TextStyle(
            color: Colors.white
          ))
        ],
      );
    }

    List<ListTile> _chat = [];
    for (var i = 0; i < data.documents.length; i++) {
      String name = data.documents[i]['users_switch'][widget.uid];
      String toUid = data.documents[i]['users_uid'].where((element) => element != widget.uid).first;

      _chat.add(ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailChat(
            name: name,
            toUid: toUid,
          )));
        },
        contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Image.asset('asset/asset-2.png'),
        title: Text('$name',style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold
        )),
        subtitle: Text('${data.documents[i].data['last_chat']}',style: TextStyle(
          color: Colors.white30
        )),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text('${data.documents[i].data['last_chat_timestamp']}', style: TextStyle(
            //   color: Color.fromRGBO(218,66,63,1))
            // ),
            // Container(
            //   width: 35,
            //   height: 20,
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 2.0),
            //     child: Text('5', style: TextStyle(
            //       color: Colors.white),
            //       textAlign: TextAlign.center,
            //     ),
            //   ),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(10),
            //     color: Color.fromRGBO(218,66,63,1),
            //   ),
            // )
          ],
        ),
      ));
    }

    return Column(
      children: _chat,
    );
  }

  Widget _chatToolBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(30.0),
                ),
                borderSide: BorderSide(
                  color: Color.fromRGBO(39,43,51,1),
                )
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  const Radius.circular(30.0),
                ),
                borderSide: BorderSide(
                  color: Color.fromRGBO(39,43,51,1),
                )
              ),
              filled: true,
              hintStyle: TextStyle(color: Colors.white),
              fillColor: Color.fromRGBO(38,42,50,1),
              hintText: "Search",
              contentPadding: EdgeInsets.only(
                left: 35.0,
                top: 10,
                bottom: 10
              )
            ),
          )
        ],
      ),
    );
  }
}
