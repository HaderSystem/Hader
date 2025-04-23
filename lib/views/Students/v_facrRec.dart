/* import 'package:flutter/material.dart';
import 'package:flutter_application_2/auth/Login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewFaceRec extends StatefulWidget {
  const ViewFaceRec({super.key});

  @override
  State<ViewFaceRec> createState() => _ViewFaceRecState();
}

class _ViewFaceRecState extends State<ViewFaceRec> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
   //   initialData: initialData,
      builder: (BuildContext context, AsyncSnapshot snapshot) 
      {
        //loading 
        if(snapshot.connectionState == ConnectionState.waiting)

       return  const Scaffold(body: Center(child: CircularProgressIndicator(),),);

final session =snapshot.hasData? snapshot.data!.session :null ;

if(session != null ) {
   print('there is  session for face rec');
}
else { print("there is no session for face rec");}



      // إذا كانت الحالة هي "done" أو "none"
      return Text('Connection is closed or no connection available');



/* 
   // حالة الاتصال الناجح
      if (snapshot.connectionState == ConnectionState.active) {
        // بناءً على حالة الـ authState يمكنك إضافة المنطق هنا
        if (snapshot.hasData) {
          return Text('User is logged in');
        } else {
          return Text('User is not logged in');
        }
      }

      // إذا كانت الحالة هي "done" أو "none"
      return Text('Connection is closed or no connection available');
  
      

 */
     }, 
    );

    
  }
} */