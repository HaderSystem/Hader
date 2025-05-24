import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      _showMessage("كلمة المرور الجديدة غير متطابقة");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        _showMessage("تم تغيير كلمة المرور بنجاح");
        Navigator.pop(context);
      } else {
        _showMessage("حدث خطأ أثناء تغيير كلمة المرور");
      }
    } catch (e) {
      _showMessage("خطأ: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تغيير كلمة المرور")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور الحالية'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'أدخل كلمة المرور الحالية' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'يجب أن تكون 6 أحرف على الأقل' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'تأكيد كلمة المرور الجديدة'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'أدخل تأكيد كلمة المرور' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("حفظ"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
