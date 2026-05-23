import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  const RegisterWithEmailUseCase(this._repository);
  final AuthRepository _repository;

  Future<AppUser> call(String name, String email, String password) {
    return _repository.registerWithEmail(name, email, password);
  }
}
