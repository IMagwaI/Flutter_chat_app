import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/chat.dart';
import 'package:chat_app/DarkMode/ThemeData.dart';
import 'package:chat_app/model/user_chat.dart';
import 'package:chat_app/settings.dart';
import 'package:chat_app/widget/loading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';


import 'contact.dart';
import 'groupchat.dart';
import 'main.dart';
import 'DarkMode/DarkThemeProvider.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key? key, required this.currentUserId});

  final String currentUserId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController listScrollController = ScrollController();
  //final themeProvider = Provider.of<DarkThemeProvider>(context);
  SharedPreferences? prefs;

  int _limit = 20;
  int _limitIncrement = 20;
  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
    const Choice(title: 'Appearance', icon: Icons.light_mode)
  ];

  @override
  void initState() {
    super.initState();
    print(" hada uid diali" + currentUserId);
    registerNotification();
    configLocalNotification();
    listScrollController.addListener(scrollListener);
    // prefs!.setString("id", currentUserId);

  }

  void registerNotification() {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      if (message.notification != null) {
        showNotification(message.notification!);
      }
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.dfa.flutterchatdemo'
          : 'com.duytq.flutterchatdemo',
      'INPT Spicy Chat',
      'Express yourselves freely ',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    print(remoteNotification);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Styles.themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: Styles.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(color: Styles.primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: Styles.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(color: Styles.primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
    }
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    await prefs?.clear();

    // await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DarkThemeProvider>(context);
    void onItemMenuPress(Choice choice) {
      /*if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatSettings(ownid: currentUserId,)));
    }*/
      switch(choice.title) {
        case 'Log out': {
          handleSignOut();
        }
        break;

        case 'Settings': {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatSettings(ownid: currentUserId,)));;
        }
        break;
        case 'Appearance': {
          Alert(
            context: context,
            type: AlertType.none,
            title: "Appearance",
            desc: "",
            buttons: [
              DialogButton(
                  child: Text(
                    "Dark",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () => { themeProvider.darkTheme = true,
                    Navigator.pop(context),},
                  width: 60,
                  color: Colors.black
              ),
              DialogButton(
                child: Text(
                  "Light",
                  style: TextStyle(color: Colors.black87, fontSize: 20),
                ),
                onPressed: () => {themeProvider.darkTheme = false,
                  Navigator.pop(context),},
                width: 60,
                color: Colors.yellowAccent,
              )
            ],
          ).show();
        }
        break;
        default: {
          //statements;
        }
        break;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MAIN',
          style: TextStyle(color: Styles.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: Theme.of(context).backgroundColor,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: Styles.primaryColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('id', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //UserChat userChat = UserChat.fromDocument(snapshot.data!.docs[1]);
                    var cnv = snapshot.data!.docs[0].get('conversations');

                    if(cnv.isNotEmpty){
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(context, cnv[index]),
                      itemCount: cnv.length,
                      controller: listScrollController,
                    );
                    }else{
                      return Image.asset("images/noconvfound.png");
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Styles.primaryColor),
                      ),
                    );
                  }
                },
              ),
            ),
            // Loading
            Positioned(
              child: isLoading ? const Loading() : Container(),
            )
          ],
        ),
        onWillPop: onBackPress,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ContactScreen(currentUserId: currentUserId)
              )
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildItem(BuildContext context, String conversation) {
    return Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('conversation')
                .where('id', isEqualTo: conversation)
                .snapshots(),
            builder: (context, snapshot) {
              var user = '';
              List<dynamic> users;
              var boolGroup=0;
              var groupName="";
              try {
                users = snapshot.data!.docs[0].get('users');
                boolGroup = snapshot.data!.docs[0].get('group');

                for (int k = 0; k < users.length; k++) {
                  if (users[k] != currentUserId) user = users[k];
                }
              } catch (e) {
                print(e);
              }

              if(boolGroup==1){
                groupName = snapshot.data!.docs[0].get('title');
                return Container(
                  child: TextButton(
                    child: Row(
                      children: <Widget>[
                        Material(
                          child: Image.asset("images/group.png",
                            width: 50.0,
                            height: 50.0,
                          ),
                          borderRadius:
                          BorderRadius.all(Radius.circular(25.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        Flexible(
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    groupName,
                                    maxLines: 1,
                                    style:
                                    TextStyle(color: Styles.primaryColor),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.fromLTRB(
                                      10.0, 0.0, 0.0, 5.0),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(left: 20.0),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChat(convId: snapshot.data!.docs[0].get('id').toString(),users:snapshot.data!.docs[0].get('users'),title:groupName),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Styles.greyColor2),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),

                  ),
                  margin: EdgeInsets.only(
                      bottom: 10.0, left: 5.0, right: 5.0),
                );
              }else{
                return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where("id", isEqualTo: user)
                    .snapshots(),
                builder: (context, snapshot) {
                  try {
                    UserChat userChat =
                        UserChat.fromDocument(snapshot.data!.docs[0]);
                    if (userChat.nickname != "") {
                      if (userChat.id == currentUserId) {
                        return SizedBox.shrink();
                      } else {
                        return Container(
                          child: TextButton(
                            child: Row(
                              children: <Widget>[
                                Material(
                                  child: userChat.photoUrl.isNotEmpty
                                      ? Image.network(
                                          userChat.photoUrl,
                                          fit: BoxFit.cover,
                                          width: 50.0,
                                          height: 50.0,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Styles.primaryColor,
                                                  value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null &&
                                                          loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, object, stackTrace) {
                                            return Icon(
                                              Icons.account_circle,
                                              size: 50.0,
                                              color: Styles.greyColor,
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.account_circle,
                                          size: 50.0,
                                          color: Styles.greyColor,
                                        ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                Flexible(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            '${userChat.nickname}',
                                            maxLines: 1,
                                            style:
                                                TextStyle(color: Styles.primaryColor),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.fromLTRB(
                                              10.0, 0.0, 0.0, 5.0),
                                        ),
                                      ],
                                    ),
                                    margin: EdgeInsets.only(left: 20.0),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Chat(
                                    ownid: currentUserId,
                                    peerId: userChat.id,
                                    peerAvatar: userChat.photoUrl,
                                  ),
                                ),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Styles.greyColor2),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            ),
                          ),
                          margin: EdgeInsets.only(
                              bottom: 10.0, left: 5.0, right: 5.0),
                        );
                      }
                    } else {
                      return SizedBox.shrink();
                    }
                  } catch (e) {
                    print(e);
                    return SizedBox.shrink();
                  }
                },
              );
              }
            }));
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
