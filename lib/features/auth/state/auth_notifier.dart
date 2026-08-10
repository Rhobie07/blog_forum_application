import 'dart:async';

import 'package:biog_forum_application/features/auth/data/auth_repository.dart';
import 'package:biog_forum_application/features/auth/state/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._repository);

  final AuthRepository _repository;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  StreamSubscription<Session?>? _sessionSubscription;
  bool _started = false;
  bool _disposed = false;

  void start() {
    if (_started) return;
    _started = true;

    _applySession(_repository.currentSession);
    _sessionSubscription = _repository.sessionChanges.listen(
      _applySession,
      onError: _handleSessionError,
    );
  }

  Future<void> signIn(String email, String password) async {
    if (_state.loading) return;
    _setState(_state.copyWith(loading: true, clearError: true));

    try {
      final response = await _repository.signIn(
        email: email,
        password: password,
      );
      _setState(
        _state.copyWith(
          session: response.session,
          clearSession: response.session == null,
          loading: false,
          clearError: true,
          signUpInProgress: false,
        ),
      );
    } on AuthException catch (error) {
      _setState(
        _state.copyWith(
          loading: false,
          error: error.message,
          signUpInProgress: false,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          loading: false,
          error: 'Unable to sign in.',
          signUpInProgress: false,
        ),
      );
    }
  }

  Future<void> signUp(String email, String password) async {
    if (_state.loading) return;
    _setState(
      _state.copyWith(
        loading: true,
        clearError: true,
        emailConfirmationRequired: false,
        signUpInProgress: true,
      ),
    );

    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
      );
      _setState(
        _state.copyWith(
          session: response.session,
          clearSession: response.session == null,
          loading: false,
          clearError: true,
          emailConfirmationRequired: response.session == null,
          signUpInProgress: false,
        ),
      );
    } on AuthException catch (error) {
      _setState(
        _state.copyWith(
          loading: false,
          error: error.message,
          signUpInProgress: false,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          loading: false,
          error: 'Unable to register.',
          signUpInProgress: false,
        ),
      );
    }
  }

  Future<void> signOut() async {
    if (_state.loading) return;
    _setState(_state.copyWith(loading: true, clearError: true));

    try {
      await _repository.signOut();
      _setState(
        _state.copyWith(
          clearSession: true,
          loading: false,
          clearError: true,
          signUpInProgress: false,
        ),
      );
    } on AuthException catch (error) {
      _setState(
        _state.copyWith(
          loading: false,
          error: error.message,
          signUpInProgress: false,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          loading: false,
          error: 'Unable to sign out.',
          signUpInProgress: false,
        ),
      );
    }
  }

  void clearFeedback() {
    _setState(
      _state.copyWith(clearError: true, emailConfirmationRequired: false),
    );
  }

  void _applySession(Session? session) {
    if (_state.signUpInProgress && session != null) return;

    _setState(
      _state.copyWith(
        session: session,
        clearSession: session == null,
        loading: false,
        clearError: true,
      ),
    );
  }

  void _handleSessionError(Object error, StackTrace stackTrace) {
    _setState(
      _state.copyWith(
        loading: false,
        error: 'Unable to observe authentication state.',
        signUpInProgress: false,
      ),
    );
  }

  void _setState(AuthState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionSubscription?.cancel();
    super.dispose();
  }
}
