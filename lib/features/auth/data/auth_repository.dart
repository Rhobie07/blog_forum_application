import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  Stream<Session?> get sessionChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session);

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) => _client.auth.signUp(email: email, password: password);

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) => _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signOut() => _client.auth.signOut();
}
