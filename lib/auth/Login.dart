import 'package:flutter/material.dart';
import 'package:flutter_application_2/auth/auth_service.dart';
import 'package:flutter_application_2/views/v_admin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

//get auth service
final authService =AuthService();

//text controllers
final _idController =TextEditingController();
final _passwordController =TextEditingController();

//login button pressed 
void login() async{
  //prepre data 
  final userId= _idController.text;
  final password = _passwordController.text;

  //attempt login ..
  try {
await authService.signInWithidPassword(userId, password);
  }catch(e){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Error: $e')));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          //id 
          TextField(controller: _idController,
          decoration: InputDecoration(labelText: "ID"),),

          //password
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: "Password"),
          ),

          //button 
          ElevatedButton(onPressed: () {
          //  if(login()==1)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewAdmin()),
                );
              },/* login */ child: const Text("Login")),

          //go to previous page 
          
        ],
      ),
    );
  }
}