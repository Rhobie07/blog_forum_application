import 'package:biog_forum_application/features/auth/redux/auth_state.dart';

class AppState {
  const AppState({required this.auth});
  final AuthState auth;

  factory AppState.initial() => AppState(auth: const AuthState());
}
