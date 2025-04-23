/* import 'dart:math';

String generateRandomPassword(int length ) {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_-+=<>?';
  Random random = Random();
  
  String password = '';
  
  for (int i = 0; i < length; i++) {
    int index = random.nextInt(characters.length); // توليد رقم عشوائي من نطاق الحروف
    password += characters[index];
  }
  
  return password;
}
 */