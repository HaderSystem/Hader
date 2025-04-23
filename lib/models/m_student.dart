/* class ModelStudent {
 int? studentid;
final String firstname;
final String lastname;
final String imageURL;
final String email;
final String? password;
//final String FaceRec;
//final String FingerRec;

  ModelStudent({ this.studentid, required this.firstname, required this.lastname,  this.imageURL='',required this.email,this.password /*  required this.FaceRec, required this.FingerRec */});




factory ModelStudent.fromMap(Map<String,dynamic> map){
  return ModelStudent (
    studentid: map['studentid'] as int ,
     firstname: map['firstname'],
      lastname: map ['lastname'],
      imageURL:map['imageURL'],
      email: map['email'],
    //  password: map['password']
      /* ,
       FaceRec: data [''],
       FingerRec: data [''] */);
}


// تحويل Model إلى Map لتخزينه في Firebase
  Map<String, dynamic> toMap() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email' :email,
      'password':password,
      
    //  'studentid' :studentid,
      //'imageURL':imageURL,
    };
  }
} */