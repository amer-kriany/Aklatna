import 'package:aklatna/features/promotions/data/dataSource/promotionDataSource.dart';
import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/usecases/promotionsUseCase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'promotions_event.dart';
part 'promotions_state.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final GetPromotionsUseCase promotionsusecase;
  PromotionsBloc({required this.promotionsusecase})
    : super(PromotionsInitial()) {
    on<PromotionsEvent>(_getPromotions);
  }
  // get all promotions
  Future<void> _getPromotions(
  PromotionsEvent event,
  Emitter<PromotionsState> emit,
) async {
  print("Loading promotions...");

  emit(PromotionsLoading());

  try {
    final promotions = await promotionsusecase();

    print(promotions.length);

    emit(PromotionsLoaded(promotions: promotions));
  } catch (e) {
    print(e);

    emit(PromotionsError(message: e.toString()));
  }
}
}
