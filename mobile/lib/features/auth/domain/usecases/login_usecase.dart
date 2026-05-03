import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Delegates login to [AuthRepository]; exists to keep BLoC dependency-free from data layer.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
