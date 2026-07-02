import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'promotions_event.dart';
part 'promotions_state.dart';

class PromotionsBloc extends Bloc<PromotionsEvent, PromotionsState> {
  PromotionsBloc() : super(PromotionsInitial()) {
    on<PromotionsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
