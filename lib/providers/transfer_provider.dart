import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/entities/transfer_entity.dart';
import '../domain/entities/file_entity.dart';
import '../domain/entities/device_entity.dart';

class TransferProvider with ChangeNotifier {
  TransferEntity? _activeTransfer;
  Timer? _progressTimer;
  int _currentFileIndex = 0;

  TransferEntity? get activeTransfer => _activeTransfer;
  bool get hasActiveTransfer => _activeTransfer != null;

  void startTransfer({
    required List<FileEntity> files,
    required DeviceEntity device,
    required TransferDirection direction,
  }) {
    if (files.isEmpty) return;

    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.size);

    _activeTransfer = TransferEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileIds: files.map((f) => f.id).toList(),
      deviceName: device.name,
      deviceIp: device.ip,
      direction: direction,
      status: TransferStatus.inProgress,
      totalBytes: totalBytes,
    );

    _currentFileIndex = 0;
    _simulateTransfer(files);
    notifyListeners();
  }

  void _simulateTransfer(List<FileEntity> files) {
    // Simulate transfer with realistic progress updates
    int elapsedMs = 0;
    const updateIntervalMs = 100;
    
    _progressTimer = Timer.periodic(
      const Duration(milliseconds: updateIntervalMs),
      (timer) {
        elapsedMs += updateIntervalMs;

        if (_activeTransfer == null) {
          timer.cancel();
          return;
        }

        // Simulate speed between 5-10 MB/s
        final speed = 6.2 * 1024 * 1024; // 6.2 MB/s
        final increment = (speed * updateIntervalMs / 1000).toInt();
        
        final newTransferred = (_activeTransfer!.transferredBytes + increment)
            .clamp(0, _activeTransfer!.totalBytes);
        
        final newProgress = newTransferred / _activeTransfer!.totalBytes;

        _activeTransfer = _activeTransfer!.copyWith(
          transferredBytes: newTransferred,
          progress: newProgress,
          speed: speed.toDouble(),
        );

        notifyListeners();

        // Complete transfer
        if (newProgress >= 1.0) {
          timer.cancel();
          _completeTransfer();
        }
      },
    );
  }

  void _completeTransfer() {
    if (_activeTransfer == null) return;

    _activeTransfer = _activeTransfer!.copyWith(
      status: TransferStatus.completed,
      progress: 1.0,
      completedAt: DateTime.now(),
    );

    notifyListeners();
  }

  void pauseTransfer() {
    if (_activeTransfer == null) return;
    
    _progressTimer?.cancel();
    _activeTransfer = _activeTransfer!.copyWith(
      status: TransferStatus.paused,
    );
    notifyListeners();
  }

  void resumeTransfer(List<FileEntity> files) {
    if (_activeTransfer == null) return;

    _activeTransfer = _activeTransfer!.copyWith(
      status: TransferStatus.inProgress,
    );
    _simulateTransfer(files);
    notifyListeners();
  }

  void cancelTransfer() {
    _progressTimer?.cancel();
    if (_activeTransfer == null) return;

    _activeTransfer = _activeTransfer!.copyWith(
      status: TransferStatus.cancelled,
    );
    notifyListeners();
    
    // Clear after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _activeTransfer = null;
      notifyListeners();
    });
  }

  void clearTransfer() {
    _progressTimer?.cancel();
    _activeTransfer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}
