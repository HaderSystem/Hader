import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import 'ForgotPasswordView.dart';
import 'dart:io';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

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
      final message = e.message.toLowerCase();
      if (message.contains("invalid login credentials") ||
          message.contains("email or password is incorrect")) {
        _handleFailedAttempt();
      } else if (message.contains("email not confirmed")) {
        _showMessage(tr("email_not_confirmed"));
      } else if (message.contains("invalid email")) {
        _showMessage(tr("invalid_email_format"));
      } else {
        _showMessage(tr("something_went_wrong"));
      }
    } on SocketException {
      _showMessage(tr("no_internet"));
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
    if (remaining > 0) {
      _showMessage(tr("wrong_email_or_password_attempt", args: [remaining.toString()]));
    }
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('login'),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              fontSize: 26.sp,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.language,
                                    color: colorScheme.onSurface.withOpacity(0.7)),
                                onPressed: _toggleLanguage,
                                tooltip: tr('change_language'),
                              ),
                              IconButton(
                                icon: Icon(Icons.brightness_6,
                                    color: colorScheme.onSurface.withOpacity(0.7)),
                                onPressed: () => ThemeManager.toggleTheme(),
                                tooltip: tr('dark_mode'),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Center(
                        child: Image.asset(
                          'lib/assets/images/small_logo.png',
                          height: 150.h,
                          width: 150.w,
                        ),
                      ),
                      SizedBox(height: 40.h),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: tr('email'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 20.h),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: tr('password'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: colorScheme.primary,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            textStyle: TextStyle(fontSize: 18.sp),
                          ),
                          child: _loading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  tr('login_button'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordView()),
                          );
                        },
                        child: Text(tr('forget_password')),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

