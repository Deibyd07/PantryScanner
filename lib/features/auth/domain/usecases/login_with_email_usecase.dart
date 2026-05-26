import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  const LoginWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  Future<AppUser> call(String email, String password) {
    return _repository.loginWithEmail(email, password);
  }
}
