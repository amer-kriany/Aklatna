import 'package:aklatna/features/job_listings/data/repository/job_repoImp.dart';
import 'package:aklatna/features/job_listings/domain/entities/jobEntity.dart';

class GetJobsUsecase {
  final JobRepoimp jobRepoimp;
  GetJobsUsecase({required this.jobRepoimp});

  Future<List<JobEntity>> call() async {
    return await jobRepoimp.getAllJobs() ;
  }
}
