
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer2/mailer.dart';
import 'package:oopproject/cartret.dart';
import 'package:oopproject/wholesalerlist.dart';

import 'authentication.dart';



final ctStream=new categoryStream();
List<String> productname=[];
List<String> productquant=[];
List<String> productprice=[];
String presentcateg;
TextEditingController contr=new TextEditingController();
class dashboardretailer extends StatefulWidget {
  @override
  _dashboardretailerState createState() => _dashboardretailerState();
}



class _dashboardretailerState extends State<dashboardretailer> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: sidedrawer(),
      appBar: AppBar(
        title: Text("My Shop"),
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
        stream: FirebaseFirestore.instance.collection('retailer').doc('rohithputha@gmail.com').snapshots(),

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

  }

  void makechangesprice(){
    FirebaseFirestore.instance.collection('retailer').doc('rohithputha@gmail.com').update({
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
            }, icon: Icon(Icons.add), )
          ]),
          FlatButton(child: Text("Buy stock"),onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> wholeList('wholesaler',productname[index],presentcateg)));
          },),
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
          ListTile(title: Text("Cart"),onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>cartret()));
            //Navigator.of(context).pop();
          },),

          ListTile(title: Text("Your Orders"),onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ordersret()));
            //Navigator.of(context).pop();
          },),

          ListTile(title: Text("Order Received"),onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>orderfromret()));
            //Navigator.of(context).pop();
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

class categoryStream{

  final _categstr=StreamController<String>.broadcast();

  Sink<String> get inputCateg=> _categstr.sink;

  Stream<String> get outputcateg=> _categstr.stream.map((event) => event);

  void dispose(){
    _categstr.close();
  }
}


List<dynamic> prodname=[];
List<dynamic> quantord=[];
List<dynamic> status=[];
List<dynamic> wholesaler=[];

class ordersret extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),

      body: StreamBuilder(
        stream:FirebaseFirestore.instance.collection('retordersto').doc(FirebaseAuth.instance.currentUser.email).snapshots(),
        builder: (context, AsyncSnapshot snapshot){
          if(snapshot.connectionState==ConnectionState.active){

            prodname.clear();
            quantord.clear();
            status.clear();

            print(snapshot.data.data().entries.toList()[0].value['item'].length);

            for(int i=0;i<snapshot.data.data().entries.toList().length;i++){

//                  print(snapshot.data().data.entries.toList()[i].value['item']);
              for(int j=0;j<snapshot.data.data().entries.toList()[i].value['item'].length;j++){
                prodname.add(snapshot.data.data().entries.toList()[i].value['item'][j]);
                quantord.add(snapshot.data.data().entries.toList()[i].value['quant'][j]);
                status.add(snapshot.data.data().entries.toList()[i].value['status'][j]);
                wholesaler.add(snapshot.data.data().keys.toList()[i]);
                if(snapshot.data.data().entries.toList()[i].value['status'][j]=='delivered')feedbackmail(FirebaseAuth.instance.currentUser.email, snapshot.data.data().entries.toList()[i].value['item'][j]);
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
TextEditingController contr2=new TextEditingController();
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
              TextField(controller: contr2,),
              FlatButton(onPressed: (){
                FirebaseFirestore.instance.collection('feedbackwh').doc(wholesaler[index]).set({
                  contr2.text:null ,
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



class orderfromret extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          title: Text("Orders"),
        ),

        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('retialordersfrom').doc(FirebaseAuth.instance.currentUser.email).snapshots(),
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

            FirebaseFirestore.instance.collection('retailer').doc(FirebaseAuth.instance.currentUser.email).set({
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


feedbackmail(String emailid, item){
  String username = "rohithputha@gmail.com";
  String password = "rohith2000";

  // final smtpServer = gmailRelaySaslXoauth2(username,password);

  var options = new GmailSmtpOptions()
    ..username = 'rohithputha@gmail.com'
    ..password = 'rohith2000';
  // Creating the Gmail server
  var emailTransport = new SmtpTransport(options);

  // Create our email message.
  var envelope = new Envelope()
    ..from = 'rohithputha@gmail.com'
    ..recipients.add(emailid)
    ..subject = 'Live Mart'
    ..text = 'Your'+item+' have been delivered. Please give your feedback in the app. Thank you';

  emailTransport.send(envelope)
      .then((envelope) => print('Email sent!'))
      .catchError((e) => print('Error occurred: $e'));
}

Future<String> getquant(String cat,dynamic snapshot, String item,String quant) async{

  int index=snapshot.data().keys.toList().indexOf(cat);

  dynamic snapshots= FirebaseFirestore.instance.collection('wholesaler').doc('rohithputhabits@gmail.com').get();
  return (int.parse(snapshot.data().entries.toList()[index].value.entries.toList()[item].value[1])-int.parse(quant)).toString();
}