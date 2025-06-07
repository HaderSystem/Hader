import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              final newLocale = currentLocale.languageCode == 'ar'
                  ? const Locale('en')
                  : const Locale('ar');
              context.setLocale(newLocale);
            },
            tooltip: tr("change_language"),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
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
        },
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


/* import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildUserTypeCard(
                context,
                icon: Icons.school,
                label: tr("create_student_account"),
                onTap: () => Navigator.pushNamed(context, '/create-student'),
              ),
              const SizedBox(height: 24),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF002D62)),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002D62),
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