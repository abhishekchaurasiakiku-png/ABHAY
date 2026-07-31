/// Safety zone model matching the MongoDB SafetyZones collection.
/// Uses GeoJSON Polygon for geospatial queries.
class SafetyZoneModel {
  final String id;
  final List<List<double>> polygonCoordinates; // List of [lng, lat] pairs
  final int riskScore; // 1 (safest) to 10 (most dangerous)
  final int reportedIncidents;
  final String? name;
  final String? description;
  final SafetyZoneMetadata? metadata;

  const SafetyZoneModel({
    required this.id,
    required this.polygonCoordinates,
    required this.riskScore,
    this.reportedIncidents = 0,
    this.name,
    this.description,
    this.metadata,
  });

  factory SafetyZoneModel.fromJson(Map<String, dynamic> json) {
    // Parse GeoJSON Polygon coordinates
    List<List<double>> coords = [];
    if (json['polygon'] != null && json['polygon']['coordinates'] != null) {
      final rawCoords = json['polygon']['coordinates'] as List<dynamic>;
      if (rawCoords.isNotEmpty) {
        // GeoJSON Polygon: coordinates is an array of LinearRings
        // The first ring is the outer boundary
        final ring = rawCoords[0] as List<dynamic>;
        coords = ring
            .map((c) =>
                (c as List<dynamic>).map((v) => (v as num).toDouble()).toList())
            .toList();
      }
    }

    return SafetyZoneModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      polygonCoordinates: coords,
      riskScore: (json['riskScore'] as num?)?.toInt() ?? 5,
      reportedIncidents: (json['reportedIncidents'] as num?)?.toInt() ?? 0,
      name: json['name'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] != null
          ? SafetyZoneMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'polygon': {
        'type': 'Polygon',
        'coordinates': [polygonCoordinates],
      },
      'riskScore': riskScore,
      'reportedIncidents': reportedIncidents,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }

  /// Human-friendly risk label.
  String get riskLabel {
    if (riskScore <= 2) return 'Very Safe';
    if (riskScore <= 4) return 'Safe';
    if (riskScore <= 6) return 'Moderate';
    if (riskScore <= 8) return 'Risky';
    return 'Dangerous';
  }

  /// Whether this zone is considered high-risk (score > 6).
  bool get isHighRisk => riskScore > 6;
}

/// Additional metadata for a safety zone.
class SafetyZoneMetadata {
  final bool hasStreetLighting;
  final bool hasCCTV;
  final double? userDensity; // Estimated users per sq km
  final DateTime? lastUpdated;

  const SafetyZoneMetadata({
    this.hasStreetLighting = false,
    this.hasCCTV = false,
    this.userDensity,
    this.lastUpdated,
  });

  factory SafetyZoneMetadata.fromJson(Map<String, dynamic> json) {
    return SafetyZoneMetadata(
      hasStreetLighting: json['hasStreetLighting'] as bool? ?? false,
      hasCCTV: json['hasCCTV'] as bool? ?? false,
      userDensity: (json['userDensity'] as num?)?.toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasStreetLighting': hasStreetLighting,
      'hasCCTV': hasCCTV,
      if (userDensity != null) 'userDensity': userDensity,
      if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
    };
  }
}
