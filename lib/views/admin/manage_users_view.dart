import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/supabase_service.dart';

class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  final _supabase = Supabase.instance.client;
  List<User> _users = [];
  String _selectedRole = 'student';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await SupabaseService.admin.auth.admin.listUsers();
    final filtered = response.where((u) => u.userMetadata != null && u.userMetadata!['role'] == _selectedRole).toList();
    setState(() {
      _users = filtered;
    });
  }

  Future<void> _deleteUser(String id) async {
    await _supabase.auth.admin.deleteUser(id);
    await _supabase.from('student_courses').delete().eq('student_id', id);
    await _supabase.from('students').delete().eq('id', id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr("user_deleted"))));
    _fetchUsers();
  }

  void _showUserDetails(User user) async {
    final metadata = user.userMetadata ?? {};
    String? imageUrl;

    try {
      imageUrl = await _supabase.storage
          .from('faces')
          .createSignedUrl('${user.id}.jpg', 60);
    } catch (e) {
      print('No image found for user ${user.id}');
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(tr("user_details")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 40,
                  ),
                ),
              const SizedBox(height: 12),
              Text("${tr("university_id")}: ${metadata['student_id']?.toString() ?? tr("not_available")}"),
              Text("${tr("email")}: ${user.email ?? tr("not_available")}"),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(tr("close")))
          ],
        );
      },
    );
  }

  void _toggleLanguage() {
    final currentLocale = context.locale;
    final newLocale = currentLocale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    context.setLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("manage_users")),
        backgroundColor: const Color(0xFF002D62),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: tr("change_language"),
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(tr("students")),
                selected: _selectedRole == 'student',
                onSelected: (_) {
                  setState(() => _selectedRole = 'student');
                  _fetchUsers();
                },
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: Text(tr("teachers")),
                selected: _selectedRole == 'teacher',
                onSelected: (_) {
                  setState(() => _selectedRole = 'teacher');
                  _fetchUsers();
                },
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: _users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (_, index) {
                      final user = _users[index];
                      final universityId = user.userMetadata?['student_id']?.toString() ?? tr("no_id");

                      return ListTile(
                        title: Text(universityId),
                        subtitle: Text(user.email ?? tr("no_email")),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'view') {
                              _showUserDetails(user);
                            } else if (value == 'delete') {
                              _deleteUser(user.id);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Text(tr("view_details")),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(tr("delete_user")),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
