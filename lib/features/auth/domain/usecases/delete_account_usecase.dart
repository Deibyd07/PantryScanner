import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repo);
  final AuthRepository _repo;

  Future<void> call({String? currentPassword}) =>
      _repo.deleteAccount(currentPassword: currentPassword);
}
