enum TransferStatus {
  pending,
  inProgress,
  paused,
  completed,
  failed,
  cancelled;
}

enum TransferDirection {
  send,
  receive;
}

class TransferEntity {
  final String id;
  final List<String> fileIds;
  final String deviceName;
  final String deviceIp;
  final TransferDirection direction;
  final TransferStatus status;
  final double progress; // 0.0 to 1.0
  final double speed; // bytes per second
  final DateTime startedAt;
  final DateTime? completedAt;
  final int totalBytes;
  final int transferredBytes;

  TransferEntity({
    required this.id,
    required this.fileIds,
    required this.deviceName,
    required this.deviceIp,
    required this.direction,
    this.status = TransferStatus.pending,
    this.progress = 0.0,
    this.speed = 0.0,
    DateTime? startedAt,
    this.completedAt,
    required this.totalBytes,
    this.transferredBytes = 0,
  }) : startedAt = startedAt ?? DateTime.now();

  Duration? get eta {
    if (speed <= 0) return null;
    final remaining = totalBytes - transferredBytes;
    return Duration(seconds: (remaining / speed).ceil());
  }

  String get speedFormatted {
    if (speed < 1024) return '${speed.toStringAsFixed(0)} B/s';
    if (speed < 1024 * 1024) return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    return '${(speed / (1024 * 1024)).toStringAsFixed(2)} MB/s';
  }

  String get etaFormatted {
    final eta = this.eta;
    if (eta == null) return '--';
    
    final hours = eta.inHours;
    final minutes = eta.inMinutes % 60;
    final seconds = eta.inSeconds % 60;
    
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  TransferEntity copyWith({
    String? id,
    List<String>? fileIds,
    String? deviceName,
    String? deviceIp,
    TransferDirection? direction,
    TransferStatus? status,
    double? progress,
    double? speed,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalBytes,
    int? transferredBytes,
  }) {
    return TransferEntity(
      id: id ?? this.id,
      fileIds: fileIds ?? this.fileIds,
      deviceName: deviceName ?? this.deviceName,
      deviceIp: deviceIp ?? this.deviceIp,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalBytes: totalBytes ?? this.totalBytes,
      transferredBytes: transferredBytes ?? this.transferredBytes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileIds': fileIds,
      'deviceName': deviceName,
      'deviceIp': deviceIp,
      'direction': direction.name,
      'status': status.name,
      'progress': progress,
      'speed': speed,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalBytes': totalBytes,
      'transferredBytes': transferredBytes,
    };
  }

  factory TransferEntity.fromJson(Map<String, dynamic> json) {
    return TransferEntity(
      id: json['id'] as String,
      fileIds: List<String>.from(json['fileIds'] as List),
      deviceName: json['deviceName'] as String,
      deviceIp: json['deviceIp'] as String,
      direction: TransferDirection.values.firstWhere(
        (e) => e.name == json['direction'],
      ),
      status: TransferStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      progress: (json['progress'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      totalBytes: json['totalBytes'] as int,
      transferredBytes: json['transferredBytes'] as int,
    );
  }
}
