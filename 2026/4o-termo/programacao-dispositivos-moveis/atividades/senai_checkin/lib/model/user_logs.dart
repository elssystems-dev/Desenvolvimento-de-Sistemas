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
    this.notes
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "created_at": createdAt,
    "media_path": mediaPath,
    "latitude": latitude,
    "longitude": longitude,
    "notes": notes
  };
  
  factory UserLogs.fromMap(Map<String, dynamic> map) {
    return UserLogs(
      id: map['id'],
      createdAt: map['created_at'], 
      mediaPath: map['media_path'], 
      latitude: map['latitude'], 
      longitude: map['longitude'],
      notes: map['notes']
    );
  }
}