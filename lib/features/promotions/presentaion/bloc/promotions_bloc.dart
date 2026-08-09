import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/usecases/promotionsUseCase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'promotions_event.dart';
part 'promotions_state.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final GetPromotionsUseCase promotionsUseCase;

  PromotionsBloc({
    required this.promotionsUseCase,
  }) : super(PromotionsInitial()) {
    on<LoadPromotionsEvent>(_getPromotions);
  }

  Future<void> _getPromotions(
    LoadPromotionsEvent event,
    Emitter<PromotionsState> emit,
  ) async {
    emit(PromotionsLoading());

    try {
      final promotions = await promotionsUseCase();

      emit(
        PromotionsLoaded(
          promotions: promotions,
        ),
      );
    } catch (e) {
      emit(
        PromotionsError(
          message: e.toString(),
        ),
      );
    }
  }
}