import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class cartret extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
        actions: [
          FlatButton( child: Text("buy",style: TextStyle(color: Colors.white),),onPressed: ()async {
            dynamic snapshot=await FirebaseFirestore.instance.collection('cartRet').doc(FirebaseAuth.instance.currentUser.email).get();
            for (int i=0;i<snapshot.data().keys.toList().length;i++){
              writetoordersretailer(snapshot.data().entries.toList()[i].value['email'],snapshot.data().keys.toList()[i],snapshot.data().entries.toList()[i].value['quant'],'placed');
              writefromordersretailer(snapshot.data().entries.toList()[i].value['email'],snapshot.data().keys.toList()[i],snapshot.data().entries.toList()[i].value['quant'],'placed');
              Deleteordercart(snapshot.data().entries.toList()[i].value['email'],snapshot.data().keys.toList()[i],snapshot.data().entries.toList()[i].value['quant']);
            }
          },),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cartRet').doc(FirebaseAuth.instance.currentUser.email).snapshots() ,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.connectionState==ConnectionState.active)return ListView.builder(itemCount: snapshot.data.data().keys.toList().length,itemBuilder: (context,index){
            return card(snapshot.data, index);
          });

          else return Center(child: CircularProgressIndicator(),);


        },
      ),

    );
  }
}

class card extends StatelessWidget {

  dynamic snapshot;
  int index;
  card(this.snapshot,this.index);


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(snapshot.data().keys.toList()[index]),
          Text(snapshot.data().entries.toList()[index].value['email']),
          Text(snapshot.data().entries.toList()[index].value['quant']),
        ],
      ),
    );
  }
}

writetoordersretailer(String retaileremail, dynamic item,dynamic quant, dynamic status)async {


  dynamic snapshot= await FirebaseFirestore.instance.collection('retordersto').doc(FirebaseAuth.instance.currentUser.email).get();

  print(retaileremail);

  int index=snapshot.data().keys.toList().indexOf(retaileremail);
  print(index);
  List<dynamic> iteml=[];
  List<dynamic> quantl=[];
  List<dynamic> statusl=[];

  if(index>=0) {
    iteml = snapshot
        .data()
        .entries
        .toList()[index].value["item"].toList();
    quantl = snapshot
        .data()
        .entries
        .toList()[index].value["quant"].toList();
    statusl = snapshot
        .data()
        .entries
        .toList()[index].value["status"].toList();

  }
  iteml.add(item);
  quantl.add(quant);
  statusl.add(status);


  print(statusl);
  print(iteml);
  print("------------");
  FirebaseFirestore.instance.collection('retordersto').doc(FirebaseAuth.instance.currentUser.email).set(
    {
      retaileremail:
      {
        "item": iteml,
        "quant": quantl,
        "status": statusl,
      },

    },

    SetOptions(merge: true),
  );

}

writefromordersretailer(String retaileremail, dynamic item,dynamic quant, dynamic status) async {

  print(retaileremail);

  dynamic snapshot= await FirebaseFirestore.instance.collection('whordersfrom').doc(retaileremail).get();
  print(snapshot.data()["item"]);
  List<dynamic> iteml=[];
  List<dynamic> quantl=[];
  List<dynamic> statusl=[];

  iteml=List.from(snapshot.data()["item"]);
  quantl=List.from(snapshot.data()["quant"]);
  statusl=List.from(snapshot.data()["status"]);
  iteml.add(item);
  quantl.add(quant);
  statusl.add(status);
  FirebaseFirestore.instance.collection('whordersfrom').doc(retaileremail).set(
    {
      "item":iteml,
      "quant":quantl,
      "status":statusl,

    },
  );

}

Deleteordercart(String retaileremail, dynamic item,dynamic quant) {
  FirebaseFirestore.instance.collection('cartRet').doc(FirebaseAuth.instance.currentUser.email).update(
      {
        item:FieldValue.delete(),
      }
  );
}
