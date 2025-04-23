/* 
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
final SupabaseClient _supabase =Supabase.instance.client;


//sign in 
Future<AuthResponse> signInWithidPassword (
  String userId, String password) async {
    return await _supabase.auth.signInWithPassword(
      email:"$userId@somedomain.com",
    password: password);
  }


//sign up 
Future<AuthResponse> signUpWithidPassword (
  String userId, String password) async {
    return await _supabase.auth.signUp(
      email:"$userId@somedomain.com",
    password: password, 
    data:{'studentid':userId});// ضفتها من تشات لما طلبت اوازن بين جدول الاوث وبين الداتا بيس
  }

//sign out 
Future <void> signOut() async {
  await _supabase.auth.signOut();
}

  // Get user 
  String? getCurrentUserid(){
    final session = _supabase.auth.currentSession;
    final user =session?.user;
    return user?.email;

  }


} */