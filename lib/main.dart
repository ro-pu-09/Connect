import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oopproject/User.dart';
import 'package:oopproject/authentication.dart';
import 'package:oopproject/dashboad.dart';
import 'package:oopproject/userDetailsInput.dart';
import 'package:oopproject/authenticationbloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


final streamKey=GlobalKey();
void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  MyApp({Key key}):super(key:key);
  @override
  Widget build(BuildContext context) {

  
  return new MaterialApp(
    home: FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context,snapshot){
        if(snapshot.hasError)return Scaffold(body: Center(child: Text("Something went wrong"),),);

        if (snapshot.connectionState == ConnectionState.done) {
          return Landing();
        }

        return Scaffold(body: Center(child: CircularProgressIndicator(),),);
      },
    ),
  );

  }
}


//class Routing extends StatelessWidget {
//  FirebaseAuth auth=FirebaseAuth.instance;
//
//  Widget build(BuildContext context) {
//
//    @override
//     return StreamBuilder<User>(
//         stream: auth.authStateChanges(),
//         builder: (context,snapshot)
//         {
//          if(snapshot.connectionState==ConnectionState.active){
//              User user = snapshot.data;
//              if(user==null)return loginpage();
//
//              return dashBoard();
//          }
//          else{
//         return Scaffold(
//             body: Center(
//                child: CircularProgressIndicator(),
//             ),
//            );
//          }
//         }
//    );
//
//  }
//}
class AuthService extends ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create a getter stream
  Stream<User> get onAuthStateChanged => _auth.authStateChanges();

//Sign in async functions here ..

}


//class Landing extends StatelessWidget {
//
//  //FirebaseAuth auth=FirebaseAuth.instance;
//  @override
//  Widget build(BuildContext context) {
//
//    AuthService auth = Provider.of<AuthService>(context);
//    return StreamBuilder(
//      key: streamKey,
//      stream: auth.onAuthStateChanged,
//      builder: (context, snapshot) {
//        if (snapshot.connectionState == ConnectionState.active ) {
//          FocusScope.of(context).unfocus();
//          User user = snapshot.data;
//          if (user == null) {
//
//            return loginpage();
//          }
//          else return dashBoard();
//        }
//        else {
//          return Scaffold(
//            body: Center(
//              child: CircularProgressIndicator(),
//            ),
//          );
//        }
//      },
//
//    );
//  }
//}




class Landing extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser(),
       // initialData: Scaffold(body: Center(child: CircularProgressIndicator(),),),
        builder: (context,snapshot ) {

          if (snapshot.connectionState == ConnectionState.done) {

            if (snapshot.data == null) {
              return loginpage();
            }
            else if (snapshot.data!=null && snapshot.data.type == null) {
              return userDetailsInput();
            }
            else
              return dashBoard();
          }

          else {
            return Scaffold(body: Center(child: CircularProgressIndicator(),),);
          }
        }
        );
  }
}

//Future<dynamic> decideRoute() async{
//
//  UserDetails userd=await  getUser();
//  if(userd==null){
//    return loginpage();
//  }
//  else if(userd.type==null){
//    return userDetailsInput();
//  }
//  else{
//    return dashBoard();
//  }
//