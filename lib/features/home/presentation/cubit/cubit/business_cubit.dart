import 'package:aklatna/features/home/domain/entity/businessEntity.dart';
import 'package:aklatna/features/home/domain/usecases/getbusiness_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'business_state.dart';

class BusinessCubit extends Cubit<BusinessState> {
  final GetbusinessUsecase getBusinessUsecase;
  BusinessCubit(this.getBusinessUsecase) : super(BusinessInitial());

  // get business from supa
  Future<void> getBusinesses() async {
    emit(BusinessLoading());
    try {
      // call usecase to get business
      final business = await getBusinessUsecase();
      emit(BusinessFetched(business: business));
    } catch (e) {
      emit(BusinessError(message: e.toString()));
    }
  }

}
