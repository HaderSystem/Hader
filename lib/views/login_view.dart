import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  final _supabase = Supabase.instance.client;

  void _login() async {
    setState(() {
      _loading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null) {
      // Success: Navigate to home
final user = Supabase.instance.client.auth.currentUser;
final role = user?.userMetadata?['role'];

if (role == 'student') {
  Navigator.pushReplacementNamed(context, '/student');
} else if (role == 'teacher') {
  Navigator.pushReplacementNamed(context, '/teacher');
} else if (role == 'admin') {
  Navigator.pushReplacementNamed(context, '/admin');
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("لم يتم التعرف على نوع الحساب")),
  );
}



    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed")),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  ),
                  TextButton(
  onPressed: () {
    Navigator.pushNamed(context, '/register-student');
  },
  child: const Text("طالب جديد؟ أنشئ حساب الآن"),
),

          ],
        ),
      ),
      
    );
  }
}
