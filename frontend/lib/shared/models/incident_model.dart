/// Incident model matching the MongoDB Incidents collection schema.
class IncidentModel {
  final String id;
  final String userId;
  final TriggerType triggerType;
  final DateTime timestamp;
  final GeoPoint location;
  final IncidentStatus status;
  final List<String> mediaLinks;
  final DateTime? resolvedAt;
  final String? notes;

  const IncidentModel({
    required this.id,
    required this.userId,
    required this.triggerType,
    required this.timestamp,
    required this.location,
    this.status = IncidentStatus.active,
    this.mediaLinks = const [],
    this.resolvedAt,
    this.notes,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      triggerType: TriggerType.fromString(json['triggerType'] as String? ?? 'Manual'),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      location: GeoPoint.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      status: IncidentStatus.fromString(json['status'] as String? ?? 'Active'),
      mediaLinks: (json['mediaLinks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'triggerType': triggerType.value,
      'timestamp': timestamp.toIso8601String(),
      'location': location.toGeoJson(),
      'status': status.value,
      'mediaLinks': mediaLinks,
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  IncidentModel copyWith({
    IncidentStatus? status,
    List<String>? mediaLinks,
    DateTime? resolvedAt,
    String? notes,
  }) {
    return IncidentModel(
      id: id,
      userId: userId,
      triggerType: triggerType,
      timestamp: timestamp,
      location: location,
      status: status ?? this.status,
      mediaLinks: mediaLinks ?? this.mediaLinks,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Duration since the incident was triggered.
  Duration get elapsed => DateTime.now().difference(timestamp);

  bool get isActive => status == IncidentStatus.active;
}

/// How the SOS was triggered.
enum TriggerType {
  voice('Voice'),
  motion('Motion'),
  manual('Manual'),
  multiModal('Multi-Modal');

  final String value;
  const TriggerType(this.value);

  static TriggerType fromString(String s) {
    return TriggerType.values.firstWhere(
      (e) => e.value.toLowerCase() == s.toLowerCase(),
      orElse: () => TriggerType.manual,
    );
  }

  String get icon {
    switch (this) {
      case TriggerType.voice:
        return '🎙️';
      case TriggerType.motion:
        return '📳';
      case TriggerType.manual:
        return '🆘';
      case TriggerType.multiModal:
        return '🤖';
    }
  }
}

/// Current status of an incident.
enum IncidentStatus {
  active('Active'),
  resolved('Resolved'),
  falseAlarm('False Alarm');

  final String value;
  const IncidentStatus(this.value);

  static IncidentStatus fromString(String s) {
    return IncidentStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == s.toLowerCase(),
      orElse: () => IncidentStatus.active,
    );
  }
}

/// Geographic point using GeoJSON format for MongoDB compatibility.
class GeoPoint {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    // Handle GeoJSON Point format: { type: "Point", coordinates: [lng, lat] }
    if (json['type'] == 'Point' && json['coordinates'] != null) {
      final coords = json['coordinates'] as List<dynamic>;
      return GeoPoint(
        longitude: (coords[0] as num).toDouble(),
        latitude: (coords[1] as num).toDouble(),
      );
    }
    // Handle flat format
    return GeoPoint(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }

  /// Convert to GeoJSON Point format for MongoDB.
  Map<String, dynamic> toGeoJson() {
    return {
      'type': 'Point',
      'coordinates': [longitude, latitude], // GeoJSON is [lng, lat]
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
    };
  }

  @override
  String toString() => '($latitude, $longitude)';
}
