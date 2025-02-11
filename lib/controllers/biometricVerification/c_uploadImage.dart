/* import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageScreenController {
  File? imageFile;
  TextEditingController imageNameController = TextEditingController();

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
     // imageNameController.text = pickedFile.name; // تحديث اسم الملف في الـ TextField
    }
  }
}
 */


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadImageScreenController {
  File? imageFile;
  TextEditingController imageNameController = TextEditingController();

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      imageNameController.text = pickedFile.name;
    }
  }

  Future<String?> uploadImageToFirebase() async {
    if (imageFile == null) return null;

    try {
      // 🔹 تحديد مسار الصورة في Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // اسم فريد
      Reference ref = FirebaseStorage.instance.ref().child("students/$fileName.jpg");

      // 🔹 رفع الصورة
      UploadTask uploadTask = ref.putFile(imageFile!);
      TaskSnapshot snapshot = await uploadTask;

      // 🔹 الحصول على رابط الصورة بعد رفعها
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("🔥 خطأ في رفع الصورة: $e");
      return null;
    }
  }
}


void _addUserDialog(BuildContext context) {
  final FirstNameController = TextEditingController();
  final LastNameController = TextEditingController();
  final student_idController = TextEditingController();
  
  UploadImageScreenController imageController = UploadImageScreenController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('إضافة طالب جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: student_idController, decoration: InputDecoration(labelText: 'ID')),
              TextField(controller: FirstNameController, decoration: InputDecoration(labelText: 'First Name')),
              TextField(controller: LastNameController, decoration: InputDecoration(labelText: 'Last Name')),
              
             
      // ✅ زر اختيار الصورة
      ElevatedButton(
        onPressed: () async {
          await imageController.pickImage();
        },
        child: Text('اختر صورة'),
      ),
      
      // ✅ عرض الصورة المختارة
      imageController.imageFile != null
          ? Image.file(imageController.imageFile!, height: 100)
          : Text('لم يتم اختيار صورة'),
    ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (FirstNameController.text.isNotEmpty && LastNameController.text.isNotEmpty && imageController.imageFile != null) {
                // ✅ رفع الصورة إلى Firebase Storage
                String imageUrl = await uploadImageToFirebase(imageController.imageFile!);

                // ✅ حفظ بيانات الطالب في Firestore مع رابط الصورة
                await FirebaseFirestore.instance.collection("student").add({
                  "student_id": student_idController.text,
                  "FirstName": FirstNameController.text,
                  "LastName": LastNameController.text,
                  "imageUrl": imageUrl, // ✅ حفظ رابط الصورة
                });

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

// ✅ دالة رفع الصورة إلى Firebase Storage
Future<String> uploadImageToFirebase(File imageFile) async {
  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference storageRef = FirebaseStorage.instance.ref().child("students/$fileName.jpg");
  await storageRef.putFile(imageFile);
  return await storageRef.getDownloadURL(); // ✅ استرجاع رابط الصورة
}
