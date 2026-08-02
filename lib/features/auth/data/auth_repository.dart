import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthOperations {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class AuthRepository implements AuthOperations {
  final AuthOperations operations;

  AuthRepository(SupabaseClient client)
    : operations = _SupabaseAuthOperations(client);

  const AuthRepository.forTesting(this.operations);

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) => operations.signUp(email: email, password: password);

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) => operations.signIn(email: email, password: password);

  @override
  Future<void> signOut() => operations.signOut();
}

class _SupabaseAuthOperations implements AuthOperations {
  const _SupabaseAuthOperations(this.client);

  final SupabaseClient client;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) => client.auth.signUp(email: email, password: password);

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) => client.auth.signInWithPassword(email: email, password: password);

  @override
  Future<void> signOut() => client.auth.signOut();
}
