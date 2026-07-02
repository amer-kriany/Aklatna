import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/usecases/promotionsUseCase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'promotions_event.dart';
part 'promotions_state.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final Promotionsusecase promotionsusecase;
  PromotionsBloc({required this.promotionsusecase})
    : super(PromotionsInitial()) {
    on<PromotionsEvent>(_getAllPromotions);
  }
  // get all promotions
  Future<void> _getAllPromotions(
    PromotionsEvent event,
    Emitter<PromotionsState> emit,
  ) async {
    try {
      emit(PromotionsLoading());
      final promotions = await promotionsusecase();
      emit(PromotionsLoaded(promotions: promotions));
    } catch (e) {
      emit(PromotionsError(message: e.toString()));
    }
  }
}
