



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oopproject/authentication.dart';
import 'package:oopproject/cartcust.dart';
import 'package:oopproject/dashboardretailer.dart';
import 'package:oopproject/shopList.dart';


final csStream=new categoryStream();
String presentcateg;
List<String> productname=[];


class dashboardconsumer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shop"),),
      drawer: sidedrawer() ,
      body: StreamBuilder(
      stream: ctStream.outputcateg,
      initialData: 'vegetables',
      builder:(context, snapshot){
          presentcateg=snapshot.data;
          print(presentcateg);
          return inputStream();
      } ),
    );
  }
}

class inputStream extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:FirebaseFirestore.instance.collection('products').doc(presentcateg).snapshots(),
        builder:(context, AsyncSnapshot snapshot){
          if(snapshot.connectionState==ConnectionState.active){
              DocumentSnapshot dsnapshot=snapshot.data;

              productname=dsnapshot.data().keys.toList();

              return ListView.builder(itemCount: productname.length,itemBuilder: (context,index){
                return card(index);
              });

          }
          else return Center(child: CircularProgressIndicator(),);
        });
  }
}

class card extends StatelessWidget {
  int index;
  card(this.index);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
             Text(productname[index],style: TextStyle(fontSize: 24)),
             Image.asset('assets/vegetablesimage.jpeg'),
             FlatButton(onPressed: (){
               Navigator.of(context).push(
                 MaterialPageRoute(builder: (context){
                   print(productname[index]);
                   print(presentcateg);
                   return shopList('retailer',productname[index],presentcateg);
                 })
               );


             }, child: Text("Buy Now")),

        ],
      ),
    );
  }
}


class sidedrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('rohithputha@gmail.com')),
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
          ListTile(title: Text('Cart'),onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>cartcust()));
          },),
          ListTile(title: Text("orders"),
            onTap: (){

                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>orderscust()));

            },
          ),
          ListTile(title: Text("Sign out"),
            onTap: (){
               FirebaseAuth.instance.signOut().then((res){
                 Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>loginpage()));
               });
            },
          ),

        ],
      ),
    );
  }
}
List prodname=[];
List quantord=[];
List status=[];
List retailer=[];

class orderscust extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),

      body: StreamBuilder(
        stream:FirebaseFirestore.instance.collection('custordersto').doc(FirebaseAuth.instance.currentUser.email).snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          prodname.clear();
          quantord.clear();
          status.clear();
          if(snapshot.connectionState==ConnectionState.active){

             print(snapshot.data.data().entries.toList()[0].value['item'].length);

             for(int i=0;i<snapshot.data.data().entries.toList().length;i++){

//                  print(snapshot.data().data.entries.toList()[i].value['item']);
             for(int j=0;j<snapshot.data.data().entries.toList()[i].value['item'].length;j++){
                 prodname.add(snapshot.data.data().entries.toList()[i].value['item'][j]);
                 quantord.add(snapshot.data.data().entries.toList()[i].value['quant'][j]);
                 status.add(snapshot.data.data().entries.toList()[i].value['status'][j]);
                 if(snapshot.data.data().entries.toList()[i].value['status'][j]=='delivered')feedbackmail(FirebaseAuth.instance.currentUser.email,snapshot.data.data().entries.toList()[i].value['item'][j] );
                 wholesaler.add(snapshot.data.data().keys.toList()[i]);
              }

             }

            return ListView.builder(itemCount: prodname.length,itemBuilder:(context,index){
              return cardorder(index);
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
class cardorder extends StatelessWidget {

  int index;
  cardorder(this.index);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Text(prodname[index]),
        Text(quantord[index]),
        Text(status[index]),
        FlatButton(onPressed: status[index]=='delivered'?(){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>feedback(index)));
        }:null, child: Text('feedback')),
      ],
     )
    );
  }
}
TextEditingController contr=new TextEditingController();
class feedback extends StatelessWidget {

  int index;
  feedback(this.index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Feedback")),
      body:Card(
        child: Column(
          children: [
            TextField(controller: contr,),
            FlatButton(onPressed: (){
              FirebaseFirestore.instance.collection('feedbackret').doc(retailer[index]).set({
                 contr.text:null ,
              },
              SetOptions(merge: true));
              Navigator.of(context).pop();
             }, child: Text("Submit")),
          ],
        ),
      )
    );
  }
}


