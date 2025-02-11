class ModelStudent {
final String student_id;
final String FirstName;
final String LastName;
final String imageUrl;
//final String FaceRec;
//final String FingerRec;

  ModelStudent({required this.student_id, required this.FirstName, required this.LastName,  this.imageUrl='' /*  required this.FaceRec, required this.FingerRec */});




factory ModelStudent.fromMap(Map<String,dynamic> data,String documentId){
  return ModelStudent(student_id: documentId, FirstName: data['FirstName'], LastName: data ['LastName'],imageUrl:data['imageUrl']/* , FaceRec: data [''], FingerRec: data [''] */);
}


// تحويل Model إلى Map لتخزينه في Firebase
  Map<String, dynamic> toMap() {
    return {
      'FirstName': FirstName,
      'LastName': LastName,
      'student_id' :student_id,
      'imageUrl':imageUrl,
    };
  }
}