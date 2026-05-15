/// Represents an authenticated user in the PantryScanner app.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.provider = AppAuthProvider.email,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final AppAuthProvider provider;

  /// Convenience getter: first letter of the display name or email.
  String get initials {
    final source = displayName ?? email;
    return source.isNotEmpty ? source[0].toUpperCase() : '?';
  }
}

/// Authentication provider used to sign in.
enum AppAuthProvider {
  email,
  google,
}

