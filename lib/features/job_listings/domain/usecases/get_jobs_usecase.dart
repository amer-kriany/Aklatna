import 'package:aklatna/features/job_listings/domain/entities/jobEntity.dart';
import 'package:aklatna/features/job_listings/domain/repository/jobRepo.dart';

class GetJobsUsecase {
  final Jobrepo jobRepo;
  GetJobsUsecase({required this.jobRepo});

  Future<List<JobEntity>> call() async {
    return await jobRepo.getAllJobs() ;
  }
}
