import 'package:flutter/material.dart';
import '../models/time_record_model.dart';
import '../services/firestore_service.dart';

enum HistoryFilter {
  today('Hoje'),
  thisWeek('Semana'),
  thisMonth('Mês'),
  all('Todos');

  final String label;
  const HistoryFilter(this.label);
}

class HistoryController extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TimeRecordModel> _records = [];
  HistoryFilter _currentFilter = HistoryFilter.all;
  bool _isLoading = false;
  String? _errorMessage;

  List<TimeRecordModel> get records => _getFilteredRecords();
  List<TimeRecordModel> get rawRecords => _records;
  HistoryFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setFilter(HistoryFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadRecords(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _firestoreService.getUserTimeRecords(userId);
      _records = list;
    } catch (e) {
      _errorMessage = 'Erro ao carregar histórico: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<TimeRecordModel> _getFilteredRecords() {
    final now = DateTime.now();
    switch (_currentFilter) {
      case HistoryFilter.today:
        return _records.where((r) =>
            r.timestamp.year == now.year &&
            r.timestamp.month == now.month &&
            r.timestamp.day == now.day).toList();

      case HistoryFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final beginningOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return _records.where((r) => r.timestamp.isAfter(beginningOfWeek)).toList();

      case HistoryFilter.thisMonth:
        return _records.where((r) =>
            r.timestamp.year == now.year &&
            r.timestamp.month == now.month).toList();

      case HistoryFilter.all:
        return _records;
    }
  }

  /// Calculates total records for today
  List<TimeRecordModel> get todayRecords {
    final now = DateTime.now();
    return _records.where((r) =>
        r.timestamp.year == now.year &&
        r.timestamp.month == now.month &&
        r.timestamp.day == now.day).toList();
  }

  /// Helper to calculate worked hours for today
  String calculateTodayWorkedHours() {
    final list = todayRecords;
    if (list.isEmpty) return '00h 00m';

    // Sort ascending for chronology
    final sorted = List<TimeRecordModel>.from(list)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Duration total = Duration.zero;
    DateTime? lastEntry;

    for (final record in sorted) {
      if (record.type == PunchType.entry || record.type == PunchType.lunchIn) {
        lastEntry = record.timestamp;
      } else if (record.type == PunchType.lunchOut || record.type == PunchType.exit) {
        if (lastEntry != null) {
          total += record.timestamp.difference(lastEntry);
          lastEntry = null;
        }
      }
    }

    // If still clocked in, calculate until current time
    if (lastEntry != null) {
      total += DateTime.now().difference(lastEntry);
    }

    final hours = total.inHours;
    final minutes = total.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }
}
