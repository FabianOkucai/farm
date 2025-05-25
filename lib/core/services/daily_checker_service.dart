import 'dart:async';
import 'package:farm/core/models/season.dart';
import 'package:farm/core/services/notification_generator.dart';
import 'package:farm/core/utils/local_storage.dart';

class DailyCheckerService {
  final LocalStorage _localStorage;
  final NotificationGenerator _notificationGenerator;
  Timer? _timer;

  DailyCheckerService({
    required LocalStorage localStorage,
    required NotificationGenerator notificationGenerator,
  }) : _localStorage = localStorage,
       _notificationGenerator = notificationGenerator;

  void startDailyCheck() {
    // Run initial check
    _checkSeasons();

    // Schedule daily checks at midnight
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);

    // First timer to align with midnight
    Timer(timeUntilMidnight, () {
      _checkSeasons();

      // Then set up daily timer
      _timer = Timer.periodic(const Duration(days: 1), (timer) {
        _checkSeasons();
      });
    });
  }

  void stopDailyCheck() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkSeasons() async {
    final seasons = await _getActiveSeasons();

    for (final season in seasons) {
      final shouldAdvance = _shouldAdvanceMonth(season);

      if (shouldAdvance) {
        final updatedSeason = await _advanceSeasonMonth(season);
        await _notificationGenerator.generateSeasonNotifications(updatedSeason);
      }
    }
  }

  Future<List<Season>> _getActiveSeasons() async {
    final seasonsJson = await _localStorage.getList('active_seasons') ?? [];
    return seasonsJson
        .map((json) => Season.fromJson(json))
        .where((season) => season.status == SeasonStatus.active)
        .toList();
  }

  bool _shouldAdvanceMonth(Season season) {
    final now = DateTime.now();
    final lastUpdated = season.lastUpdated;

    // Check if it's been a month since the last update
    if (now.year > lastUpdated.year) return true;
    if (now.year == lastUpdated.year && now.month > lastUpdated.month)
      return true;

    return false;
  }

  Future<Season> _advanceSeasonMonth(Season season) async {
    final updatedSeason = season.copyWith(
      currentMonth: season.currentMonth + 1,
      lastUpdated: DateTime.now(),
    );

    // Update in local storage
    final seasons = await _getActiveSeasons();
    final updatedSeasons =
        seasons.map((s) {
          if (s.id == season.id) return updatedSeason;
          return s;
        }).toList();

    await _localStorage.setList(
      'active_seasons',
      updatedSeasons.map((s) => s.toJson()).toList(),
    );

    return updatedSeason;
  }
}
