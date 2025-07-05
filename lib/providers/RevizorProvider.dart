import 'package:flutter/cupertino.dart';

import '../api/ApiService.dart';
import '../models/Revizor.dart';

class RevizorProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Revizor> _revizors = [];
  bool _isLoading = false;

  List<Revizor> get revizors => _revizors;
  bool get isLoading => _isLoading;

  RevizorProvider(this.apiService){
    fetchRevizors();
  }

  void fetchRevizors() async {
    _isLoading = true;
    notifyListeners();
    _revizors = await apiService.fetchRevizors();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createRevizor(String name) async {
    final newRevizor = await apiService.createRevizor(name);
    _revizors.add(newRevizor);
    notifyListeners();
  }

  Future<void> updateRevizor(int id, String name) async {
    final updatedRevizor = await apiService.updateRevizor(id, name);
    int index = _revizors.indexWhere((revizor) => revizor.id == id);
    if (index != -1) {
      _revizors[index] = updatedRevizor;
      notifyListeners();
    }
  }

  Future<void> deleteRevizor(int id) async {
    await apiService.deleteRevizor(id);
    _revizors.removeWhere((revizor) => revizor.id == id);
    notifyListeners();
  }
}
