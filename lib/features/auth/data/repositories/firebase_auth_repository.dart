import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../features/settings/domain/entities/app_language.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    AppLanguage lang = AppLanguage.spanish,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _lang = lang;

  final AppLanguage _lang;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // ── Helpers ───────────────────────────────────────────────────────────────

  AppUser _mapUser(User user) {
    final bool isGoogle = user.providerData.any(
      (UserInfo info) => info.providerId == 'google.com',
    );

    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      provider: isGoogle ? AppAuthProvider.google : AppAuthProvider.email,
    );
  }

  /// Translates Firebase error codes into user-friendly messages
  /// in the currently selected app language.
  String _mapErrorCode(String code) {
    final bool isEn = _lang == AppLanguage.english;
    switch (code) {
      case 'user-not-found':
        return isEn
            ? 'No account found with this email address.'
            : 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return isEn ? 'Incorrect password.' : 'La contraseña es incorrecta.';
      case 'invalid-credential':
        return isEn
            ? 'Invalid credentials. Please check your email and password.'
            : 'Las credenciales son inválidas. Verifica tu correo y contraseña.';
      case 'email-already-in-use':
        return isEn
            ? 'An account with this email already exists.'
            : 'Ya existe una cuenta con este correo electrónico.';
      case 'weak-password':
        return isEn
            ? 'The password is too weak.'
            : 'La contraseña es demasiado débil.';
      case 'invalid-email':
        return isEn
            ? 'Invalid email address format.'
            : 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return isEn
            ? 'This account has been disabled.'
            : 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return isEn
            ? 'Too many failed attempts. Please try again later.'
            : 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'network-request-failed':
        return isEn
            ? 'Connection error. Please check your internet.'
            : 'Error de conexión. Verifica tu internet.';
      case 'operation-not-allowed':
        return isEn
            ? 'This authentication method is not enabled.'
            : 'Este método de autenticación no está habilitado.';
      case 'requires-recent-login':
        return isEn
            ? 'For security, please sign in again before continuing.'
            : 'Por seguridad, vuelve a iniciar sesión antes de continuar.';
      default:
        return isEn
            ? 'Authentication error. Please try again.'
            : 'Error de autenticación. Intenta de nuevo.';
    }
  }

  // ── AuthRepository ────────────────────────────────────────────────────────

  @override
  Stream<AppUser?> watchAuthState() {
    // userChanges() also fires when displayName / photoURL are updated,
    // which lets the profile screen react to name edits immediately.
    return _auth.userChanges().map((User? user) {
      return user != null ? _mapUser(user) : null;
    });
  }

  @override
  Future<AppUser> loginWithEmail(String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorCode(e.code));
    }
  }

  @override
  Future<AppUser> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user!.updateDisplayName(name.trim());
      await credential.user!.reload();

      final User updatedUser = _auth.currentUser!;
      return _mapUser(updatedUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorCode(e.code));
    }
  }

  @override
  Future<AppUser> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException('Se canceló el inicio de sesión con Google.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return _mapUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorCode(e.code));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Error al iniciar sesión con Google: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorCode(e.code));
    }
  }

  @override
  Future<void> logout() async {
    await Future.wait(<Future<void>>[
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> updateDisplayName(String name) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw const AuthException('No hay sesión activa.');
      await user.updateDisplayName(name.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorCode(e.code));
    }
  }

  @override
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw const AuthException('No hay sesión activa.');

      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorCode(e.code));
    }
  }

  @override
  Future<void> deleteAccount({String? currentPassword}) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw const AuthException('No hay sesión activa.');

      final bool isGoogle = user.providerData.any(
        (UserInfo info) => info.providerId == 'google.com',
      );

      if (isGoogle) {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw const AuthException(
              'Se canceló la verificación con Google.');
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final OAuthCredential cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(cred);
      } else {
        if (currentPassword == null || currentPassword.isEmpty) {
          throw const AuthException('Se requiere la contraseña actual.');
        }
        final AuthCredential cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);
      }

      await user.delete();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapErrorCode(e.code));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Error al eliminar la cuenta: $e');
    }
  }
}

/// Domain-level authentication error with a user-facing message.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
