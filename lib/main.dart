import 'dart:async';
import 'package:biog_forum_application/config/env/env.dart';
import 'package:biog_forum_application/config/theme/theme.dart';
import 'package:biog_forum_application/core/redux/app_state.dart';
import 'package:biog_forum_application/core/router/router.dart';
import 'package:biog_forum_application/features/auth/data/auth_repository.dart';
import 'package:biog_forum_application/features/auth/redux/auth_actions.dart';
import 'package:biog_forum_application/features/auth/redux/auth_middleware.dart';
import 'package:biog_forum_application/features/auth/redux/auth_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
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
  final store = Store<AppState>(
    _appReducer,
    initialState: AppState.initial(),
    middleware: [createAuthMiddleware(AuthRepository(client))],
  );
  final router = AppRouter(store);

  runApp(_BlogForumApp(store: store, router: router));
}

AppState _appReducer(AppState state, dynamic action) =>
    AppState(auth: authReducer(state.auth, action));

class _BlogForumApp extends StatefulWidget {
  const _BlogForumApp({required this.store, required this.router});
  final Store<AppState> store;
  final AppRouter router;

  @override
  State<_BlogForumApp> createState() => _BlogForumAppState();
}

class _BlogForumAppState extends State<_BlogForumApp> {
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    widget.store.dispatch(AuthSessionChanged(auth.currentSession));
    _authSub = auth.onAuthStateChange.listen(
      (event) => widget.store.dispatch(AuthSessionChanged(event.session)),
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    widget.router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StoreProvider<AppState>(
    store: widget.store,
    child: MaterialApp.router(
      title: 'Blog Forum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: widget.router.router,
    ),
  );
}
