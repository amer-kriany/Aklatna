import 'package:aklatna/features/promotions/domain/entities/promotionEntity.dart';
import 'package:aklatna/features/promotions/domain/usecases/GetPromotionsMapUseCase.dart';
import 'package:aklatna/features/promotions/domain/usecases/promotionsUseCase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'promotions_event.dart';
part 'promotions_state.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  final GetPromotionsUseCase promotionsUseCase;
  final GetPromotionsMapUseCase getPromotionsMapUseCase;

  PromotionsBloc({
    required this.promotionsUseCase, required this.getPromotionsMapUseCase,
  }) : super(PromotionsInitial()) {
    on<LoadPromotionsEvent>(_getPromotions);
    on<LoadPromotionsMapEvent>(_getPromotionsMap);
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
  Future<void> _getPromotionsMap(
  LoadPromotionsMapEvent event,
  Emitter<PromotionsState> emit,
) async {
  emit(PromotionsLoading());
  try {
    final map = await getPromotionsMapUseCase(event.businessId);
    emit(PromotionsMapLoaded(promotionsMap: map));
  } catch (e) {
    emit(PromotionsError(message: e.toString()));
  }
}
}