import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:aklatna/features/home/domain/usecases/searchBusinessesUseCase.dart'
    show Searchbusinessesusecase;
import 'package:aklatna/features/home/presentation/widgets/search/recentKeyword.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'business_event.dart';
part 'business_state.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  final GetbusinessUsecase getBusinessUsecase;
  final Searchbusinessesusecase searchbusinessesusecase;
  BusinessBloc({
    required this.getBusinessUsecase,
    required this.searchbusinessesusecase,
  }) : super(BusinessInitial()) {
    on<GetBusinesses>(_getBusinesses);
    on<SearchBusinesses>(_searchBusinesses);
  }
  Future<void> _getBusinesses(
    GetBusinesses event,
    Emitter<BusinessState> emit,
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

  // search businesses
  Future<void> _searchBusinesses(
    SearchBusinesses event,
    Emitter<BusinessState> emit,
  ) async {
    try {
      emit(BusinessLoading());
      final response = await searchbusinessesusecase(query: event.query);
      if (response.isNotEmpty) {
        
        emit(BusinessFetched(businesses: response));
      } else {
        emit(BusinessUnfound());
      }
    } catch (e) {
      emit(BusinessError(message: e.toString()));
    }
  }
}
