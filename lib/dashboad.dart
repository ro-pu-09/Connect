import 'package:flutter/material.dart';
import 'package:oopproject/authentication.dart';
import 'package:oopproject/authenticationbloc.dart';
import 'package:oopproject/dashboardretailer.dart';

import 'User.dart';




class dashBoard extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
    future: getUser(),
    builder: (context,snapshot){
      if(snapshot.connectionState==ConnectionState.done){
        UserDetails userd=snapshot.data;
        if(userd.type=='retailer') return dashboardretailer();
        else return loginpage();
      }

      else return Scaffold(body:Center(child: CircularProgressIndicator(),));
    });


  }
}