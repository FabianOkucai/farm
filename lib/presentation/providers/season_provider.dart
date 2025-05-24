import 'package:flutter/material.dart';
import '../../core/models/season_data.dart';
import '../../core/services/api_service.dart';

class SeasonProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<SeasonData> _seasons = [];
  SeasonData? _selectedSeason;
  bool _isLoading = false;
  String? _error;

  SeasonProvider({required ApiService apiService}) : _apiService = apiService;

  List<SeasonData> get seasons => _seasons;
  SeasonData? get selectedSeason => _selectedSeason;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllSeasons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _seasons = await _apiService.getAllSeasons();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadSeasonInfo(int monthNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedSeason = await _apiService.getSeasonInfo(monthNumber);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
