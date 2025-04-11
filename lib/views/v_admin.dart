
 import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_application_2/controllers/biometricVerification/c_uploadImage.dart';
import 'package:flutter_application_2/controllers/c_students.dart';
import 'package:flutter_application_2/controllers/generatePassword.dart';
import 'package:flutter_application_2/models/m_student.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_2/auth/auth_service.dart';




class ViewAdmin extends StatefulWidget {
   // const ViewAdmin({super.key});

  @override
  _ViewAdminState createState() => _ViewAdminState();
}


class _ViewAdminState extends State<ViewAdmin> {
 File? _imageFile;

final studentDatabase = ControllerStudent();



  final studentIDController =TextEditingController();
    final FirstNameController =TextEditingController();
  final LastNameController =TextEditingController();
  final emailController =TextEditingController();
   // final passwordController =TextEditingController();
   // final imageURLcontroller =TextEditingController(uploadImage.path);

String pass=generateRandomPassword(5);
 // final passwordController = Text("data");

insert () async{
  try{
final response =await Supabase.instance.client.from('student').insert({
"studentid":studentIDController.text,
"firstname":FirstNameController.text
,
"lastname":LastNameController,
"email":emailController,
"password" : pass,
"imageURL" : UploadImage(),
});
if(response.error !=null){
  print("Task added successfully");
}
else{    print("Error: ${response.error!.message}");
}
  } catch(e){ }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة الطلاب')),
      body:
      StreamBuilder(
        //listens to this stream 
        stream: studentDatabase.stream,

        builder: (context, snapshot) {
          if (!snapshot.hasData){
            return const Center(child: CircularProgressIndicator(),);
          }

          //loaded 
          final students=snapshot.data!;

          //list of students 
          return ListView.builder(itemCount: students.length,itemBuilder: (context,index){

            try{ 
//get each student
final student=students[index];


//list title ui 

return ListTile(title: Text('id: ${student.studentid}'),

trailing:SizedBox(
  width: 100,child: Row(children: [
  //  Image(image: student.imageURL,),
    //update button
   // IconButton(onPressed: ()=>studentDatabase.updateStudent(student, student.firstname), icon:Icon( Icons.edit),),
    IconButton(onPressed: ()=>deleteStudent(student), icon: Icon(Icons.delete)),

/* IconButton(onPressed: (){

/*  MenuBar
 (children: [pragma('object')
                   //  deleteStudent(student)

                
                  
 */
}, icon: Icon(Icons.menu)
)
, */

  ],//trailing
            
  
  ),
)

/* 
/* IconButton(onPressed: (){child}, icon: const Icon(Icons.menu))*/
Drawer(child: ListView(/* padding: EdgeInsets.zero */
children: <Widget>[DrawerHeader(child: /* Text('Edit') */Icon(Icons.menu),
),ListTile(title: Text('delete'),
onTap: (){studentDatabase.deleteStudent(student);
},)],),)

 */
 );
            }//try

            catch(e){  return ListTile(title: Text('Error in builder: $e'));}
          },
          
          );
        }, //builder
      )
      
     ,


      //add student button

       floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          
            builder: (BuildContext context) {
              return AlertDialog(content: Column(
              
                children: 
                    [//TextField( controller:studentIDController,decoration: InputDecoration(labelText:"id: ${studentIDController }" ) ,),
              TextField( controller:FirstNameController,decoration: InputDecoration(labelText:"first name" ),),
                    TextField( controller:LastNameController,decoration: InputDecoration(labelText:"last name" ),),
            TextField( controller:emailController, decoration: InputDecoration(labelText:"email" ),),
                    //pick image button
            ElevatedButton(onPressed:pickImage , child: Text("Picked Image"),),
            //   _imageFile !=null? Image.file(_imageFile!):const Text("no image selected"),
              
                    
                    ]),
               actions: [
                TextButton(onPressed: (){Navigator.pop(context);/* studentIDController.clear(); */}, child: Text('cancel'),),
               //   TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
                  ElevatedButton(
                    onPressed: () async {
                        final ControllerStudent _studentController = ControllerStudent();
                    //  if (studentIDController.text.isNotEmpty && FirstNameController.text.isNotEmpty) {
                        try { 
                          UploadImage();
                        print(pass);
                          //studentDatabase.uploadImage;
              print('object');            
                    Navigator.pop(context);
                        print('12');

final SupabaseClient _supabase =Supabase.instance.client;



Future<void> createUserAsAdmin({
  required String email,
  required String password,
}) async {
  final url = Uri.parse('https://<ilwxmfwgmbxmzcjczxka>.supabase.co/auth/v1/admin/users');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer <eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlsd3htZndnbWJ4bXpjamN6eGthIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczOTM1OTE0OSwiZXhwIjoyMDU0OTM1MTQ5fQ.vhJ4UHv_s60j4tWqMDQ4DSqLpljJfRwd2Jr2C2WTlqA>',
      'apikey': '<eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlsd3htZndnbWJ4bXpjamN6eGthIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczOTM1OTE0OSwiZXhwIjoyMDU0OTM1MTQ5fQ.vhJ4UHv_s60j4tWqMDQ4DSqLpljJfRwd2Jr2C2WTlqA>', // نفس المفتاح
    },
    body: jsonEncode({
      'email': emailController,
      'password': pass,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    final userId = data['UID'];
    print('User created! User ID: $userId');

    // هون بتضيفه على جدول الطلاب (students) باستخدام supabase client
    await _supabase.from('student').insert({
      'user_id': userId,
      // باقي معلومات الطالب
    });

  } else {
    print('Error creating user: ${response.body}');
  }
}

/* 
              final response = await Supabase.instance.client.auth.admin.createUser(
  AdminUserAttributes(
    email: 'student@email.com',
    password: 'secret123', // لازم تعطيه باسورد
    userMetadata: {
    //  'role': 'student',
     // 'name': 'Ahmad',
    },
  ),
);

final userId = response.user?.id;



await Supabase.instance.client.from('student').insert({
  'user_id': userId,
  //'name': 'Ahmad',
  //'class': '10A',
  // أي بيانات تانية
});


 */

                          await _studentController.createStudent(
                          ModelStudent(/* studentid: studentIDController.text ,*/
                           firstname: FirstNameController.text,  
                           lastname: LastNameController.text,
                           email: emailController.text,
                           password:pass,// passwordController,
                          /*   imageURL:  */   ),
                        );

                        } catch(e){print('an error $e');}
                      }
                  //  }
                  // 
                  ,
                    child: Text('Add'),),]);

            }
          ), child: Icon(Icons.add)

        )

    );
  
   
  }
  


 Future pickImage() async{
    //picker
    final ImagePicker picker=ImagePicker();

    //pick from gallery
    final XFile? image =await picker.pickImage(source: ImageSource.gallery);
    
    //update image preview
    if (image !=null ){
      setState(() {
        _imageFile =File(image.path);
      });
    } 
    
  }




  
  //upload
  
Future UploadImage() async{
 // if (_imageFile ==null) return;


  //generate a unique file path
  final fileName='${DateTime.now().millisecondsSinceEpoch}.jpg';
   //   final fileBytes = await _imageFile?.readAsBytes(); // قراءة بيانات الصورة


       //   final response = await Supabase.instance.client.storage.from('HaderSystem').upload(fileName, fileBytes as File); // رفع الصورة
  //final resonse = await Supabase.instance.client.storage.getBucket(fileName); // الحصول على الرابط العام للصورة

//print(fileBytes);

  final path ='StudentsImages/${fileName}';

  //upload the image to supabase storage
  await Supabase.instance.client.storage
  .from('HaderSystem')
  .upload(path, _imageFile!).then((value)=>ScaffoldMessenger.of(context)/* .showSnackBar(const SnackBar(content:Text("Image upload successful !"))) */);

//int a=studentDatabase.storage;
//get url 
//int studentid = getStudentIdFromSomewhere();
final getURL= await Supabase.instance.client.storage
  .from('HaderSystem').getPublicUrl(path);

     await Supabase.instance.client
        .from('student') // تأكد من أن اسم الجدول صحيح
        .update({
          'imageURL': getURL, // اسناد الرابط للعمود
        })
        .eq('studentid',50
      ); // شرط الwhere 
} 


void deleteStudent(ModelStudent student ){

showDialog(
          context: context,
          
            builder: (BuildContext context) {
              return AlertDialog(title: Text('Delete Student'),content:
              TextField( controller:
              
              studentIDController,),
                    
                  
                actions: [
                TextButton(onPressed: (){
                  studentIDController.clear();
                
                  Navigator.pop(context);
                  
                  /* studentIDController.clear(); */},
                    child: Text('cancel'),),
               //   TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
                
                
                 //save button
                  ElevatedButton(
                    onPressed: ()  {
     
     studentDatabase.deleteStudent(student);

     Navigator.pop(context);
     studentIDController.clear();

                      },
                  
                    child: Text('delete'),),
                  


          /* ElevatedButton(onPressed: ()  {
studentDatabase.updateStudent(ModelStudent(studentid:student.studentid ,firstname: 'nana', lastname: 'nana',imageURL: 'nana'), 
  '${UploadImage()}');

     Navigator.pop(context);
     studentIDController.clear();

  },child: Text('update'),),
   */

  ]
 ) ;
}
          );
      //     child: Icon(Icons.add);

        

}
  
}
  
  
  

        /*    GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        //    itemCount: student.length,
            itemBuilder: (context, i) {
              return Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container()
                   //   Text(students[i].FirstName, style: TextStyle(fontWeight: FontWeight.bold)),
                     // Text(students[i].LastName),
                    ],
                  ),
                ), 
              );
            },
          )
    );*/
    

      
    /*    floatingActionButton: FloatingActionButton(
        onPressed: () => _addStudentDialog()
      // {print('tt');} 
      ,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ), 
    ); */
  /* 

  void _addStudentDialog() {
  final FirstNameController = TextEditingController();
  final LastNameController = TextEditingController();
  final student_idController = TextEditingController();


  }
  // حذف التعريف الخاطئ لاسم المتغير
   ControllerUploadFile imageController = ControllerUploadFile(); // إعادة تسميته لعدم التضارب
 */
  /* showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text('Add new student'),
      content: SingleChildScrollView( // ✅ يضمن عدم حدوث Overflow
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: student_idController, decoration: InputDecoration(labelText: 'ID')),
            TextField(controller: FirstNameController, decoration: InputDecoration(labelText: 'First Name')),
            TextField(controller: LastNameController, decoration: InputDecoration(labelText: 'Last Name')),

            // ✅ زر اختيار الصورة
            ElevatedButton(
              onPressed: () async {
              //  await imageController.pickImage();
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
    setState(() {
    //  ControllerUploadFile = PlatformFile(pickedFile.path);
    print("image null");
    });
  }
              print("picked image");
              },
              child: Text(' اختر صورة للطالب'),
            ),

            // ✅ عرض الصورة المختارة
        /*     imageController.imageFile != null
                ? SizedBox(
                    height: 100, // ✅ يمنع الـ Overflow
                    child: Image.file(imageController.imageFile!),
                  )
                : Text('لم يتم اختيار صورة'), */
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            // تنفيذ إضافة الطالب
            Navigator.pop(context);
          },
          child: Text('Add'),
        ),
      ]
    );
    
  }, *    

  }} 


 */



/*

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _image;
  final picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> _pickImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      UploadImageScreenController = File(pickedFile.path);
    });
  }
}
 */


/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/controllers/c_students.dart';
import 'package:flutter_application_2/models/m_student.dart';


class ViewAdmin extends StatefulWidget {
  @override
  _ViewAdminState createState() => _ViewAdminState();
}

class _ViewAdminState extends State<ViewAdmin> {

//fetch students
List students=[ ];

@override
void initState(){
  getStudents() async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("student").get();
    students.addAll(querySnapshot.docs);
  setState(() {
        students = querySnapshot.docs.map((doc) => doc.data()).toList();

  });
  }

}


  final ControllerStudent _userController = ControllerStudent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(title: Text('إدارة المستخدمين')), // ✅ العنوان فقط داخل الـ AppBar
  /* body: SingleChildScrollView(
    child: Column(
      children: [
        Divider(thickness: 2),
        Text('قائمة الطلاب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        _buildStudentList(), // ✅ هذا داخل body وليس AppBar
      ],
    ),
  ),
); */

 /*    return Scaffold(
      appBar: AppBar(title: Text('إدارة المستخدمين'),Divider(thickness: 2),
Text('قائمة الطلاب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
_buildStudentList(),
), */
      body:GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2), itemBuilder: (context, int i){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ في جلب البيانات'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا يوجد مستخدمين بعد!'));
          } 
          
          return
        
    
         Card(
          child: Container(padding: EdgeInsets.all(10),
          child: Column(children: [
          Text(students[i].FirstName)
        
          ],),),
        );
      })


      /* 
       StreamBuilder<List<ModelStudent>>(
        stream: _userController.getStudentStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ في جلب البيانات'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا يوجد مستخدمين بعد!'));
          }

          var students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, i) {
              return ListTile(
                title: Text(students[i].FirstName),
                subtitle: Text(students[i].LastName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editUserDialog(students[i]),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(students[i].student_id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
 */

,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addUserDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      )
    );
    
    
      }

  void _addUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة مستخدم جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'الاسم')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'الإيميل')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  await _userController.addUser(
                    ModelStudent(student_id: '', FirstName: nameController.text, LastName: emailController.text),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _editUserDialog(ModelStudent student) {
    final nameController = TextEditingController(text: student.FirstName);
    final emailController = TextEditingController(text: student.LastName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل بيانات المستخدم'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'الاسم')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'الإيميل')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  await _userController.updateUser(
                    ModelStudent(student_id: student.student_id, FirstName: nameController.text, LastName: emailController.text),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) async {
    await _userController.deleteUser(userId);
  }
}

extension on ControllerStudent {
  getStudentStream() {}
}



Widget _buildStudentList() {
  return StreamBuilder<List<ModelStudent>>(
    stream: _userController.getStudentsStream(), // جلب الطلاب فقط
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('خطأ في جلب البيانات'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text('لا يوجد طلاب مسجلين!'));
      }

      var students = snapshot.data!;
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: students.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.green),
              title: Text(students[index].FirstName),
              subtitle: Text(students[index].LastName),
            ),
          );
        },
      );
    },
  );
}

class _userController {
  static getStudentsStream() {}
}

*/
