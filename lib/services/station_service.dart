import 'package:flutter/foundation.dart';
import '../data/database.dart';

class StationService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Simulate initialization delay
    await Future.delayed(const Duration(seconds: 1));
    _initialized = true;
  }

  Future<int> getStationCount() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // In a real app, this might come from a network request
      return StationDatabase.allStations.length;
    } catch (e) {
      debugPrint('Error getting station count: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getStationByName(String name) async {
    try {
      // First try exact match
      final station = StationDatabase.allStations.firstWhere(
        (s) => (s['name'] as String).toLowerCase() == name.toLowerCase(),
        orElse: () => {},
      );

      if (station.isNotEmpty) {
        return station;
      }

      // Try contains match
      final fuzzyMatch = StationDatabase.allStations.firstWhere(
        (s) => (s['name'] as String).toLowerCase().contains(name.toLowerCase()),
        orElse: () => {},
      );

      return fuzzyMatch.isNotEmpty ? fuzzyMatch : null;
    } catch (e) {
      debugPrint('Error finding station: $e');
      return null;
    }
  }
}
