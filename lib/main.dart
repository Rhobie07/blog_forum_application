import 'package:biog_forum_application/config/env/env.dart';
import 'package:biog_forum_application/config/theme/theme.dart';
import 'package:biog_forum_application/core/router/router.dart';
import 'package:biog_forum_application/features/auth/data/auth_repository.dart';
import 'package:biog_forum_application/features/auth/state/auth_notifier.dart';
import 'package:biog_forum_application/features/blog_page/data/blog_repository.dart';
import 'package:biog_forum_application/features/blog_page/state/blog_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: Environment.fileName);

  final url = Environment.supabaseUrl;
  final key = Environment.supabaseKey;
  if (url.isEmpty || key.isEmpty) {
    throw StateError('Missing Supabase configuration.');
  }

  await Supabase.initialize(url: url, publishableKey: key);
  final client = Supabase.instance.client;

  runApp(_BlogForumApp(client: client));
}

class _BlogForumApp extends StatefulWidget {
  const _BlogForumApp({required this.client});

  final SupabaseClient client;

  @override
  State<_BlogForumApp> createState() => _BlogForumAppState();
}

class _BlogForumAppState extends State<_BlogForumApp> {
  late final AuthNotifier _authNotifier;
  late final AppRouter _router;

  AuthRepository get authRepository => AuthRepository(widget.client);
  BlogRepository get blogRepository => BlogRepository(widget.client);

  @override
  void initState() {
    super.initState();
    _authNotifier = AuthNotifier(authRepository)..start();
    _router = AppRouter(_authNotifier);
  }

  @override
  void dispose() {
    _router.dispose();
    _authNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthNotifier>.value(value: _authNotifier),
      ChangeNotifierProvider<BlogNotifier>(
        create: (_) => BlogNotifier(blogRepository),
      ),
    ],
    child: MaterialApp.router(
      title: 'Blog Forum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router.router,
    ),
  );
}
