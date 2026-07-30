import 'package:biog_forum_application/features/auth/screens/auth_screen.dart';
import 'package:biog_forum_application/features/auth/screens/registration_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      routes: [
        GoRoute(path: '/login', builder: (_, _) => const AuthScreen()),
        GoRoute(
          path: '/register',
          builder: (_, _) => const RegistrationScreen(),
        ),
      ],
    );
  }
}
