import 'package:aklatna/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';

class CurrentuserUsecase {
  final AuthRepositoryImpl repository;
  CurrentuserUsecase({ required this.repository});
  Future<AppuserEntity> call() async {
    return await repository.getCurrentUser();
  }
}