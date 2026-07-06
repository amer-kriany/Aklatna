import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'business_event.dart';
part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
    final GetbusinessUsecase getBusinessUsecase;
  BusinessBloc( {required this.getBusinessUsecase}) : super(BusinessInitial()) {
    on<GetBusinesses>(_getBusinesses);
  }
   Future<void> _getBusinesses(
    GetBusinesses event,
    Emitter<BusinessState> emit
   ) async {
      print('🟡 getBusinesses started');

    emit(BusinessLoading());
    try {
      // call usecase to get business
      final businesses = await getBusinessUsecase();
          print('🟢 Fetched ${businesses.length} businesses');

      emit(BusinessFetched(businesses: businesses));
    } catch (e) {
          print('🔴 Error: $e');

      emit(BusinessError(message: e.toString()));
    }
  }
}
