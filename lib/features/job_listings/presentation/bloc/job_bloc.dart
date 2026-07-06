import 'package:aklatna/features/job_listings/domain/entities/jobEntity.dart';
import 'package:aklatna/features/job_listings/domain/usecases/get_jobs_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final GetJobsUsecase getJobsUsecase;

  JobBloc({required this.getJobsUsecase}) : super(JobInitial()) {
    on<GetJobsEvent>(_getAllJobs);
  }
  // get all jobs
  Future<void> _getAllJobs(GetJobsEvent event, Emitter<JobState> emit) async {
    try {
      emit(JobLoading());
      final jobs = await getJobsUsecase();
      emit(JobLoaded(jobs: jobs));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }
}
