import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  final _supabase = Supabase.instance.client;

  void _toggleLanguage() {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  void _login() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final response = await _supabase.auth.signInWithPassword(email: email, password: password);

    if (response.session != null) {
      final role = response.user?.userMetadata?['role'];
      if (role == 'student') {
        Navigator.pushReplacementNamed(context, '/student');
      } else if (role == 'teacher') {
        Navigator.pushReplacementNamed(context, '/teacher');
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        _showMessage(tr("unknown_role"));
      }
    } else {
      _showMessage(tr("login_failed"));
    }

    setState(() => _loading = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    print('📁 Localized string: ' + tr('login'));

    return Scaffold(
      
      backgroundColor: const Color(0xFFE9EDF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('login'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002D62),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.language, color: Colors.grey[700]),
                    onPressed: _toggleLanguage,
                    tooltip: tr('change_language'),
                  )
                ],
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: tr('email'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: tr('password'),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF002D62),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002D62),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(tr('login_button')),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register-student'),
                child: Text(
                  tr('register_now'),
                  style: const TextStyle(color: Color(0xFF002D62)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/* import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool _loading = false;
  final _supabase = Supabase.instance.client;



int _failedAttempts = 0;
final int _maxAttempts = 5;
DateTime? _lockUntil;


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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed")),
      );
    }

    setState(() {
      _loading = false;
    });
  }

 


 // بلوك بعد محاولات عديدة
/* 
void _login() async {
  final now = DateTime.now();

  // تحقق من القفل المؤقت
  if (_lockUntil != null && now.isBefore(_lockUntil!)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم قفل الحساب مؤقتًا. حاول بعد ${_lockUntil!.difference(now).inMinutes} دقيقة.')),
    );
    return;
  }

  setState(() {
    _loading = true;
  });

  final email = _emailController.text.trim();
  final password = _passwordController.text;

  try {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null) {
      _failedAttempts = 0; // إعادة المحاولات الناجحة للصفر

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
      _failedAttempts++;
      if (_failedAttempts >= _maxAttempts) {
        _lockUntil = now.add(Duration(minutes: 10));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم قفل الحساب لمدة 10 دقائق بسبب محاولات خاطئة متكررة.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل الدخول. المحاولة $_failedAttempts من $_maxAttempts")),
        );
      }
    }
  } catch (e) {
    _failedAttempts++;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("خطأ أثناء محاولة الدخول: $e")),
    );
  }

  setState(() {
    _loading = false;
  });
}

 */


  // ✅ إنشاء المستخدم في حالة عدم وجوده
  Future<void> simulateSignUpIfNeeded(String email, String password) async {
    try {
      await Supabase.instance.client.auth.signUp(email: email, password: password);
      print('$email created');
    } catch (e) {
      print('$email may already exist or failed: $e');
    }
  }



// DEBUG ONLY: Load test 10 fake users to simulate login pressure

  // ✅ اختبار تحميل وهمي
  void simulateLoadTest() async {
    for (int i = 0; i < 10; i++) {
      final email = 'test$i@example.com';
      final password = 'password123';

      await simulateSignUpIfNeeded(email, password);
      await Future.delayed(Duration(seconds: 1));

      try {
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        print("User $i: ${response.session != null ? 'Success' : 'Failed'}");
      } catch (e) {
        print("User $i: Error - $e");
      }
    }
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
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              obscureText: _obscurePassword,
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



// This button is for development/debug purposes only.
// It simulates multiple login attempts to test system load.

            if (kDebugMode)
              ElevatedButton(
                onPressed: simulateLoadTest,
                child: const Text("Load Test (Debug Only)"),
              ),
          ],
        ),
      ),
    );
  }
}
 */