import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class LoginWithGoogleUseCase {
  const LoginWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  Future<AppUser> call() {
    return _repository.loginWithGoogle();
  }
}
