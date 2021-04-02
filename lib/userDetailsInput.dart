
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:oopproject/dashboad.dart';
import 'package:oopproject/authenticationbloc.dart';
enum type { consumer, retailer, wholesaler}

class locationData {
  Location location=new Location();

  Future<dynamic> getCoordinates()async {
     LocationData currentloction;
     try {
       currentloction = await location.getLocation();
       print(currentloction);
     }
     on PlatformException catch (e) {
       if (e.code == 'PERMISSION_DENIED') {
         print("Grant Permission");
       }
       if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {

         print("Grant Permission in settings");
       }
       currentloction = null;
     }
     if(currentloction!=null) {
       final coordinates = new Coordinates(
           currentloction.latitude, currentloction.longitude);

//       dynamic address = await Geocoder.google('AIzaSyCblxZnpT7YId0xPAM_K5HJmgTBfA22YfQ').findAddressesFromCoordinates(
//           coordinates);
        return coordinates;
     }
  }
}

class userDetailsInput extends StatefulWidget {
  @override
  _userDetailsInputState createState() => _userDetailsInputState();
}

class _userDetailsInputState extends State<userDetailsInput> {
  type _character = type.consumer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: Text("Consumers"),
            leading: Radio(value: type.consumer, groupValue: _character, onChanged:(type value){
              setState(() {
                _character=value;
              });
            }),
          ),
          ListTile(
            title: Text("Retailer"),
            leading: Radio(value: type.retailer, groupValue: _character, onChanged: (type value){

              setState(() {
                _character=value;
              });
            }),
          ),
          ListTile(
            title: Text("Wholesaler"),
            leading: Radio(value: type.wholesaler, groupValue: _character, onChanged: (type value){
              setState(() {
                _character=value;
              });
            }),
          ),

          FlatButton(onPressed: ()async {
               addUserDetails("rohithputha@gmail.com", _character,context);
            }, child: Text("Finish Registeration")),

        ],
      ),
    );
  }
}

Future<void> addUserDetails(String email,type character,BuildContext context) async{
  
  await Firebase.initializeApp();
  final db=FirebaseFirestore.instance;
  locationData obj=new locationData();
  Coordinates coordinates=await obj.getCoordinates();
  dynamic snapshhot=db.collection('UserDetails').doc(email).set(
      {
        "latitude": coordinates.latitude,
        "longitude":coordinates.longitude,
        "type":character.toString().split('.').last,
      }).then((value) {

      getUser();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
      return dashBoard();
    }));
  });


}
