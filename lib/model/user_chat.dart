import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;
  List<String> conversations;

  UserChat({required this.id, required this.photoUrl, required this.nickname, required this.aboutMe,required this.conversations});

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    List<String> conversations=[];

    try {
      aboutMe = doc.get('aboutMe');
    } catch (e) {}
    try {
      photoUrl = doc.get('photoUrl');
    } catch (e) {}
    try {
      nickname = doc.get('nickname');
    } catch (e) {}
    try {
      conversations = doc.get('conversations');
      print("//");
      print(conversations);
    } catch (e) {}

    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
      conversations:conversations,
    );
  }
}
