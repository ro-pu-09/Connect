



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oopproject/authentication.dart';
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
          ListTile(title: Text("Sign out"),
            onTap: (){
               FirebaseAuth.instance.signOut().then((res){
                 Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>loginpage()));
               });
            },
          )
        ],
      ),
    );
  }
}


