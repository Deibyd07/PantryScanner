import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  const UpdatePasswordUseCase(this._repo);
  final AuthRepository _repo;

  Future<void> call(String currentPassword, String newPassword) =>
      _repo.updatePassword(currentPassword, newPassword);
}
