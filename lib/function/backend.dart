import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model.dart';

class Backend {
  FirebaseAuth auth = FirebaseAuth.instance;
  Firestore query = Firestore.instance;

  Future updateLastActive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');

    QuerySnapshot getUser = await query.collection('users')
      .where('uid', isEqualTo: uid)
      .getDocuments();

    for (var i = 0; i < getUser.documents.length; i++) {
      await query.collection('users')
        .document(getUser.documents[i].documentID)
        .updateData({
          'last_active': DateTime.now().toString()
        });
    }
  }

  Future<DateTime> getLastActive(String uid) async {
    DateTime datetime;

    QuerySnapshot getUser = await query.collection('users')
      .where('uid', isEqualTo: uid)
      .getDocuments();

    for (var i = 0; i < getUser.documents.length; i++) {
      if (getUser.documents[i]['last_active'] != null) {
        datetime = DateTime.parse(getUser.documents[i]['last_active']);
      }
    }

    return datetime;
  }

  Future<FirebaseUser> register({
    @required String name,
    @required String email,
    @required String password
  }) async {
    FirebaseUser userDetail;
    try {
      AuthResult doRegister = await auth.createUserWithEmailAndPassword(
                                email: email, 
                                password: password
                              ).timeout(Duration(seconds: 30));
      
      if (doRegister != null && doRegister.user != null) {
        DocumentReference addUserDetail = await query.collection('users')
                                          .add({
                                            'uid': doRegister.user.uid,
                                            'name': name,
                                            'email': doRegister.user.email,
                                            'fcm_token': '',
                                            'last_active': DateTime.now().toString()
                                          }).timeout(Duration(seconds: 30));

        if (addUserDetail != null) {
          userDetail = doRegister.user;
        }
      }
    } catch (e) {
      print('Register.register err ($e)');
    }

    return userDetail;
  }

  Future<StdResponse> login({
    @required String email,
    @required String password
  }) async {
    StdResponse result;
    FirebaseUser user;

    try {
      // update last active
      await this.updateLastActive();
      
      user = (
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password
        ).timeout(Duration(seconds: 30))
      ).user;
    } catch (e) {
      result = StdResponse(
        msg: 'Oops, something went wrong',
        msgCode: 500
      );
    }

    if (result != null) {
      return result;
    }

    if (user != null) {
      result = StdResponse(
        msg: 'Success',
        msgCode: 200
      );
    } else {
      result = StdResponse(
        msg: 'Wrong password',
        msgCode: 403
      );
    }

    return result;
  }

  Future saveUserInformation(UserInformation user) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.setBool('login', true);
    _prefs.setString('uid', user.uid);
    _prefs.setString('name', user.name);
    _prefs.setString('email', user.email);
  }

  Future<List<UserInformation>> getUserList() async {
    List<UserInformation> users;
    try {
      // update last active
      await this.updateLastActive();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = prefs.getString('uid');

      QuerySnapshot getUser = await query
        .collection('users')
        .getDocuments()
        .timeout(Duration(seconds: 30));

      if (getUser != null) {
        users = [];
        for (var i = 0; i < getUser.documents.length; i++) {
          if (getUser.documents[i]['uid'] != uid) {
            users.add(UserInformation(
              email: getUser.documents[i]['email'],
              fcmToken: getUser.documents[i]['fcm_token'],
              name: getUser.documents[i]['name'],
              uid: getUser.documents[i]['uid']
            ));
          }
        }
      }
    } catch (e) {
      print('backend.getUserList err: $e');
    }

    return users;
  }

  Future<StdResponse> sendMessage({
    @required String toUid,
    @required String msg
  }) async {
    // update last active
    await this.updateLastActive();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');
    StdResponse result;

    try {
      QuerySnapshot checkChatroom1 = await query.collection('chatroom')
                                    .where('users_uid', isEqualTo: [toUid, uid])
                                    .where('chat_type', isEqualTo: 'personal-msg')
                                    .getDocuments();

      QuerySnapshot checkChatroom2 = await query.collection('chatroom')
                                    .where('users_uid', isEqualTo: [uid, toUid])
                                    .where('chat_type', isEqualTo: 'personal-msg')
                                    .getDocuments();
      
      String chatroomId;
      if (checkChatroom1 != null && checkChatroom2 != null && checkChatroom1.documents.length <= 0 && checkChatroom2.documents.length <= 0) {
        String nameA = await this.getUserName(toUid);
        String nameB = await this.getUserName(uid);

        DocumentReference createChatRoom = await query.collection('chatroom')
          .add({
            'chat_start': DateTime.now().toString(),
            'chat_type': 'personal-msg',
            'last_chat': '',
            'last_chat_timestamp': DateTime.now().toString(),
            'users_switch': {
              toUid: nameB,
              uid: nameA
            },
            'users_uid': [
              toUid, uid
            ],
          });

        chatroomId = createChatRoom.documentID;
      } else {
        if (checkChatroom1 != null && checkChatroom1.documents.length > 0) {
          chatroomId = checkChatroom1.documents[0].documentID;
        } else if (checkChatroom2 != null && checkChatroom2.documents.length > 0) {
          chatroomId = checkChatroom2.documents[0].documentID;
        }
      }

      // update last chat
      await query.collection('chatroom')
        .document(chatroomId)
        .updateData({
          'last_chat': msg,
          'last_chat_timestamp': DateTime.now().toString()
        });

      // send msg
      DocumentReference sendMsg = await query
        .collection('chatroom')
        .document(chatroomId)
        .collection('chat')
        .add({
          'from_uid': uid,
          'msg': msg,
          'timestamp': DateTime.now().toString()
        });

      if (sendMsg != null) {
        result = StdResponse(
          msg: 'Msg sent',
          msgCode: 200
        );
      }
    } catch (e) {
      print('backend.sendMessage err: $e');
    }

    return result;
  }

  Stream<QuerySnapshot> getChat() async* {
    // update last active
    await this.updateLastActive();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');
    
    if (uid == null) {
      uid = '';
    }

    Stream<QuerySnapshot> messages = query.collection('chatroom')
      .where('users_uid', arrayContainsAny: [uid])
      .where('chat_type', isEqualTo: 'personal-msg')
      .snapshots();

    yield* messages;
  }

  Stream<QuerySnapshot> getMessage(String toUid) async* {
    // update last active
    await this.updateLastActive();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString('uid');
    
    QuerySnapshot checkChatroom1 = await query.collection('chatroom')
      .where('users_uid', isEqualTo: [toUid, uid])
      .where('chat_type', isEqualTo: 'personal-msg')
      .getDocuments();

    QuerySnapshot checkChatroom2 = await query.collection('chatroom')
      .where('users_uid', isEqualTo: [uid, toUid])
      .where('chat_type', isEqualTo: 'personal-msg')
      .getDocuments();
      
    String chatroomId;
    if (checkChatroom1.documents.length >= 0) {
      chatroomId = checkChatroom1.documents[0].documentID;
    } else if (checkChatroom2.documents.length >= 0) {
      chatroomId = checkChatroom2.documents[0].documentID;
    }
    
    Stream<QuerySnapshot> msg = query.collection('chatroom')
      .document(chatroomId)
      .collection('chat')
      .orderBy('timestamp')
      .snapshots();

    yield* msg;
  }

  Future<String> getUserName(String uid) async {
    // update last active
    await this.updateLastActive();
    
    var getUser = await query.collection('users').where('uid',isEqualTo: uid).getDocuments();
    
    String name;
    if (getUser.documents.length > 0) {
      name = getUser.documents[0]['name'];
    }

    return name;
  }
}