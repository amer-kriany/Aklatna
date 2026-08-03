part of 'business_bloc.dart';

sealed class BusinessState extends Equatable {
  const BusinessState();
  
  @override
  List<Object> get props => [];
}

final class BusinessInitial extends BusinessState {}
final class BusinessLoading extends BusinessState {}
final class BusinessFetched extends BusinessState {
  final List<BusinessEntity> businesses;
  const BusinessFetched({required this.businesses});
}
// NEW — single business, for BusinessDetailsPage
final class BusinessDetailLoaded extends BusinessState {
  final BusinessEntity business;
  const BusinessDetailLoaded({required this.business});

  @override
  List<Object> get props => [business];
}
final class BusinessError extends BusinessState {
  final String message;
  const BusinessError({required this.message});
}
final class BusinessUnfound extends BusinessState{
  
}

