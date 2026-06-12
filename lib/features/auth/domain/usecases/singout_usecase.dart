import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';

class SingoutUsecase {
  final AuthRepositoryImpl repository;
  SingoutUsecase({required this.repository});
  Future<void> call() async {
    await repository.signOut();
  }
}