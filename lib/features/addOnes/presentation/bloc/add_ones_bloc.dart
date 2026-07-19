import 'package:aklatna/features/addOnes/domain/enitity/addOnesEntity.dart';
import 'package:aklatna/features/addOnes/domain/useCases/getAddOnesUseCase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_ones_event.dart';
part 'add_ones_state.dart';

class AddonBloc extends Bloc<AddOnesEvent, AddOnesState> {
  final GetAddonsUsecase getAddonsUsecase;
  AddonBloc({required this.getAddonsUsecase}) : super(AddOnesInitial()) {
    on<GetAddonsEvent>(_onGetAddons);
  }

  Future<void> _onGetAddons(GetAddonsEvent event, Emitter<AddOnesState> emit) async {
    emit(AddonLoading());
    try {
      final addons = await getAddonsUsecase(event.itemId);
      emit(AddonLoaded(addons: addons));
    } catch (e) {
      emit(AddonError(message: e.toString()));
    }
  }
}
