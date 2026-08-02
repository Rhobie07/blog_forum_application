import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  const AuthState({
    this.session,
    this.loading = false,
    this.error,
    this.emailConfirmationRequired = false,
    this.signUpInProgress = false,
  });

  final Session? session;
  final bool loading;
  final String? error;
  final bool emailConfirmationRequired;
  final bool signUpInProgress;

  AuthState copyWith({
    Session? session,
    bool? loading,
    String? error,
    bool? emailConfirmationRequired,
    bool? signUpInProgress,
    bool clearSession = false,
    bool clearError = false,
  }) => AuthState(
    session: clearSession ? null : session ?? this.session,
    loading: loading ?? this.loading,
    error: clearError ? null : error ?? this.error,
    emailConfirmationRequired:
        emailConfirmationRequired ?? this.emailConfirmationRequired,
    signUpInProgress: signUpInProgress ?? this.signUpInProgress,
  );
}
