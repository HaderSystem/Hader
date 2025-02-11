/* import 'dart:ui';

import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:flutter_face_api/flutter_face_api.dart' as Regula;

class FaceRecognitionScreen extends StatefulWidget {
  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  Regula.MatchFacesResponse? response;

  void captureFace() async {
    Regula.FaceSDK.  presentFaceCaptureActivity().then((result) {
      var image = Regula.Image();
      image.bitmap = result['bitmap'];
      image.imageType = Regula.ImageType.LIVE;
      setState(() {
        response = Regula.MatchFacesResponse();
        response!.firstImage = image;
      });
    });
  }

  void matchFace() async {
    if (response == null || response!.firstImage == null) {
      print("التقط صورة أولا!");
      return;
    }
    
    var request = Regula.MatchFacesRequest();
    request.images = [response!.firstImage!, response!.firstImage!]; // مقارنة نفس الصورة
    
    Regula.FaceSDK.matchFaces(request).then((matchResult) {
      var similarity = matchResult['similarity'];
      print("التشابه: $similarity");
      if (similarity > 0.8) {
        print("✅ الوجه مطابق!");
      } else {
        print("❌ الوجه غير مطابق!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Face Recognition')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          response?.firstImage?.bitmap != null
              ? Image.memory(response!.firstImage!.bitmap!)
              : Icon(Icons.face, size: 100),
          SizedBox(height: 20),
          ElevatedButton(onPressed: captureFace, child: Text("التقاط الوجه")),
          ElevatedButton(onPressed: matchFace, child: Text("مطابقة الوجه")),
        ],
      ),
    );
  }
}
 */