
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:oopproject/User.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
UserDetails userD;
class AuthenticationBlock{
  Future<dynamic> SignUpWithEmail(String username, String password) async{
    await Firebase.initializeApp();

    User user;
    try {

      UserCredential userCredential=await _auth.createUserWithEmailAndPassword(
          email: username,
          password: password
      );

      user= userCredential.user;
      if(!user.emailVerified)
      {
        await user.sendEmailVerification();
      }
      userD=new UserDetails(user.email, null,null,null, false);
      return userD;
    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("---------------------------");
         return await SignInWithEmail(username, password);

      }
      else if (e.code == 'weak-password') {
        return 0;
      }
    } catch (e) {
      return e;
    }


  }



  Future<dynamic> SignInWithEmail(String username,String password)async{
    print("-----------------------22222224fff---------");
    await Firebase.initializeApp();

    User user;
    try{
      UserCredential userCredential= await _auth.signInWithEmailAndPassword(email: username, password: password);
      user=userCredential.user;

      userD =await getUserfromFireStore(user);
      return userD;

    }
    on FirebaseAuthException catch(e){
      if(e.code=='user-not-found')
        return 1;
      else if(e.code=='wrong-password'){
        return 2;
      }
    }
    catch(e){
      print(e);
    }
  }
}

Future<dynamic> getUserfromFireStore(User user)async{
  final db = FirebaseFirestore.instance;

  dynamic snapshot = await db.collection('UserDetails').doc(user.email).get();
  print(snapshot.data());
   if(snapshot.data()!=null){
     String type = snapshot.data()['type'];
     double latitude = snapshot.data()['latitude'];
     double longitude= snapshot.data()['longitude'];

     userD = new UserDetails(user.email, type, latitude,longitude, true);
     return userD;
   }
   else {

     userD=new UserDetails(user.email, null,null, null, true);
     return userD;
   }
}


Future<dynamic> getUser() async {
  User user = await FirebaseAuth.instance.currentUser;

  if(user==null) return null;

  else return await getUserfromFireStore(user);
}
Future<void> AuthChanges() async{
    await Firebase.initializeApp();
    _auth.authStateChanges();
}