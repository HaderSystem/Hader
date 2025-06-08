//this page to give adimn choose the type of account he will create for users
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateUserTypeView extends StatelessWidget {
  const CreateUserTypeView({super.key});

  @override
  Widget build(BuildContext context) {
            final colorScheme = Theme.of(context).colorScheme;

        final theme = Theme.of(context);

    final currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("select_user_type"),
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              final newLocale = currentLocale.languageCode == 'ar'
                  ? const Locale('en')
                  : const Locale('ar');
              context.setLocale(newLocale);
            },
            tooltip: tr("change_language"),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUserTypeCard(
                context,
                icon: Icons.school,
                label: tr("create_student_account"),
                onTap: () => Navigator.pushNamed(context, '/create-student'),
              ),
              SizedBox(height: 24.h),
              _buildUserTypeCard(
                context,
                icon: Icons.person,
                label: tr("create_teacher_account"),
                onTap: () => Navigator.pushNamed(context, '/create-teacher'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32.sp, color: const Color(0xFF002D62)),
              SizedBox(width: 16.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002D62),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

