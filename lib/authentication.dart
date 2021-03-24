
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'dashboad.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;


Future<dynamic> SignUpWithEmail(String username, String password) async{
  await Firebase.initializeApp();
  User user;
  try {
    UserCredential userCredential=await _auth.createUserWithEmailAndPassword(
        email: username,
        password: password
     );
    user= userCredential.user;
    if(!user.emailVerified){
      await user.sendEmailVerification();
    }

    return user;
  }
  on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      return 0;
    } else if (e.code == 'email-already-in-use') {
      return await SignInWithEmail(username, password);
    }
  } catch (e) {
     return e;
  }
}


Future<dynamic> SignInWithEmail(String username,String password)async{
   await Firebase.initializeApp();
   User user;
   try{
     UserCredential userCredential= await _auth.signInWithEmailAndPassword(email: username, password: password);
     user=userCredential.user;
     return user;
   }
   on FirebaseAuthException catch(e){
     if(e.code=='user-not-found')
       return 1;
     else if(e.code=='wrong-password'){
       return 2;
     }
   }
   catch(e){
     print(e);
   }
}

class loginpage extends StatelessWidget{



  initState(){

  }
  TextEditingController username=new TextEditingController();
  TextEditingController password=new TextEditingController();
  Widget build (BuildContext buildContext){

    return Scaffold(

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: [

          TextFormField(
            decoration: InputDecoration(labelText: 'Enter your username'),
            controller: username,
          ),

          TextFormField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Enter your password'),
            controller: password,
          ),
          RaisedButton(onPressed: (){
            SignUpWithEmail(username.text, password.text).then((user){

              if(user==1){
                print("user not found");
                dialog(buildContext,'The username is not registered with us','username not registered with us. Please sign up');
              }
              else if(user==0){
                dialog(buildContext,'Weak Password','Please enter a strong password');
              }
              else if(user==2){
                dialog(buildContext, 'Wrong Password', 'The password entered is wrong.Please try again ');
              }
              else if(!user.emailVerified){
                dialog(buildContext,'verify your email','An Email has been sent to your registered mail. Please click on the link provided in the mail to verify');

              }
              else {
                Navigator.of(buildContext).push(
                    MaterialPageRoute(builder: (context) {
                      return dashBoard();
                    }));
              }

              });

          },child: Text("Signup"),)
        ],

      ),

    );
  }
}

dialog(BuildContext context, String title, String content)async {
  await showDialog(context: context,
    builder: (BuildContext context){
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
          FlatButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text("Ok")),
      ],
    );
    }
  );
}