import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:aklatna/features/home/domain/usecases/searchBusinessesUseCase.dart'
    show Searchbusinessesusecase;

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
    on<GetBusinessById>(_getBusinessById);
  }
  Future<void> _getBusinesses(
    GetBusinesses event,
    Emitter<BusinessState> emit,
  ) async {

    emit(BusinessLoading());
    try {
      // call usecase to get business
      final businesses = await getBusinessUsecase();

      emit(BusinessFetched(businesses: businesses));
    } catch (e) {

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

  Future<void> _getBusinessById(
    GetBusinessById event,
    Emitter<BusinessState> emit,
  ) async {
    emit(BusinessLoading());
    try {
      final businesses = await getBusinessUsecase();
      final business = businesses.where((b) => b.id == event.id).firstOrNull;
      if (business == null) {
        throw Exception('Business with id ${event.id} not found');
      }
      emit(BusinessDetailLoaded(business: business));
    } catch (e) {
      emit(BusinessError(message: e.toString()));
    }
  }
}
