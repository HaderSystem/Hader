import 'package:flutter/material.dart';
import 'package:flutter_application_2/views/Students/add.dart';
import 'package:flutter_application_2/views/Students/v_facrRec.dart';
import 'package:flutter_application_2/views/v_admin.dart';



class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('اختيار الدور')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.admin_panel_settings),
              label: Text('دخول كأدمن'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewAdmin()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
         
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.school),
              label: Text('دخول كطالب'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>AddStud()), //ViewStudentLogin()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              
            ),       
             SizedBox(height: 20),

             ElevatedButton.icon(
              icon: Icon(Icons.school),
              label: Text('بصمة الوجه'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewFaceRec()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),)
          ],
        ),
      ),
    );
  }
}




/* import 'package:flutter/material.dart';
import 'package:flutter_application_2/controllers/c_students.dart';
import 'package:flutter_application_2/models/m_student.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ControllerStudent _userController = ControllerStudent();
  late Future<List<ModelStudent>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userController.getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المستخدمون')),
      body: FutureBuilder<List<ModelStudent>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ في جلب البيانات'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا يوجد بيانات'));
          }

          var users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(users[index].FirstName),
                subtitle: Text(users[index].LastName),
              );
            },
          );
        },
      ),
    );
  }
}
 */