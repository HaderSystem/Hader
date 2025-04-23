import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';


class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

 Future<void> _fetchUsers() async {
  final users = await SupabaseService.admin.auth.admin.listUsers();
  setState(() {
    _users = users;
  });
}


  Future<void> _deleteUser(String id) async {
    await _supabase.auth.admin.deleteUser(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("User deleted")));
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Users")),
      body: _users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (_, index) {
                final user = _users[index];
                final email = user.email ?? 'No Email';
                return ListTile(
                  title: Text(email),
                  subtitle: Text(user.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteUser(user.id),
                  ),
                );
              },
            ),
    );
  }
}
