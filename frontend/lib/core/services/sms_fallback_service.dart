import 'dart:async';
import '../../shared/models/emergency_contact_model.dart';
import 'location_service.dart';

/// SMS fallback service for offline SOS alerts.
///
/// When the device has no internet connection, this service
/// intercepts the local GSM module to send SMS alerts with
/// GPS coordinates to all emergency contacts.
class SmsFallbackService {
  final LocationService _locationService;

  SmsFallbackService({required LocationService locationService})
      : _locationService = locationService;

  /// Send SOS SMS to all emergency contacts.
  ///
  /// Message includes GPS coordinates as a Google Maps link.
  /// Returns the number of SMS messages successfully sent.
  Future<int> sendSosToContacts(List<EmergencyContact> contacts) async {
    final locationString = _locationService.generateSmsLocation();
    if (locationString == null) {
      print('[SMS] Cannot send SOS — no location available');
      return 0;
    }

    int sentCount = 0;

    for (final contact in contacts) {
      if (!contact.notifyOnSos) continue;

      try {
        final message = _buildSosMessage(contact.name, locationString);
        await _sendSms(contact.phone, message);
        sentCount++;
        print('[SMS] SOS sent to ${contact.name} (${contact.phone})');
      } catch (e) {
        print('[SMS] Failed to send to ${contact.name}: $e');
      }
    }

    return sentCount;
  }

  /// Send a single SMS via the device's native SMS module.
  Future<void> _sendSms(String phoneNumber, String message) async {
    // In production, this uses the `telephony` package:
    //
    // final Telephony telephony = Telephony.instance;
    // await telephony.sendSms(
    //   to: phoneNumber,
    //   message: message,
    //   isMultipart: true, // For long messages
    // );
    //
    // Note: Requires SMS permission on Android.
    // On iOS, SMS can only be sent via MFMessageComposeViewController
    // which requires user interaction — so this is Android-focused.

    // Simulate SMS sending delay
    await Future.delayed(const Duration(milliseconds: 300));

    print('[SMS] Sent to $phoneNumber: ${message.substring(0, 50)}...');
  }

  /// Build the SOS message body.
  String _buildSosMessage(String contactName, String locationString) {
    return '🆘 EMERGENCY ALERT from SafeHer-AI!\n\n'
        '$locationString\n\n'
        'This is an automated SOS alert. '
        'Please try to reach me immediately or contact local emergency services.\n\n'
        'Sent via SafeHer-AI Safety App';
  }

  /// Send a status update SMS (e.g., when SOS is resolved).
  Future<void> sendStatusUpdate(
    List<EmergencyContact> contacts,
    String status,
  ) async {
    for (final contact in contacts) {
      if (!contact.notifyOnSos) continue;

      try {
        final message = '✅ SafeHer-AI Update: $status\n\n'
            'The emergency alert has been updated. '
            'No further action may be needed.';
        await _sendSms(contact.phone, message);
      } catch (e) {
        print('[SMS] Failed status update to ${contact.name}: $e');
      }
    }
  }

  /// Check if SMS permission is granted.
  Future<bool> hasSmsPermission() async {
    // In production:
    // final Telephony telephony = Telephony.instance;
    // return await telephony.requestSmsPermissions ?? false;
    return true; // Placeholder
  }
}
