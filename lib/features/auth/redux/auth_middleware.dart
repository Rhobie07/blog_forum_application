import 'package:biog_forum_application/core/redux/app_state.dart';
import 'package:biog_forum_application/features/auth/data/auth_repository.dart';
import 'package:redux/redux.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_actions.dart';

Middleware<AppState> createAuthMiddleware(AuthRepository repository) =>
    (store, action, next) {
      next(action);
      if (action is SignInRequested) {
        return _signIn(store, repository, action);
      } else if (action is SignUpRequested) {
        return _signUp(store, repository, action);
      } else if (action is SignOutRequested) {
        return _signOut(store, repository);
      }
    };

Future<void> _signIn(
  Store<AppState> store,
  AuthRepository repository,
  SignInRequested action,
) async {
  try {
    
    final response = await repository.signIn(
      email: action.email,
      password: action.password,
    );

    
    store.dispatch(AuthSucceeded(response.session));
  } on AuthException catch (error) {
    store.dispatch(AuthFailed(error.message));
  } catch (_) {
    store.dispatch(const AuthFailed('Unable to sign in.'));
  }
}

Future<void> _signUp(
  Store<AppState> store,
  AuthRepository repository,
  SignUpRequested action,
) async {
  try {
    final response = await repository.signUp(
      email: action.email,
      password: action.password,
    );
    if (response.session != null) {
      await repository.signOut();
    }
    store.dispatch(const EmailConfirmationRequired());
  } on AuthException catch (error) {
    store.dispatch(AuthFailed(error.message));
  } catch (_) {
    store.dispatch(const AuthFailed('Unable to register.'));
  }
}

Future<void> _signOut(Store<AppState> store, AuthRepository repository) async {
  try {
    await repository.signOut();
    store.dispatch(const AuthSucceeded(null));
  } on AuthException catch (error) {
    store.dispatch(AuthFailed(error.message));
  } catch (_) {
    store.dispatch(const AuthFailed('Unable to sign out.'));
  }
}
