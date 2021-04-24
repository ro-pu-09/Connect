import 'package:flutter/material.dart';
import 'package:oopproject/APIdistance.dart';
import 'package:oopproject/authentication.dart';
import 'package:oopproject/authenticationbloc.dart';
import 'package:oopproject/dashboardconsumer.dart';
import 'package:oopproject/dashboardretailer.dart';
import 'package:oopproject/dashboardwholesaler.dart';

import 'User.dart';




class dashBoard extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
    future: getUser(),
    builder: (context,snapshot){
      if(snapshot.connectionState==ConnectionState.done){

        UserDetails userd=snapshot.data;
        //distanceAPI.getListOfretailers();
        if(userd.type=='retailer') return dashboardretailer();
        else if (userd.type=='consumer')return dashboardconsumer();
        else if(userd.type=='wholesaler') return dashboardwholesaler();
        else return loginpage();

      }

      else return Scaffold(body:Center(child: CircularProgressIndicator(),));
    });


  }
}