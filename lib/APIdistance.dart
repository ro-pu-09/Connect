


import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oopproject/authenticationbloc.dart';
//import 'package:great_circle_distance/great_circle_distance.dart';
import 'User.dart';

class distanceAPI
{


  static List<List<String>> finallist=[];
  static double latcons;
  static double longcons;


  static Future<dynamic> getListOfretailers(int q, int d,type,prodname,String categ) async{
       UserDetails userDconsumer=await getUser();
        latcons=userD.latitude;
        longcons=userD.longitude;
        finallist.clear();

         dynamic snapshots=await FirebaseFirestore.instance.collection('UserDetails').where('type',isEqualTo: 'retailer').get();


        dynamic temp=await retailerList(snapshots,q,d,type,prodname,categ);
        return temp;

  }

  static Future<dynamic> retailerList(QuerySnapshot snapshots,int q,int d,String type, String prodname, String categ) async{

      finallist.clear();
      for(dynamic element in snapshots.docs){
      dynamic snapshots2=await FirebaseFirestore.instance.collection(type).doc(element.id).get();


      int index=snapshots2.data().keys.toList().indexOf(categ);
//      print(type);
//      print(element.id);
//
//      print(index);


      int indexofprod=snapshots2.data().entries.toList()[index].value.keys.toList().indexOf(prodname);
      print(indexofprod);
      List<String> retailerdet=[];
      int dist= await findDistance(element.id, latcons, longcons);

      print(dist);
      print(d);
      if(indexofprod!=-1 && int.parse(snapshots2.data().entries.toList()[index].value.values.toList()[indexofprod][1])>=q && dist<=d ){
          retailerdet.add(element.id);
          retailerdet.add(snapshots2.data().entries.toList()[index].value.values.toList()[indexofprod][0]);
          retailerdet.add(dist.toString());
          finallist.add(retailerdet);
         }


      }

      finallist.sort((a,b)=>(int.parse(a[2])<=int.parse(b[2])?-1:1));

      print("____________");
      print(finallist);

      return finallist;
  }
  static Future<int> findDistance(String email,latcons, longcons) async{
     UserDetails userD =await getUserfromFireStore(email,true);
    return calculateDistance(userD.latitude, userD.longitude, latcons, longcons).toInt();

  }

  static double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

}