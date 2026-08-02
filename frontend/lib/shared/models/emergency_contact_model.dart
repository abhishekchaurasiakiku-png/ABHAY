/// Emergency contact model for SOS notification targets.
class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String relationship;
  final bool notifyOnSos;
  final String? fcmToken; // For push notification delivery

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.relationship = 'Other',
    this.notifyOnSos = true,
    this.fcmToken,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      relationship: json['relationship'] as String? ?? 'Other',
      notifyOnSos: json['notifyOnSos'] as bool? ?? true,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'notifyOnSos': notifyOnSos,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? relationship,
    bool? notifyOnSos,
    String? fcmToken,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      notifyOnSos: notifyOnSos ?? this.notifyOnSos,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  /// Predefined relationship options.
  static const List<String> relationshipOptions = [
    'Parent',
    'Spouse',
    'Sibling',
    'Friend',
    'Colleague',
    'Neighbor',
    'Other',
  ];
}
