import 'package:aklatna/features/addOnes/domain/enitity/addOnesEntity.dart';

abstract class AddonRepository {
  Future<List<AddonEntity>> getAddonsForItem(String itemId);
}