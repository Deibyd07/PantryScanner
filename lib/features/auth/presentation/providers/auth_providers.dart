import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/delete_account_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_with_email_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/update_display_name_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';

// ── Repository ───────────────────────────────────────────────────────────────

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// ── Auth state stream ────────────────────────────────────────────────────────

/// Core provider: emits the current user or `null` when signed out.
final StreamProvider<AppUser?> authStateProvider =
    StreamProvider<AppUser?>((ref) {
  final WatchAuthStateUseCase useCase = WatchAuthStateUseCase(
    ref.watch(authRepositoryProvider),
  );
  return useCase();
});

// ── Use-case providers ───────────────────────────────────────────────────────

final Provider<LoginWithEmailUseCase> loginWithEmailUseCaseProvider =
    Provider<LoginWithEmailUseCase>((ref) {
  return LoginWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final Provider<RegisterWithEmailUseCase> registerWithEmailUseCaseProvider =
    Provider<RegisterWithEmailUseCase>((ref) {
  return RegisterWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final Provider<LoginWithGoogleUseCase> loginWithGoogleUseCaseProvider =
    Provider<LoginWithGoogleUseCase>((ref) {
  return LoginWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final Provider<ResetPasswordUseCase> resetPasswordUseCaseProvider =
    Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final Provider<LogoutUseCase> logoutUseCaseProvider =
    Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final Provider<UpdateDisplayNameUseCase> updateDisplayNameUseCaseProvider =
    Provider<UpdateDisplayNameUseCase>((ref) {
  return UpdateDisplayNameUseCase(ref.watch(authRepositoryProvider));
});

final Provider<UpdatePasswordUseCase> updatePasswordUseCaseProvider =
    Provider<UpdatePasswordUseCase>((ref) {
  return UpdatePasswordUseCase(ref.watch(authRepositoryProvider));
});

final Provider<DeleteAccountUseCase> deleteAccountUseCaseProvider =
    Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.watch(authRepositoryProvider));
});

// ── UI state helpers ─────────────────────────────────────────────────────────

/// Global loading flag used by auth screens.
final StateProvider<bool> authLoadingProvider =
    StateProvider<bool>((ref) => false);
