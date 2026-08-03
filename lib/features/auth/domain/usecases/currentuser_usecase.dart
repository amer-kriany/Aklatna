import 'package:aklatna/features/auth/domain/entities/appuser_entity.dart';
import 'package:aklatna/features/auth/domain/repositories/auth_repository.dart';

class CurrentuserUsecase {
  final AuthRepository repository;
  CurrentuserUsecase({ required this.repository});
  Future<AppuserEntity> call() async {
    return await repository.getCurrentUser();
  }
}