class UserLogs {
  final int? id;
  final DateTime createdAt;
  final String mediaPath;
  final double latitude;
  final double longitude;
  final String? notes;

  UserLogs({
    this.id,
    required this.createdAt,
    required this.mediaPath,
    required this.latitude,
    required this.longitude,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      "created_at": createdAt.toIso8601String(),
      "media_path": mediaPath,
      "latitude": latitude,
      "longitude": longitude,
      "notes": notes,
    };
    if (id != null) {
      map["id"] = id;
    }
    return map;
  }

  factory UserLogs.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final rawDate = map['created_at'];
    if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return UserLogs(
      id: map['id'] as int?,
      createdAt: parsedDate,
      mediaPath: (map['media_path'] ?? '') as String,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String?,
    );
  }

  String get formattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year.toString();
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year às $hour:$minute';
  }
}