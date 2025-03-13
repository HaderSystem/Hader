
import 'dart:io';

import 'package:flutter_application_2/models/m_student.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerStudent {

final database = Supabase.instance.client.from('student');

//create 

 Future createStudent(ModelStudent student) async {
  await database.insert(student.toMap());
 }

 //Read 
 final stream =Supabase.instance.client.from('student').stream(primaryKey: ['id'],
 ).map((data)=>data.map((studentMap)=> ModelStudent.fromMap(studentMap)
 ).toList());

 //update 

 Future updateStudent(ModelStudent oldVersionofStudents, String newContent) async {
  await database.update({'imageURL':newContent})
  .eq('studentid',
   oldVersionofStudents.studentid!);
   
  // await database.update({'firstname':oldVersionofStudents});
 }



 Future editStudent(ModelStudent oldVersionofStudents, String newContent) async {
  await database.update({'imageURL':newContent})
  .eq('studentid',
   oldVersionofStudents.studentid!);
   
  // await database.update({'firstname':oldVersionofStudents});
 }



Future deleteStudent (ModelStudent student) async {
  await database.delete().eq('studentid', student.studentid!);
}


 //final _supabaseClient = Supabase.instance.client;







Future<String> uploadImage(File image) async {
    final fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg'; // تحديد اسم الصورة بشكل فريد
    final fileBytes = await image.readAsBytes(); // قراءة بيانات الصورة
    
    final response = await storage.upload(fileName, fileBytes as File); // رفع الصورة
   /*  if (response.error != null) {
      print('Error uploading image: ${response.error?.message}');
      return ''; // إرجاع فارغ في حالة حدوث خطأ
    } */
    return fileName; // إرجاع اسم الملف ليتم استخدامه في الخطوة التالية
  }

final storage = Supabase.instance.client.storage.from('HaderSystem');

Future<String> getImageUrl(String fileName) async {
  final response = storage.getPublicUrl(fileName); // الحصول على الرابط العام للصورة
 /*  if (response.error != null) {
    print('Error getting image URL: ${response.error?.message}');
    return ''; // إرجاع فارغ في حالة حدوث خطأ
  } */
 
  return response;
}



/* 

Future<void> getImages() async {
  final response = await _supabaseClient
      .from('HaderSystem')
      .select('StudentsImages')  // حدد العمود الذي يحتوي على روابط الصور
     // .eq('some_column', 'some_value')  // فلتر حسب شرط معين
      .single();

 /*  if (response.
  error != null) {
    print('Error fetching images: ${response.error?.message}');
    return;
  } */

  final data = response.values;
  ;
  print('Fetched images: $data');
}

 */

















}
/*   final SupabaseClient _supabase = Supabase.instance.client;

   // جلب بيانات جميع الطلاب
  void getUser(Future <List<ModelStudent>> user) async {
    final response = await _supabase.from('student').select();
    if (Error() != null) {
      throw Exception('Failed to fetch users: ');
    }

    List<dynamic> data = response;
   // return data.map((item) => ModelStudent.fromMap(item).).toList();
  }
 
  // إضافة مستخدم جديد
  Future<void> addUser(ModelStudent user) async {
   final response =await _supabase.from('student').insert(user.toMap());

    if (response.error != null) {
      throw Exception('Failed to add user: ${response.error!.message}');
    }  
  }

 /*  // تحديث بيانات مستخدم
  Future<void> updateUser(ModelStudent user) async {
    final response = await _supabase.from('student').update(user.toMap()).eq('studentid', user.studentid);
    if (response.error != null) {
      throw Exception('Failed to update user: ${response.error!.message}');
    }
  }
 */
  // حذف مستخدم
  Future<void> deleteUser(String userId) async {
    final response = await _supabase.from('student').delete().eq('studentid', userId);
    if (response.error != null) {
      throw Exception('Failed to delete user: ${response.error!.message}');
    }
  }} */
































/*   // جلب البيانات بشكل مستمر (Stream)
  Stream<List<ModelStudent>> getStudentsStream() {
    return _supabase
        .from('student')
        .stream(primaryKey: ['student_id'])
        .map((data) => data.map((item) => ModelStudent.fromMap(item)).toList());
  }
} */

/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/models/m_student.dart';

class ControllerStudent {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب بيانات جميع المستخدمين
  Future<List<ModelStudent>> getUsers() async {
    var snapshot = await _firestore.collection('student').get();
    return snapshot.docs
        .map((doc) => ModelStudent.fromMap(doc.data(), doc.id))
        .toList();
  }

  // إضافة مستخدم جديد
  Future<void> addUser(ModelStudent user) async {
    await _firestore.collection('student').add(user.toMap());
  }

  // تحديث بيانات مستخدم
  Future<void> updateUser(ModelStudent user) async {
    await _firestore.collection('student').doc(user.student_id).update(user.toMap());
  }

  // حذف مستخدم
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('student').doc(userId).delete();
  }

  
  Stream<List<ModelStudent>> getStudentsStream() {
  return FirebaseFirestore.instance.collection('student').snapshots().map(
    (snapshot) => snapshot.docs.map(
      (doc) => ModelStudent.fromMap(doc.data(),doc.id),
    ).toList(),
  );
}

}
 */