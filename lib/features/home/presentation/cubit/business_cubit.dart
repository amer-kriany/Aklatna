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
