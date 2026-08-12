import 'package:biog_forum_application/features/auth/screens/auth_screen.dart';
import 'package:biog_forum_application/features/auth/screens/registration_screen.dart';
import 'package:biog_forum_application/features/auth/state/auth_notifier.dart';
import 'package:biog_forum_application/features/blog_page/screens/blog_page.dart';
import 'package:biog_forum_application/features/blog_page/screens/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter(AuthNotifier authNotifier) {
    router = GoRouter(
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final signedIn = authNotifier.state.session != null;
        final location = state.matchedLocation;

        if (signedIn && (location == '/login' || location == '/register')) {
          return '/blogPage';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', redirect: (_, _) => '/blogPage'),
        GoRoute(path: '/login', builder: (_, _) => const AuthScreen()),
        GoRoute(
          path: '/register',
          builder: (_, _) => const RegistrationScreen(),
        ),
        GoRoute(path: '/blogPage', builder: (_, _) => const BlogPageScreen()),
        GoRoute(
          path: '/posts/:id',
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null || id <= 0) {
              return Scaffold(
                appBar: AppBar(title: const Text('Post')),
                body: const Center(child: Text('Post unavailable')),
              );
            }
            return PostDetailScreen(postId: id);
          },
        ),
      ],
      errorBuilder: (_, _) => Scaffold(
        appBar: AppBar(title: const Text('Not Found')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }

  late final GoRouter router;

  void dispose() => router.dispose();
}
