
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:oopproject/APIdistance.dart';
import 'package:oopproject/dashboad.dart';
import 'package:oopproject/dashboardconsumer.dart';
import 'package:oopproject/dashboardretailer.dart';



TextEditingController locdistcontr=new TextEditingController();
TextEditingController quantcontr=new TextEditingController();
int d=-1,q=-1;
enum mode{offline,online}
mode _character=mode.online;
String type;
String prod;
String categ;
class wholeList extends StatefulWidget {
  wholeList(String t,String p, String c)
  {
    type=t;
    prod=p;
    categ=c;
  }

  @override
  _shopListState createState() => _shopListState();
}

class _shopListState extends State<wholeList> {



  @override
  Widget build(BuildContext bcontext) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Text("Choose the wholesaler"),
      ),

      body:



      FutureBuilder(
          future: distanceAPI.getListOfretailers(q, d, type, prod, categ),
          builder: (context,snapshot){

            if(snapshot.connectionState==ConnectionState.done){
              print(snapshot.data);

              if(snapshot.data!=null)
                return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: (snapshot.data.length)+1,
                    itemBuilder:(bcontext,index){

                      if(index==0){

                        return Card(
                          child:  Column(
                            children: [

                              Center(child:Text("Enter the max distance",style: TextStyle(fontSize: 14),)),
                              TextFormField(
                                autofocus: true,
                                textAlign: TextAlign.center,
                                controller: locdistcontr,
                                keyboardType: TextInputType.number,


                              ),

                              //Spacer(flex: 2,),
                              Center(child:Text("Enter the quantity required",style: TextStyle(fontSize: 14),)),

                              TextFormField(
                                autofocus: true,
                                textAlign: TextAlign.center,
                                controller: quantcontr,
                                keyboardType: TextInputType.number,

                              ),

                              ListTile(
                                  title:Text("Online"),
                                  leading:Radio(value:mode.online,groupValue: _character,onChanged: (mode value){
                                    setState(() {
                                      _character=value;
                                    });
                                  },)
                              ),
                              ListTile(
                                  title:Text("Offline"),
                                  leading:Radio(value:mode.offline,groupValue: _character,onChanged: (mode value){
                                    setState(() {
                                      _character=value;
                                    });
                                  },)
                              ),
                              FlatButton(child: Text("Search"),onPressed: (){
                                setState(() {
                                  d=int.parse(locdistcontr.text);
                                  q=int.parse(quantcontr.text);
                                });
                              },)
                            ],
                          ),
                        );
                      }
                      //return card(snapshot.data[index]);
                      else return card(snapshot.data[index-1]);
                    });

              else return Center(child: Text("No Shops present"),);
            }
            else return Center(child: CircularProgressIndicator());
          }),

    );
  }
}

class card extends StatelessWidget {

  dynamic snapshot;
  card(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
          children: [
            Text(snapshot[0],style: TextStyle(fontSize: 24),),
            Text(snapshot[1],style: TextStyle(fontSize: 24),),
            Text(snapshot[2],style: TextStyle(fontSize: 24),),
            FlatButton(onPressed: (){
              if(_character==mode.online)
                addtocart(snapshot[0],q.toString(),prod,context );

              else addtocalender(snapshot[0],q.toString(),prod,context );
            }, child: Text("Buy")),
          ],
        )
    );
  }
}

addtocart(String email,String quant,String prod, context) async{

  User user=await FirebaseAuth.instance.currentUser;

  FirebaseFirestore.instance.collection('cartRet').doc(user.email).set(
      {
        prod:{
          "email": email,
          "quant": quant,
        }
      },
      SetOptions(merge: true)
  ).then((value) =>Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) {
    return dashboardretailer();
  }))
  );
}

addtocalender(String email,String quant, String prod, context) async{

  Event event=Event(
    title: 'Pick up order',
    description: 'You need to pick up your order from'+email,
    location: 'test location',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(minutes: 30)),
    allDay: true,

  );

  Add2Calendar.addEvent2Cal(event).then((success)=>SnackBar(content: Text(success?'Added to calender':'Error while adding to calender')));
}