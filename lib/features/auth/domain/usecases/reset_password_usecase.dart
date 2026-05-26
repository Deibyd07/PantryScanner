import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call(String email) {
    return _repository.resetPassword(email);
  }
}
