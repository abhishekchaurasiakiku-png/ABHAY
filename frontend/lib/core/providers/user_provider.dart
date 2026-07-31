import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/emergency_contact_model.dart';

/// User profile and emergency contacts state management.
class UserProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EmergencyContact> get emergencyContacts =>
      _user?.emergencyContacts ?? [];

  /// Set user from auth response.
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// Fetch user profile from backend.
  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _error = 'Failed to load profile';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Update user profile.
  Future<bool> updateProfile({
    String? name,
    String? phone,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.userProfile,
        data: {
          'name': ?name,
          'phone': ?phone,
        },
      );

      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add an emergency contact.
  Future<bool> addEmergencyContact(EmergencyContact contact) async {
    if (_user == null) return false;

    try {
      final updatedContacts = [..._user!.emergencyContacts, contact];
      final response = await _apiClient.put(
        ApiConstants.userContacts,
        data: {
          'emergencyContacts': updatedContacts.map((c) => c.toJson()).toList(),
        },
      );

      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add contact';
      notifyListeners();
      return false;
    }
  }

  /// Remove an emergency contact.
  Future<bool> removeEmergencyContact(String contactId) async {
    if (_user == null) return false;

    try {
      final updatedContacts = _user!.emergencyContacts
          .where((c) => c.id != contactId)
          .toList();
      final response = await _apiClient.put(
        ApiConstants.userContacts,
        data: {
          'emergencyContacts': updatedContacts.map((c) => c.toJson()).toList(),
        },
      );

      _user = UserModel.fromJson(response.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove contact';
      notifyListeners();
      return false;
    }
  }

  /// Update AI sensitivity settings.
  Future<bool> updateAiSettings(AiSettings settings) async {
    if (_user == null) return false;

    try {
      await _apiClient.put(
        ApiConstants.userAiSettings,
        data: settings.toJson(),
      );

      _user = _user!.copyWith(aiSettings: settings);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update AI settings';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
