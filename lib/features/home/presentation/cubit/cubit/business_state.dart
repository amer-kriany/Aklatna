part of 'business_cubit.dart';

sealed class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object> get props => [];
}

final class BusinessInitial extends BusinessState {}
final class BusinessLoading extends BusinessState {}
final class BusinessFetched extends BusinessState {
  final BusinessEntity business;
  const BusinessFetched({required this.business});
}
final class BusinessError extends BusinessState {
  final String message;
  const BusinessError({required this.message});
}
