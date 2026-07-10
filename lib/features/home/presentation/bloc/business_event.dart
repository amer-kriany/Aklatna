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
// NEW — fetches one business by id, for BusinessDetailsPage
final class GetBusinessById extends BusinessEvent {
  final String id;
  const GetBusinessById({required this.id});

  @override
  List<Object> get props => [id];
}
