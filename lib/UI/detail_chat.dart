import 'package:chatapp/function/backend.dart';
import 'package:chatapp/function/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailChat extends StatefulWidget {
  DetailChat({
    Key key,
    @required this.name,
    @required this.toUid
  }) : super(key: key);

  final String name;
  final String toUid;

  @override
  _DetailChatState createState() => _DetailChatState();
}

class _DetailChatState extends State<DetailChat> {

  var query = Firestore.instance;
  Future<String> _uid;

  TextEditingController _msgPad = TextEditingController();
  
  Future<String> _getUId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');
    return uid;
  }

  @override
  void initState() {
    _uid = _getUId();
    super.initState();
  }

  Widget _chatStream(String uid) {
    return StreamBuilder(
      stream: Backend().getMessage(widget.toUid),
      builder: (context, snapshot) {
        return _chatList(uid, snapshot.data);
      },
    );
  }

  Widget _chatList(String uid, QuerySnapshot chats) {
    if (chats == null || chats.documents.length <= 0) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chats.documents.map(
          (e) => Row(
            mainAxisAlignment: uid == e.data['from_uid']
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: uid == e.data['from_uid']
                    ? BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                    ) : BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topRight: Radius.circular(15),
                    )
                  ),
                  child: Text('${e.data['msg']}', style: TextStyle(
                    color: Colors.white
                  )),
                ),
              ),
            ],
          )
        ).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    color: Theme.of(context).accentColor,
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: ListTile(
                      onLongPress: () {},
                      leading: Image.asset('asset/asset-2.png', width: 35),
                      title: Text('${widget.name}', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      )),
                      subtitle: _lastSeen()
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right:20.0),
                    child: IconButton(
                      color: Theme.of(context).accentColor,
                      icon: Icon(Icons.phone),
                      onPressed: () {}
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                child: FutureBuilder(
                  future: _uid,
                  builder: (context, snapshot) {
                    return snapshot.hasData
                      ? _chatStream(snapshot.data)
                      : Container();
                  },
                ),
              )
            ],
          ),
        )
      ),
      bottomSheet: Container(
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _msgPad,
                style: TextStyle(
                  color: Colors.white,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 30),
                  hintText: 'Type a message',
                  hintStyle: TextStyle(
                    color: Color.fromRGBO(143, 144, 150,1)
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(84, 87, 92,1),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(84, 87, 92,1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                      color: Color.fromRGBO(84, 87, 92,1)
                    ),
                  ),
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
                minWidth: 60,
                height: 60,
                color: Theme.of(context).accentColor,
                onPressed: () async {
                  if (_msgPad.text != '') {
                    _saveMsg(_msgPad.text);
                  }
                }, 
                child: Icon(Icons.send, color: Colors.white), 
              ),
            )
          ],
        ),
      )
    );
  }

  Widget _lastSeen() {
    return FutureBuilder(
      future: Backend().getLastActive(widget.toUid),
      builder: (context, snapshot) {
        return snapshot.hasData
          ? Text('Last seen at ${Helper().dateHelper(snapshot.data.toString())}', style: TextStyle(
                color: Colors.white
              )
            )
          : Container();
      }
    );
  }

  _saveMsg(String msg) async {
    await Backend().sendMessage(
      msg: _msgPad.text,
      toUid: widget.toUid
    );

    _msgPad.clear();
  }
}