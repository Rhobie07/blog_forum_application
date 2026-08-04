import 'package:biog_forum_application/features/auth/redux/auth_state.dart';
import 'package:biog_forum_application/features/blog_page/redux/blog_state.dart';

class AppState {
  const AppState({required this.auth, required this.blog});
  final AuthState auth;
  final BlogState blog;

  factory AppState.initial() =>
      AppState(auth: const AuthState(), blog: BlogState());
}
