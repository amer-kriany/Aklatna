import 'package:aklatna/features/job_listings/domain/entities/jobEntity.dart';

 abstract class Jobrepo {
  // get all jobs
  Future<List<JobEntity>> getAllJobs();
}
