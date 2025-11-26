import 'package:flutter/foundation.dart';
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

  List<HistoryEntity> get history => _filteredHistory;
  HistoryFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  HistoryProvider() {
    _loadMockHistory();
  }

  void _loadMockHistory() {
    // Mock history data for UI demonstration
    _history = [
      HistoryEntity(
        id: '1',
        fileName: 'vacation.jpg',
        fileSize: 4718592,
        deviceName: 'Redmi Note 12',
        deviceIp: '192.168.1.102',
        direction: TransferDirection.send,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      HistoryEntity(
        id: '2',
        fileName: 'design-spec.pdf',
        fileSize: 8601651,
        deviceName: 'Sarah\'s MacBook Pro',
        deviceIp: '192.168.1.105',
        direction: TransferDirection.receive,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      HistoryEntity(
        id: '3',
        fileName: 'concert-footage.mov',
        fileSize: 891289600,
        deviceName: 'Living Room PC',
        deviceIp: '192.168.1.108',
        direction: TransferDirection.send,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      HistoryEntity(
        id: '4',
        fileName: 'new-ringtone.m4a',
        fileSize: 768000,
        deviceName: 'Galaxy Tab S8',
        deviceIp: '192.168.1.110',
        direction: TransferDirection.receive,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HistoryEntity(
        id: '5',
        fileName: 'archive.zip',
        fileSize: 134217728,
        deviceName: 'Redmi Note 12',
        deviceIp: '192.168.1.102',
        direction: TransferDirection.send,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
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

  void addHistory(HistoryEntity item) {
    _history.insert(0, item);
    notifyListeners();
  }

  void removeHistory(String id) {
    _history.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
