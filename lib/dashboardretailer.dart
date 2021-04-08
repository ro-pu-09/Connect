
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



final ctStream=new categoryStream();
List<String> productname=[];
List<String> productquant=[];
List<String> productprice=[];


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
      ),
      body: StreamBuilder(
        initialData: 'vegetables',
      stream: ctStream.outputcateg,
      builder: (context,snapshot){


          final db=FirebaseFirestore.instance;
          return intputStream(snapshot.data);


      },
    )
    );

  }
}


class intputStream extends StatelessWidget {
  String categ;
  intputStream(this.categ);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('retailer').doc('rohithputha@gmail.com').snapshots(),

        builder: (context,AsyncSnapshot snapshot){

           if(snapshot.connectionState==ConnectionState.active) {

             DocumentSnapshot Dsnapshot=snapshot.data;
             int index=Dsnapshot.data().keys.toList().indexOf(categ);
//             print("-=--------------");
//             print(index);
//             print("---------------");
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
  productcard(this.index){
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
//    setState(() {
//
//    });
    FirebaseFirestore.instance.collection('retailer').doc('rohithputha@gmail.com').update({
       'vegetables':{
        'onions':FieldValue.arrayUnion([price, quant ]),
         //'tomatoes':FieldValue.arrayUnion(['60','100']),
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Text(productname[index]),

          Text("Quantity Available "+quant),
          Row(children: [
            ElevatedButton.icon(onPressed: (){
              price=(int.parse(price)-1).toString();
              makechangesprice();
            }, icon: Icon(Icons.remove), label: Text("subtract")),

            Text("Selling Price "+price),

            ElevatedButton.icon(onPressed: null, icon: Icon(Icons.add), label: Text("add"))
          ]),
          FlatButton(child: Text("Buy stock"),onPressed: (){},),
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