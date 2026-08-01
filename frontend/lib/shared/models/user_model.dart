import 'emergency_contact_model.dart';

/// User model matching the MongoDB Users collection schema.
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? profileImage;
  final String? bloodGroup;
  final String? medicalNotes;
  final String? homeSafeZone;
  final List<EmergencyContact> emergencyContacts;
  final List<String> trustedDevices;
  final AiSettings aiSettings;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImage,
    this.bloodGroup,
    this.medicalNotes,
    this.homeSafeZone,
    this.emergencyContacts = const [],
    this.trustedDevices = const [],
    this.aiSettings = const AiSettings(),
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImage: json['profileImage'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      medicalNotes: json['medicalNotes'] as String?,
      homeSafeZone: json['homeSafeZone'] as String?,
      emergencyContacts: (json['emergencyContacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trustedDevices: (json['trustedDevices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      aiSettings: json['aiSettings'] != null
          ? AiSettings.fromJson(json['aiSettings'] as Map<String, dynamic>)
          : const AiSettings(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      if (profileImage != null) 'profileImage': profileImage,
      if (bloodGroup != null) 'bloodGroup': bloodGroup,
      if (medicalNotes != null) 'medicalNotes': medicalNotes,
      if (homeSafeZone != null) 'homeSafeZone': homeSafeZone,
      'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
      'trustedDevices': trustedDevices,
      'aiSettings': aiSettings.toJson(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profileImage,
    String? bloodGroup,
    String? medicalNotes,
    String? homeSafeZone,
    List<EmergencyContact>? emergencyContacts,
    List<String>? trustedDevices,
    AiSettings? aiSettings,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      homeSafeZone: homeSafeZone ?? this.homeSafeZone,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      trustedDevices: trustedDevices ?? this.trustedDevices,
      aiSettings: aiSettings ?? this.aiSettings,
      createdAt: createdAt,
    );
  }
}

/// User-configurable AI sensitivity settings.
class AiSettings {
  final double voiceSensitivity;
  final double motionSensitivity;
  final bool voiceDetectionEnabled;
  final bool motionDetectionEnabled;
  final List<String> distressKeywords;

  const AiSettings({
    this.voiceSensitivity = 0.75,
    this.motionSensitivity = 0.70,
    this.voiceDetectionEnabled = true,
    this.motionDetectionEnabled = true,
    this.distressKeywords = const [
      'help me',
      'save me',
      'bachao',
      'please help',
      'somebody help',
    ],
  });

  factory AiSettings.fromJson(Map<String, dynamic> json) {
    return AiSettings(
      voiceSensitivity: (json['voiceSensitivity'] as num?)?.toDouble() ?? 0.75,
      motionSensitivity: (json['motionSensitivity'] as num?)?.toDouble() ?? 0.70,
      voiceDetectionEnabled: json['voiceDetectionEnabled'] as bool? ?? true,
      motionDetectionEnabled: json['motionDetectionEnabled'] as bool? ?? true,
      distressKeywords: (json['distressKeywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['help me', 'save me', 'bachao', 'please help', 'somebody help'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voiceSensitivity': voiceSensitivity,
      'motionSensitivity': motionSensitivity,
      'voiceDetectionEnabled': voiceDetectionEnabled,
      'motionDetectionEnabled': motionDetectionEnabled,
      'distressKeywords': distressKeywords,
    };
  }
}
