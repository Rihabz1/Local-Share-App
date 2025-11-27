import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/entities/transfer_entity.dart';
import '../domain/entities/file_entity.dart';
import '../domain/entities/device_entity.dart';
import '../services/file_transfer_service.dart';

class TransferProvider with ChangeNotifier {
  TransferEntity? _activeTransfer;
  Timer? _progressTimer;
  final FileTransferService _transferService = FileTransferService();

  TransferEntity? get activeTransfer => _activeTransfer;
  bool get hasActiveTransfer => _activeTransfer != null;

  Future<void> startTransfer({
    required List<FileEntity> files,
    required DeviceEntity device,
    required TransferDirection direction,
  }) async {
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

    notifyListeners();

    // Setup callbacks for real transfer
    _transferService.onProgress = (progress, speed) {
      if (_activeTransfer == null) return;
      
      final transferred = (totalBytes * progress).toInt();
      _activeTransfer = _activeTransfer!.copyWith(
        transferredBytes: transferred,
        progress: progress,
        speed: speed,
      );
      notifyListeners();
    };

    _transferService.onComplete = () {
      _completeTransfer();
    };

    _transferService.onError = (error) {
      debugPrint('Transfer error: $error');
      if (_activeTransfer != null) {
        _activeTransfer = _activeTransfer!.copyWith(
          status: TransferStatus.failed,
        );
        notifyListeners();
      }
    };

    try {
      // Start actual file transfer
      if (direction == TransferDirection.send) {
        await _transferService.sendFiles(
          device: device,
          files: files,
        );
      }
      // Receiving is handled by receive_provider
    } catch (e) {
      debugPrint('Error starting transfer: $e');
      if (_activeTransfer != null) {
        _activeTransfer = _activeTransfer!.copyWith(
          status: TransferStatus.failed,
        );
        notifyListeners();
      }
    }
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

  Future<void> resumeTransfer(List<FileEntity> files, DeviceEntity device) async {
    if (_activeTransfer == null) return;

    _activeTransfer = _activeTransfer!.copyWith(
      status: TransferStatus.inProgress,
    );
    notifyListeners();
    
    // Resume transfer
    await startTransfer(
      files: files,
      device: device,
      direction: _activeTransfer!.direction,
    );
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
    _transferService.dispose();
    super.dispose();
  }
}
