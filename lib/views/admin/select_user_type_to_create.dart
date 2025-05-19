import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CreateUserTypeView extends StatelessWidget {
  const CreateUserTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr("select_user_type")),
        backgroundColor: const Color(0xFF002D62),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              final newLocale =
                  currentLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
              context.setLocale(newLocale);
            },
            tooltip: tr("change_language"),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/create-student'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: const Color(0xFF002D62),
                ),
                child: Text(tr("create_student_account"), style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/create-teacher'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: const Color(0xFF002D62),
                ),
                child: Text(tr("create_teacher_account"), style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
