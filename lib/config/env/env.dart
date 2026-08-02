import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get fileName => '.env.prod';
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'SUPABASE_URL_NOT_FOUND';
  static String get supabaseKey =>
      dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
      'SUPABASE_PUBLISHABLE_KEY_NOT_FOUND';
}
