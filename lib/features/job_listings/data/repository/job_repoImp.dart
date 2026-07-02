import 'package:aklatna/features/job_listings/data/dataSource/job_datasource.dart';
import 'package:aklatna/features/job_listings/data/models/jobModel.dart';
import 'package:aklatna/features/job_listings/domain/entities/jobEntity.dart';
import 'package:aklatna/features/job_listings/domain/repository/jobRepo.dart';

class JobRepoimp implements Jobrepo{
  final JobDatasource jobDatasource;
  JobRepoimp({required this.jobDatasource});
  // get all jobs
  @override
  Future<List<JobEntity>> getAllJobs() async {
    final jobs = await jobDatasource.getAllJobs();
    return jobs.map((e)=>mapToEntity(e)).toList() ;
  }
}

JobEntity mapToEntity(Jobmodel model) {
  return JobEntity(
    title: model.title,
    description: model.description,
    location: model.location,
    businessId: model.businessId,
    requirements: model.requirements,
    contactPhone: model.contactPhone,
    isApproved: model.isApproved,
    isActive: model.isActive,
    businessName: model.businessName,
  );
}
