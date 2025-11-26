import 'transfer_entity.dart';

class HistoryEntity {
  final String id;
  final String fileName;
  final int fileSize;
  final String deviceName;
  final String deviceIp;
  final TransferDirection direction;
  final DateTime timestamp;

  HistoryEntity({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.deviceName,
    required this.deviceIp,
    required this.direction,
    required this.timestamp,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '1 week ago';
    }
  }

  HistoryEntity copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    String? deviceName,
    String? deviceIp,
    TransferDirection? direction,
    DateTime? timestamp,
  }) {
    return HistoryEntity(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      deviceName: deviceName ?? this.deviceName,
      deviceIp: deviceIp ?? this.deviceIp,
      direction: direction ?? this.direction,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileSize': fileSize,
      'deviceName': deviceName,
      'deviceIp': deviceIp,
      'direction': direction.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryEntity.fromJson(Map<String, dynamic> json) {
    return HistoryEntity(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
      deviceName: json['deviceName'] as String,
      deviceIp: json['deviceIp'] as String,
      direction: TransferDirection.values.firstWhere(
        (e) => e.name == json['direction'],
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
