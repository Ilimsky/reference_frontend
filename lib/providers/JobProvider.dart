import 'package:flutter/cupertino.dart';

import '../api/ApiService.dart';
import '../models/Job.dart';

class JobProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Job> _jobs = [];
  bool _isLoading = false;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;

  JobProvider(this.apiService){
    fetchJobs();
  }

  void fetchJobs() async {
    _isLoading = true;
    notifyListeners();
    _jobs = await apiService.fetchJobs();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createJob(String name) async {
    final newJob = await apiService.createJob(name);
    _jobs.add(newJob);
    notifyListeners();
  }

  Future<void> updateJob(int id, String name) async {
    final updatedJob = await apiService.updateJob(id, name);
    int index = _jobs.indexWhere((job) => job.id == id);
    if (index != -1) {
      _jobs[index] = updatedJob;
      notifyListeners();
    }
  }

  Future<void> deleteJob(int id) async {
    await apiService.deleteJob(id);
    _jobs.removeWhere((job) => job.id == id);
    notifyListeners();
  }
}