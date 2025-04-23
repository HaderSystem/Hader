import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // client عادي للمستخدم المسجّل (طالب، معلم، أدمن)
  static final client = Supabase.instance.client;

  // admin client بصلاحيات كاملة باستخدام service_role
  static final admin = SupabaseClient(
    'https://gnorslgqghumwmgoqwhk.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdub3JzbGdxZ2h1bXdtZ29xd2hrIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NTIzMDUzNSwiZXhwIjoyMDYwODA2NTM1fQ.ybht5pNxY4QC4dHMGGOD-Rj66LATISW5N9DiHMNLeIs',
  );
}
