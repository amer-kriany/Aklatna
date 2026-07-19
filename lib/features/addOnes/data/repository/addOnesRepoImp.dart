import 'package:aklatna/features/addOnes/data/datasource/addOnesDataSource.dart';
import 'package:aklatna/features/addOnes/domain/enitity/addOnesEntity.dart';
import 'package:aklatna/features/addOnes/domain/repository/addOnesRepo.dart';

class AddonRepositoryImpl implements AddonRepository {
  final Addonesdatasource datasource;
  AddonRepositoryImpl({required this.datasource});

  @override
  Future<List<AddonEntity>> getAddonsForItem(String itemId) async {
    final models = await datasource.getAddonsForItem(itemId);
    return models.map((m) => m.toEntity()).toList();
  }
}