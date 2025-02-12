/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_2/controllers/c_students.dart';
import 'package:flutter_application_2/models/m_student.dart';

class ViewAdmin extends StatefulWidget {
  @override
  _ViewAdminState createState() => _ViewAdminState();
}

class _ViewAdminState extends State<ViewAdmin> {
  final ControllerStudent _userController = ControllerStudent();

  Future<List<ModelStudent>> getStudents() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("student").get();
    return querySnapshot.docs.map((doc) => ModelStudent(
      student_id: doc["student_id"] ?? '',
      FirstName: doc["FirstName"] ?? '',
      LastName: doc["LastName"] ?? '',
      imageUrl: doc["imageUrl"] ?? '',
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة المستخدمين')),
      body: FutureBuilder<List<ModelStudent>>(
        future: getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ في جلب البيانات: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا يوجد مستخدمين بعد!'));
          }

          var students = snapshot.data!;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: students.length,
            itemBuilder: (context, i) {
              return Card(
                child: Column(
                  children: [
                    students[i].imageUrl.isNotEmpty
                        ? Image.network(students[i].imageUrl, height: 100, width: 100, fit: BoxFit.cover)
                        : Icon(Icons.person, size: 100),
                    Text(students[i].FirstName, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(students[i].LastName),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addUserDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addUserDialog() {
    final FirstNameController = TextEditingController();
    final LastNameController = TextEditingController();
    final student_idController = TextEditingController();
    File? _selectedImage;
    final picker = ImagePicker();

    Future<void> _pickImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة طالب جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: student_idController, decoration: InputDecoration(labelText: 'ID')),
              TextField(controller: FirstNameController, decoration: InputDecoration(labelText: 'الاسم الأول')),
              TextField(controller: LastNameController, decoration: InputDecoration(labelText: 'الاسم الأخير')),
              SizedBox(height: 10),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 100)
                  : ElevatedButton(onPressed: _pickImage, child: Text("اختيار صورة")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
  onPressed: () async {
    if (FirstNameController.text.isNotEmpty && LastNameController.text.isNotEmpty) {
      // رفع الصورة إن وُجدت
      String imageUrl = '';
      if (UploadImageScreenController != null) {
        String fileName = "users/${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(UploadImageScreenController!);
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      await _userController.addUser(
        ModelStudent(
          student_id: student_idController.text,
          FirstName: FirstNameController.text,
          LastName: LastNameController.text,
          imageUrl: imageUrl, // تمرير رابط الصورة هنا
        ),
      );
      Navigator.pop(context);
      setState(() {}); // تحديث الواجهة
    }
  },
  child: Text('Add'),
),
          ],
        );
      },
    );
  }

  Future<String> _uploadImage(File image) async {
    try {
      String fileName = "students/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("🔥 خطأ أثناء رفع الصورة: $e");
      return "";
    }
  }
}
 */
 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_application_2/controllers/biometricVerification/c_uploadImage.dart';
import 'package:flutter_application_2/controllers/c_students.dart';
import 'package:flutter_application_2/models/m_student.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/biometricVerification/c_uploadImage.dart';

/* 
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../controllers/biometricVerification/c_uploadImage.dart'; */

class ViewAdmin extends StatefulWidget {
  @override
  _ViewAdminState createState() => _ViewAdminState();
}

class _ViewAdminState extends State<ViewAdmin> {
  final ControllerStudent _studentController = ControllerStudent();

  Future<List<ModelStudent>> getStudents() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("student").get();
    return querySnapshot.docs.map((doc) => ModelStudent(
      student_id: doc["student_id"]??'', 
      FirstName: doc["FirstName"]?? '',  
      LastName: doc["LastName"]?? '', 
    // imageUrl: doc["imageUrl"]?? '', 

    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة الطلاب')),
      body: FutureBuilder<List<ModelStudent>>(
        future: getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
             print(" خطأ في جلب البيانات: ${snapshot.error}");
  return Center(child: Text('خطأ في جلب البيانات: ${snapshot.error}'));

          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا يوجد مستخدمين بعد!'));
          }

          var students = snapshot.data!;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: students.length,
            itemBuilder: (context, i) {
              return Card(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(students[i].FirstName, style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(students[i].LastName),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: () => _addStudentDialog()
      // {print('tt');} 
      ,
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ), 
    );
  }

  void _addStudentDialog() {
  final FirstNameController = TextEditingController();
  final LastNameController = TextEditingController();
  final student_idController = TextEditingController();



  // حذف التعريف الخاطئ لاسم المتغير
   ControllerUploadFile imageController = ControllerUploadFile(); // إعادة تسميته لعدم التضارب

  showDialog(
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
    
  },
);         

  }} 






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






/* 






 /*  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera); // أو ImageSource.gallery

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      }); */

      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      String fileName = "users/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(_image!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();

      await firestore.collection("face_images").add({
        "image_url": downloadURL,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم رفع الصورة بنجاح!"))
      );
    } catch (e) {
      print("حدث خطأ أثناء الرفع: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل في رفع الصورة"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("رفع صورة")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Text("لم يتم تحديد صورة"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("اختر صورة"),
            ),
          ],
        ),
      ),
    );
  }
} */
 

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