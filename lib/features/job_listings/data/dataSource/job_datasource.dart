import 'package:aklatna/features/job_listings/data/models/jobModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class JobDatasource {
  final supabase = Supabase.instance.client;
  // get all jobs
  Future<List<Jobmodel>> getAllJobs() async {
  try {
    final response = await supabase
        .from('job_listings')
        .select()
        .eq('is_approved', true)
        .eq('is_active', true);
    return response.map((e) => Jobmodel.fromJson(e)).toList();
  } catch (e) {
    rethrow;
  }
}
}
