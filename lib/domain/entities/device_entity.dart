class DeviceEntity {
  final String name;
  final String ip;
  final int port;
  final bool isAvailable;

  DeviceEntity({
    required this.name,
    required this.ip,
    this.port = 54321,
    this.isAvailable = true,
  });

  String get address => '$ip:$port';

  DeviceEntity copyWith({
    String? name,
    String? ip,
    int? port,
    bool? isAvailable,
  }) {
    return DeviceEntity(
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ip': ip,
      'port': port,
      'isAvailable': isAvailable,
    };
  }

  factory DeviceEntity.fromJson(Map<String, dynamic> json) {
    return DeviceEntity(
      name: json['name'] as String,
      ip: json['ip'] as String,
      port: json['port'] as int? ?? 54321,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }
}
