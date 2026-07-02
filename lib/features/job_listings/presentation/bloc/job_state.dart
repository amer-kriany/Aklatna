part of 'job_bloc.dart';

sealed class JobState extends Equatable {
  const JobState();
  
  @override
  List<Object> get props => [];
}

final class JobInitial extends JobState {}
