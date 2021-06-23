import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final String phone;

  OTPScreen(this.phone);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  late String _credId ;
  late String _verificationCode;
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  User? currentUser;
  SharedPreferences? prefs;
  bool isLoading = false;
  bool isLoggedIn = false;

  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  // @override
  // void initState() {
  //   super.initState();
  //   isSignedIn();
  // }

  // void isSignedIn() async {
  //   this.setState(() {
  //     isLoading = true;
  //   });
  //
  //   prefs = await SharedPreferences.getInstance();
  //
  //   isLoggedIn = await googleSignIn.isSignedIn();
  //   if (isLoggedIn && prefs?.getString('id') != null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               HomeScreen(currentUserId: prefs!.getString('id') ?? "")),
  //     );
  //   }
  //
  //   this.setState(() {
  //     isLoading = false;
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP verification'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Verify +212-${widget.phone}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: PinPut(
              fieldsCount: 6,
              withCursor: true,
              textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
              eachFieldWidth: 40.0,
              eachFieldHeight: 55.0,
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              submittedFieldDecoration: pinPutDecoration,
              selectedFieldDecoration: pinPutDecoration,
              followingFieldDecoration: pinPutDecoration,
              pinAnimationType: PinAnimationType.fade,
              onSubmit: (pin) async {
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                      verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen(currentUserId: value.user!.uid)),
                              (route) => false);
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();
                  _scaffoldkey.currentState!
                      .showSnackBar(SnackBar(content: Text('invalid OTP')));
                }
              },
            ),
          )
        ],
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+212${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              ////////////////////////
              final QuerySnapshot result = await FirebaseFirestore.instance
                  .collection('users')
                  .where('id', isEqualTo: value.user!.uid)
                  .get();
              final List<DocumentSnapshot> documents = result.docs;
              if (documents.length == 0) {
                // Update data to server if new user
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(value.user!.uid)
                    .set({
                  'nickname': "New User",
                  'photoUrl': "https://centrecharlesemileclaude.ca/wp-content/uploads/2019/01/avatar-grey-blue.png",
                  'id': value.user!.uid,
                  'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
                  'chattingWith': null
                });

                // Write data to local
                currentUser = value.user;
                await prefs?.setString('id', value.user!.uid);
                await prefs?.setString('nickname', "New User");
                await prefs?.setString('photoUrl', "https://centrecharlesemileclaude.ca/wp-content/uploads/2019/01/avatar-grey-blue.png");
                setState(() {});
              }
              ///////////////////////////
              setState(() {
                _credId =value.user!.uid;
              });
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(currentUserId:value.user!.uid )),
                      (route) => false);
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verficationID, int? resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        // timeout: Duration(seconds: 120)
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyPhone();
  }

}
