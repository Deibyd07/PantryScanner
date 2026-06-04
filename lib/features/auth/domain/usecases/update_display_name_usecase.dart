import '../repositories/auth_repository.dart';

class UpdateDisplayNameUseCase {
  const UpdateDisplayNameUseCase(this._repo);
  final AuthRepository _repo;

  Future<void> call(String name) => _repo.updateDisplayName(name);
}
