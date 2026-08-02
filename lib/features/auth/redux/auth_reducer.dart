import 'package:redux/redux.dart';
import 'auth_actions.dart';
import 'auth_state.dart';

AuthState authReducer(
  AuthState state,
  dynamic action,
) => combineReducers<AuthState>([
  TypedReducer<AuthState, SignInRequested>(
    (s, _) => s.copyWith(loading: true, clearError: true),
  ).call,

  TypedReducer<AuthState, SignUpRequested>(
    (s, _) => s.copyWith(
      loading: true,
      clearError: true,
      emailConfirmationRequired: false,
      signUpInProgress: true,
    ),
  ).call,

  TypedReducer<AuthState, SignOutRequested>(
    (s, _) => s.copyWith(loading: true, clearError: true),
  ).call,

  TypedReducer<AuthState, AuthSessionChanged>(
    (s, a) => s.signUpInProgress && a.session != null
        ? s
        : s.copyWith(
            session: a.session,
            clearSession: a.session == null,
            loading: false,
            clearError: true,
          ),
  ).call,

  TypedReducer<AuthState, AuthSucceeded>(
    (s, a) => s.copyWith(
      session: a.session,
      clearSession: a.session == null,
      loading: false,
      clearError: true,
      signUpInProgress: false,
    ),
  ).call,

  TypedReducer<AuthState, AuthFailed>(
    (s, a) =>
        s.copyWith(loading: false, error: a.message, signUpInProgress: false),
  ).call,

  TypedReducer<AuthState, AuthStreamFailed>(
    (s, a) =>
        s.copyWith(loading: false, error: a.message, signUpInProgress: false),
  ).call,

  TypedReducer<AuthState, EmailConfirmationRequired>(
    (s, _) => s.copyWith(
      loading: false,
      clearError: true,
      emailConfirmationRequired: true,
      signUpInProgress: false,
    ),
  ).call,

  TypedReducer<AuthState, AuthFeedbackCleared>(
    (s, _) => s.copyWith(clearError: true, emailConfirmationRequired: false),
  ).call,
])(state, action);
