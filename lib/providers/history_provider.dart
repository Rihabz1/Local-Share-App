import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/history_entity.dart';
import '../domain/entities/transfer_entity.dart';

enum HistoryFilter {
  all,
  sent,
  received;
}

class HistoryProvider with ChangeNotifier {
  List<HistoryEntity> _history = [];
  HistoryFilter _filter = HistoryFilter.all;
  String _searchQuery = '';
  static const String _historyKey = 'transfer_history';

  List<HistoryEntity> get history => _filteredHistory;
  HistoryFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  HistoryProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        _history = historyList
            .map((json) => HistoryEntity.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by timestamp (newest first)
        _history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        notifyListeners();
        debugPrint('Loaded ${_history.length} history items');
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(
        _history.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_historyKey, historyJson);
      debugPrint('Saved ${_history.length} history items');
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  List<HistoryEntity> get _filteredHistory {
    var filtered = _history;

    // Apply filter
    if (_filter == HistoryFilter.sent) {
      filtered = filtered.where((h) => h.direction == TransferDirection.send).toList();
    } else if (_filter == HistoryFilter.received) {
      filtered = filtered.where((h) => h.direction == TransferDirection.receive).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((h) {
        return h.fileName.toLowerCase().contains(query) ||
            h.deviceName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void setFilter(HistoryFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addHistory(HistoryEntity item) async {
    _history.insert(0, item);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> removeHistory(String id) async {
    _history.removeWhere((item) => item.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }
}
