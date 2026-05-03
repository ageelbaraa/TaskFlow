import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Delegates registration to [AuthRepository]; keeps BLoC free from data-layer types.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
  }) =>
      _repository.register(name: name, email: email, password: password);
}
