import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

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

  /// Translates Firebase error codes into user-friendly Spanish messages.
  String _mapErrorCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'invalid-credential':
        return 'Las credenciales son inválidas. Verifica tu correo y contraseña.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      case 'operation-not-allowed':
        return 'Este método de autenticación no está habilitado.';
      default:
        return 'Error de autenticación. Intenta de nuevo.';
    }
  }

  // ── AuthRepository ────────────────────────────────────────────────────────

  @override
  Stream<AppUser?> watchAuthState() {
    return _auth.authStateChanges().map((User? user) {
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

      // Set the display name on the Firebase profile.
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
}

/// Domain-level authentication error with a user-facing message.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
