import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:chat_app/groupchat.dart';


class Newgroupdialog extends StatefulWidget {
  var users;
  String userId;
  Newgroupdialog(this.userId,this.users);

  @override
  _Newgroupdialog createState() => _Newgroupdialog(userId,users);
}
String title='';

class _Newgroupdialog extends State<Newgroupdialog> {
  String userId;
  var users;
  var selectedUsers;
  _Newgroupdialog(this.userId,this.users);

  createAlertDialog(BuildContext context) async {
    var selected;
    await showDialog(
      context: context,
      builder: (ctx) {
        return  MultiSelectDialog(
          items: users.map<MultiSelectItem<Object?>>((e) => MultiSelectItem(e, e.name)).toList(),
          initialValue: selected,
          onConfirm: (values) {
            selectedUsers=values;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else
              return mydialog(context,snapshot);
        }
      },
    );
  }
  @override
  Widget mydialog(BuildContext context,AsyncSnapshot snapshot) {

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, bottom: 15, top: 25),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'group title',
            ),
            onChanged: (Value) {
              setState(() {
                title = Value.toString();
              });
            },
          )
        ),
        Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
            child:TextButton(
              child: Text("add users"),
              onPressed:()=> createAlertDialog(context) ,
            )
        ),
        Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
            child:TextButton(
              child: Text("Ok"),
              onPressed:()=>{
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChat(convId: userId+title,users:selectedUsers,title:title),
                ),
              )
    },
            )
        ),
      ],
    );
  }
}






