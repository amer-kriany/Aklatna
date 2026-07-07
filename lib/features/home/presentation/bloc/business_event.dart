part of 'business_bloc.dart';

sealed class BusinessEvent extends Equatable {
  const BusinessEvent();

  @override
  List<Object> get props => [];
}

class GetBusinesses extends BusinessEvent {}

class SearchBusinesses extends BusinessEvent {
  final String query;
 const SearchBusinesses({required this.query});
}
