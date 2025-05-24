import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/theme_provider.dart';

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

  void _toggleLanguage() {
    final currentLocale = context.locale;
    final newLocale =
        currentLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  void _login() async {
    final now = DateTime.now();

    if (_lockUntil != null && now.isBefore(_lockUntil!)) {
      final remaining = _lockUntil!.difference(now).inMinutes + 1;
      _showMessage(tr("account_locked", args: [remaining.toString()]));
      return;
    }

    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _failedAttempts = 0;
        _lockUntil = null;

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
        _handleFailedAttempt();
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains("invalid login credentials") ||
          e.message.toLowerCase().contains("email or password is incorrect")) {
        _handleFailedAttempt();
      } else {
        _showMessage(e.message);
      }
    } catch (_) {
      _showMessage(tr("something_went_wrong"));
    }

    setState(() => _loading = false);
  }

  void _handleFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= _maxAttempts) {
      _lockUntil = DateTime.now().add(const Duration(minutes: 10));
      _showMessage(tr("account_locked", args: ['10']));
    } else {
      final remaining = _maxAttempts - _failedAttempts;
      _showMessage(tr("wrong_email_or_password_attempt", args: [remaining.toString()]));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.language, color: colorScheme.onSurface.withOpacity(0.7)),
                        onPressed: _toggleLanguage,
                        tooltip: tr('change_language'),
                      ),
                      IconButton(
                        icon: Icon(Icons.brightness_6, color: colorScheme.onSurface.withOpacity(0.7)),
                        onPressed: () => ThemeManager.toggleTheme(),
                        tooltip: tr('dark_mode'),
                      ),
                    ],
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
                      color: colorScheme.primary,
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
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(tr('login_button')),
                ),
              ),
              const SizedBox(height: 16),
           /*    TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register-student'),
                child: Text(
                  tr('register_now'),
                  style: TextStyle(color: colorScheme.primary),
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}

// الكود قبل حظر المحاولات الفاشلة 


/* import 'package:flutter/material.dart';
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
    final newLocale =
        currentLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  void _login() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

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
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains("invalid login credentials") ||
          e.message.toLowerCase().contains("email or password is incorrect")) {
        _showMessage(tr("wrong_email_or_password"));
      } else {
        _showMessage(e.message);
      }
    } catch (e) {
      _showMessage(tr("something_went_wrong"));
    }

    setState(() => _loading = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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

 */

//الكود قبل ايرور هاندلغ



/* import 'package:flutter/material.dart';
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
 */
