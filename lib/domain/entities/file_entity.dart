enum FileType {
  image,
  video,
  audio,
  document,
  archive,
  other;

  static FileType fromExtension(String extension) {
    final ext = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'].contains(ext)) {
      return FileType.image;
    } else if (['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv', 'webm'].contains(ext)) {
      return FileType.video;
    } else if (['mp3', 'wav', 'flac', 'aac', 'm4a', 'ogg', 'wma'].contains(ext)) {
      return FileType.audio;
    } else if (['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext)) {
      return FileType.document;
    } else if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return FileType.archive;
    }
    return FileType.other;
  }
}

class FileEntity {
  final String id;
  final String name;
  final String path;
  final int size;
  final FileType type;
  final DateTime addedAt;

  FileEntity({
    required this.id,
    required this.name,
    required this.path,
    required this.size,
    required this.type,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last : '';
  }

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  FileEntity copyWith({
    String? id,
    String? name,
    String? path,
    int? size,
    FileType? type,
    DateTime? addedAt,
  }) {
    return FileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      size: size ?? this.size,
      type: type ?? this.type,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'size': size,
      'type': type.name,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FileEntity.fromJson(Map<String, dynamic> json) {
    return FileEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      size: json['size'] as int,
      type: FileType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FileType.other,
      ),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}
