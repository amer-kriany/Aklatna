import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class SingoutUsecase {
  final AuthRepository repository;
  SingoutUsecase({required this.repository});
  Future<void> call() async {
    await repository.signOut();
  }
}