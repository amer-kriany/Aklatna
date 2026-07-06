part of 'business_bloc.dart';

sealed class BusinessEvent extends Equatable {
  const BusinessEvent();

  @override
  List<Object> get props => [];
}

class GetBusinesses extends BusinessEvent {
}
