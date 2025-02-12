import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerUploadFile extends StatefulWidget {
  const ControllerUploadFile({super.key,});

  @override
  State<ControllerUploadFile> createState() => _ControllerUploadFileState();
  
}

class _ControllerUploadFileState extends State<ControllerUploadFile> {
  PlatformFile? pickedFile;

  // 1. إعداد اتصال Supabase
  final supabaseUrl = 'https://ilwxmfwgmbxmzcjczxka.supabase.co';
  final supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlsd3htZndnbWJ4bXpjamN6eGthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkzNTkxNDksImV4cCI6MjA1NDkzNTE0OX0.QdJmkj-6Fz0PK8IhjNmINOOsY32YQmRWklzX345Ccmg';
  late SupabaseClient supabase;

  @override
  void initState() {
    super.initState();
    supabase = SupabaseClient(supabaseUrl, supabaseKey);
  }

  // 2. رفع الصورة إلى Supabase
  Future uploadFileToSupabase() async {
    if (pickedFile == null) return;

    final file = File(pickedFile!.path!);
    final fileName = 'assets/${pickedFile!.name}';

    // رفع الصورة إلى Supabase
    final storageResponse = await supabase.storage
        .from('HaderSystem')
        .upload(fileName, file);

     // التعامل مع الخطأ بشكل صحيح
  /*   if (storageResponse.error != null) {
      print("Error uploading file to Supabase: ${storageResponse.error?.message}");
    } else { */
      // إذا لم يكن هناك خطأ، احصل على الرابط العام
      final fileUrl = supabase.storage
          .from('HaderSystem/StudentsImages')
          .getPublicUrl(fileName);
      
      // تخزين رابط الصورة في Firebase Firestore
      await saveFileUrlToFirebase(fileUrl);
    //}
  }

  // 3. تخزين رابط الصورة في Firebase Firestore
  Future saveFileUrlToFirebase(String fileUrl) async {
    try {
      await FirebaseFirestore.instance.collection('students').add({
        'fileUrl': fileUrl,
        'uploadedAt': Timestamp.now(),
      });
      print("File URL saved to Firebase Firestore");
    } catch (e) {
      print("Error saving file URL to Firestore: $e");
    }
  }

  // 4. اختيار الملف
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedFile != null)
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Image.file(
                    File(pickedFile!.path!),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: selectFile,
              child: Text("Select File"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: uploadFileToSupabase,
              child: Text("Upload File"),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/* import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ControllerUploadFile extends StatefulWidget {
  const ControllerUploadFile({super.key});

  @override
  State<ControllerUploadFile> createState() => _ControllerUploadFileState();
}

class _ControllerUploadFileState extends State<ControllerUploadFile> {
  PlatformFile? pickedFile;

Future uploadFile() async {
  final path ='assets/${pickedFile!.name}';
  final file =File(pickedFile!.path!);
  
  final ref=FirebaseStorage.instance.ref().child(path);
  ref.putFile(file);
  
}

Future selectFile() async {
  final result =await FilePicker.platform.pickFiles();
  if (result ==null ) return;

  setState(() {
    pickedFile =result.files.first;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child:Column(
        mainAxisAlignment:MainAxisAlignment.center,
      children:[
        if(pickedFile !=null)
        Expanded(child: Container(color: Colors.white,
        child: Image.file(File(pickedFile!.path!),width: double.infinity,fit: BoxFit.cover,)        )
        ),
        ElevatedButton(onPressed: selectFile, child: Text("select file")),
        SizedBox(height: 30,),

        ElevatedButton(onPressed: uploadFile, child: Text("upload file")),SizedBox(height: 30,)
    
      ],) ,
      )
    );
  }
}

 */