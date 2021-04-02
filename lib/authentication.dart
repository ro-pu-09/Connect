
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oopproject/User.dart';
import 'package:oopproject/authenticationbloc.dart';
import 'dashboad.dart';


AuthenticationBlock authblock=new AuthenticationBlock();

TextEditingController username=new TextEditingController();

TextEditingController password=new TextEditingController();

TextEditingController repassword=new TextEditingController();

rePasswordCheck RPC=new rePasswordCheck();

final _formKey = GlobalKey<FormState>();


class loginpage extends StatefulWidget{

  @override
  _loginpageState createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {

   initState(){
      repassword.addListener(() {
        // print(repassword.text);
        return RPC.addToStreamRePassword(repassword.text);
      });


      password.addListener(() {
       //print("-----");
       // print(password.text);
        return RPC.addToStreamPassword(password.text);
      });
   }

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
           // key:_formKey,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Enter your password'),
            controller: password,

          ),
          TextFormField(
         //   key: _formKey,
          obscureText: true,
          decoration: InputDecoration(labelText: 'Re-enter your password'),
          controller: repassword,

          ),

          SignUpButton(),

        ],

      ),

    );
  }
}


class SignUpButton extends StatefulWidget {
  @override
  _SignUpButtonState createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<SignUpButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:RPC.repasswordcheck,
        initialData: false,
        builder: (buildContext,snapshot){
          return Column(
              children:[
                RaisedButton(
                   onPressed:!snapshot.data?null: ()
                  {

                    print(snapshot.data);
                    if(snapshot.data){
                      authblock.SignUpWithEmail(username.text, password.text).then((userd){
                        print("!!!!!!!!!!!!!!!!!!");
                        print(userd);
                        if(userd==1){
                          print("user not found");
                          dialog(buildContext,'The username is not registered with us','username not registered with us. Please sign up');
                        }
                        else if(userd==0){
                          dialog(buildContext,'Weak Password','Please enter a strong password');
                        }
                        else if(userd==2){
                          dialog(buildContext, 'Wrong Password', 'The password entered is wrong.Please try again ');
                        }
                        else if(userd==3){
                          dialog(buildContext, 'did not find the email', 'Please Enter correct Email');
                        }
                        else if(!userd.emailVerified){
                          dialog(buildContext,'verify your email','An Email has been sent to your registered mail. Please click on the link provided in the mail to verify');
                        }

                        else {
                          Navigator.of(buildContext).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                                return dashBoard();
                              })
                          );
                        }

                      });
                    }

                    else{
                      print("hellow");
                      return null;
                    }
                  },
                  child: Text("Signup"),
                  disabledColor: Colors.grey,

                )]);
        });
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

class rePasswordCheck
{


  final _rePasswordCheck = StreamController<String>.broadcast();


  Sink<String> get inputrepassword=>_rePasswordCheck.sink;

  //ink<String> get inputpassword=>_rePasswordCheck.sink;
  String inputpassword;
  addToStreamPassword(String text){
     inputpassword=text;
  }
  addToStreamRePassword(String text){
    inputrepassword.add(text);
  }

  Stream<bool> get repasswordcheck => _rePasswordCheck.stream.map((event) {


  return event==inputpassword;
  });

  void dispose()=> _rePasswordCheck.close();
}