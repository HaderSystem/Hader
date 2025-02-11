import 'package:cloud_firestore/cloud_firestore.dart';
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
