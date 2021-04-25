
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'authentication.dart';



final ctStream=new categoryStream();
List<String> productname=[];
List<String> productquant=[];
List<String> productprice=[];
String presentcateg;
TextEditingController contr=new TextEditingController();
class dashboardwholesaler extends StatefulWidget {
  @override
  _dashboardwholesalerState createState() => _dashboardwholesalerState();
}



class _dashboardwholesalerState extends State<dashboardwholesaler> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: sidedrawer(),
        appBar: AppBar(
          title: Text("Wholesaler shop"),
          actions: [
            IconButton(icon: Icon(Icons.add), onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>addprods()));
            })
          ],
        ),
        body: StreamBuilder(
          initialData: 'vegetables',
          stream: ctStream.outputcateg,
          builder: (context,snapshot){



            final db=FirebaseFirestore.instance;
            presentcateg=snapshot.data;
            return intputStream();
          },
        )
    );

  }
}


class intputStream extends StatelessWidget {
  //String categ;
  //intputStream(this.categ);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('wholesaler').doc('rohithputhabits@gmail.com').snapshots(),

        builder: (context,AsyncSnapshot snapshot){

          if(snapshot.connectionState==ConnectionState.active) {

            DocumentSnapshot Dsnapshot=snapshot.data;
            int index=Dsnapshot.data().keys.toList().indexOf(presentcateg);

            productname.clear();
            productquant.clear();
            productprice.clear();



            for(int i=0;i<Dsnapshot.data().entries.toList()[index].value.entries.toList().length;i++){
              productname.add(Dsnapshot.data().entries.toList()[index].value.entries.toList()[i].key);
              productquant.add(Dsnapshot.data().entries.toList()[index].value.entries.toList()[i].value[1]);
              productprice.add(Dsnapshot.data().entries.toList()[index].value.entries.toList()[i].value[0]);
            }
            print(productname);
            print(productquant);


            return productlist();
          }
          else {
            print("########");
            return Scaffold(body: Center(child: CircularProgressIndicator(),),);
          }
        });
  }
}


class productlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(productprice);
    return ListView.builder(itemCount:productname.length,itemBuilder: (context,int index){
      return productcard(index);
    });


  }
}
//class productcard extends StatefulWidget {
//
//  int index;
//  productcard(this.index);
//
//  @override
//  _productcardState createState() => _productcardState(index);
//}

class productcard extends StatelessWidget {

  int index;
  String price;
  String quant;
  productcard(this.index)
  {
    price=productprice[index];
    quant=productquant[index];

  }


  @override
  void initState() {
    //price=productprice[index];
    //quant=productquant[index];
    //super.initState();
  }

  void makechangesprice(){

    FirebaseFirestore.instance.collection('wholesaler').doc('rohithputhabits@gmail.com').update({

      presentcateg+'.'+productname[index]:[price,quant],
      //'tomatoes':FieldValue.arrayUnion(['60','100']),

    });

  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Text(productname[index],style: TextStyle(fontSize: 24),),


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: (){
                quant=(int.parse(quant)-1).toString();
                makechangesprice();
              }, icon: Icon(Icons.remove),),
              Text("Quantity Available "+quant),
              IconButton(onPressed: (){
                quant=(int.parse(quant)+1).toString();
                makechangesprice();
              }, icon: Icon(Icons.add),),
            ],),
          Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: (){
                  price=(int.parse(price)-1).toString();
                  makechangesprice();
                }, icon: Icon(Icons.remove),),

                Text("Selling Price "+price),

                IconButton(onPressed: (){
                  price=(int.parse(price)+1).toString();
                  makechangesprice();
                }, icon: Icon(Icons.add),),

        ],
      ),
    ]));
  }
}



class sidedrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('rohithputhabits@gmail.com')),
          ListTile(title: Text("Vegetables"),onTap: (){
            ctStream.inputCateg.add('vegetables');
            Navigator.of(context).pop();
          },),
          ListTile(title: Text("Fruits"),onTap: (){
            ctStream.inputCateg.add('fruits');
            Navigator.of(context).pop();
          },),
          ListTile(title: Text("Groceries"),onTap: (){
            ctStream.inputCateg.add('groceries');
            Navigator.of(context).pop();
          },),
          ListTile(title: Text("Dairy"),onTap: (){
            ctStream.inputCateg.add('dairy');
            Navigator.of(context).pop();
          },),

          ListTile(title: Text("Orders Received"),onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>orderfromwh()));
           // Navigator.of(context).pop();
          },),
          ListTile(title: Text("Sign out",style: TextStyle(),),
              onTap: (){
                FirebaseAuth.instance.signOut().then((res){
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>loginpage()));
                });
              }),
        ],
      ),
    );
  }
}

class categoryStream
{

  final _categstr=StreamController<String>.broadcast();

  Sink<String> get inputCateg=> _categstr.sink;

  Stream<String> get outputcateg=> _categstr.stream.map((event) => event);

  void dispose(){
    _categstr.close();
  }
}

List prodname=[];
List quantord=[];
List status=[];
class orderfromwh extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('whordersfrom').doc(FirebaseAuth.instance.currentUser.email).snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
//            prodname.clear();
//            quantord.clear();
//            status.clear();

          if (snapshot.connectionState == ConnectionState.active) {
            print(FirebaseAuth.instance.currentUser.email);
            print(List.from(snapshot.data.data()['item']));
            prodname = List.from(snapshot.data.data()['item']);

            quantord = List.from(snapshot.data.data()['quant']);

            status = List.from(snapshot.data.data()['status']);


            print(quantord);
            print(status);
            return ListView.builder(
                itemCount: prodname.length, itemBuilder: (context, index) {
              return cardorderrec(index);
            });
          }


          else {
            return Center(child: CircularProgressIndicator(),);
          }
        },
      ),
    );
  }

}
class cardorderrec extends StatelessWidget {

  int index;

  cardorderrec(this.index);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(children: [
          Text(prodname[index]),
          Text(quantord[index]),
          Text(status[index]),

        ],
        )
    );
  }
}



class addprods extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add product"),),
      body: Card(child: Column(
        children: [
          TextField(
            controller:contr,
          ),
          FlatButton(onPressed: (){

            FirebaseFirestore.instance.collection('wholesaler').doc(FirebaseAuth.instance.currentUser.email).set({
              presentcateg:{
                contr.text:['0','0']
              }
            }, SetOptions(merge: true));

            FirebaseFirestore.instance.collection('products').doc(presentcateg).set({
               contr.text:null
            },SetOptions(merge: true));

            Navigator.of(context).pop();
           }, child: Text("Submit")),



        ],
      ),),
    );
  }
}
