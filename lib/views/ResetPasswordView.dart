import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _updatePassword() async {
    setState(() => _loading = true);
    final newPassword = _passwordController.text.trim();

    try {
      final res = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (res.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('reset_success'.tr())),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('reset_failed'.tr())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('reset_failed'.tr())),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('reset_password_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'new_password'.tr()),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _updatePassword,
              child: Text(_loading ? 'updating'.tr() : 'update_password'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
