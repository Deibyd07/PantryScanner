import '../entities/app_user.dart';

/// Contract for authentication operations.
abstract class AuthRepository {
  /// Emits the current user whenever auth state changes.
  /// Emits `null` when signed out.
  Stream<AppUser?> watchAuthState();

  /// Sign in with email and password.
  Future<AppUser> loginWithEmail(String email, String password);

  /// Create a new account with name, email and password.
  Future<AppUser> registerWithEmail(String name, String email, String password);

  /// Sign in with Google (OAuth 2.0).
  Future<AppUser> loginWithGoogle();

  /// Send a password-reset email.
  Future<void> resetPassword(String email);

  /// Sign out from all providers.
  Future<void> logout();
}
