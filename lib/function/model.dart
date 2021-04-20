class StdResponse {
  final String msg;
  final int msgCode;

  StdResponse({
    this.msg,
    this.msgCode
  });
}

class UserInformation {
  final String uid;
  final String name;
  final String email;
  final String fcmToken;

  UserInformation({
    this.uid,
    this.name,
    this.email,
    this.fcmToken
  });
}